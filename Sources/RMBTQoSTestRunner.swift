//
//  RMBTQoSTestRunner.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 15.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

@objc protocol RMBTQoSTestRunnerDelegate: AnyObject {
    func qosRunnerDidFail()
    func qosRunnerDidStart(with testGroups: [RMBTQoSTestGroup])
//    func qosRunnerDidFinishTestInGroup(_ group: RMBTQoSTestGroup, groupProgress: Float, totalProgress: Float)
    
    func qosRunnerDidUpdateProgress(_ progress: Float, in group: RMBTQoSTestGroup, totalProgress: Float)
    
    func qosRunnerDidComplete(with results: [[String: Any]])
}


class RMBTQoSTestRunner: NSObject {
    private weak var delegate: RMBTQoSTestRunnerDelegate?
    
    private var groups: [RMBTQoSTestGroup] = []
    private var tests: [RMBTQoSTest] = []
    
    private var controlConnections: [RMBTQoSControlConnectionParams: RMBTQoSControlConnection] = [:]
    
    private var queue: OperationQueue = OperationQueue()

    private var notificationQueue: DispatchQueue = DispatchQueue(label: "at.rtr.rmbt.qostestrunner.notification")
    
    private var results: [String: [String: Any]] = [:]
    
    private var isDead: Bool = false
    
    private var totalProgress: RMBTCompositeProgress?
    
    @objc init(delegate: RMBTQoSTestRunnerDelegate) {
        self.delegate = delegate
        self.queue.isSuspended = true
        self.queue.maxConcurrentOperationCount = 4
    }
    
    // Fetches qos objectives from control server and initializes internal state, enqueuing all tests to run
    @objc func start(with token: String) { // needed for qos control server connection
        results = [:]

        RMBTControlServer.shared.getQoSParams { [weak self] response in
            guard let self = self else { return }
            guard let objectives = response.objectives else {
                Log.logger.error("Error getting QoS params: no objectives received")
                self.fail()
                return
            }
            
            var tests: [RMBTQoSTest] = []
            var groups: [RMBTQoSTestGroup] = []
            var groupsProgress: [RMBTCompositeProgress] = []

            objectives.forEach { (key: String, value: [[String : AnyObject]]) in
                let desc: String
                if let value = RMBTControlServer.shared.qosTestNames[key.uppercased()] {
                    desc = value
                } else {
                    desc = key
                }
                
                guard let g = RMBTQoSTestGroup.group(for: key, description: desc) else { return }
                
                var groupTestsProgress: [RMBTProgress] = []
                    
                for params in value {
                    if let t = g.test(with: params) {
                        tests.append(t)
                        groupTestsProgress.append(t.progress)
                    }
                }
                    
                if (groupTestsProgress.count > 0) {
                    groups.append(g)
                    
                    
                    let gp = RMBTCompositeProgress(with: groupTestsProgress)
                    
                    gp.onFractionCompleteChange = { [weak self] p in
                        guard let self = self else { return }
                        self.notificationQueue.async {
                            self.delegate?.qosRunnerDidUpdateProgress(p, in: g, totalProgress: self.totalProgress?.fractionCompleted ?? 0.0)
                        }
                    }
                    
                    groupsProgress.append(gp)
                }
            }

            Log.logger.debug("Starting QoS with tests: \(tests)")

            self.tests = tests
            self.groups = groups
            self.totalProgress = RMBTCompositeProgress(with: groupsProgress)

            // Construct a map of all different control server connection params and create/reuse a connection for each one,
            // then assign them to tests that use them:
            
            
            self.tests.forEach { t in
                if let test = t as? RMBTQoSCCTest,
                   let ccParams = test.controlConnectionParams {
                    if let conn = self.controlConnections[ccParams] {
                        test.controlConnection = conn
                    } else {
                        let conn = RMBTQoSControlConnection(with: ccParams, token: token)
                        self.controlConnections[ccParams] = conn
                        test.controlConnection = conn
                    }
                }
            }
            
            self.delegate?.qosRunnerDidStart(with: groups)

            self.enqueue()
        } error: { error in
            Log.logger.error("Error getting QoS params \(String(describing: error))")
            self.fail()
        }
    }
    
    @objc func cancel() {
        queue.cancelAllOperations()
        self.done()
    }
    
    func fail() {
        self.cancel()
        self.delegate?.qosRunnerDidFail()
    }
    
    func done() {
        RMBTQosWebTestURLProtocol.stop()
        
        controlConnections.values.forEach { c in
            c.close()
        }
        
        isDead = true
    }
    
    func enqueue() {
        assert(!isDead)
        assert(tests.count > 0)
        
        let group = DispatchGroup()
        
        
        if (tests.count > 0) {
            RMBTQosWebTestURLProtocol.start()
            
            let testsByConcurrency: [RMBTQoSTest] = tests.sorted(by: { $0.concurrencyGroup > $1.concurrencyGroup })
            
            var lastConcurrencyGroup = testsByConcurrency.first?.concurrencyGroup
            var lastConcurrencyGroupTests: [RMBTQoSTest] = []
            var marker: Operation?

            for t in testsByConcurrency {
                if (t.concurrencyGroup != lastConcurrencyGroup) {
                    marker = Operation()
                    marker?.completionBlock = {
                        Log.logger.debug("QoS concurrency group \(String(describing: lastConcurrencyGroup)) finished")
                    };
                    marker?.name = String(format: "End of concurrency group %ld", UInt(lastConcurrencyGroup ?? 0))
                    
                    for pt in lastConcurrencyGroupTests {
                        marker?.addDependency(pt)
                    }
                    
                    if let marker = marker {
                        queue.addOperation(marker)
                    }
                    
                    
                    lastConcurrencyGroupTests = [];
                    lastConcurrencyGroup = t.concurrencyGroup
                }

                if let m = marker {
                    t.addDependency(m)
                }
                
                lastConcurrencyGroupTests.append(t)
                
                group.enter()
                
                t.completionBlock = { [weak self, weak t] in
                    guard let self = self else { return }
                    
                    self.notificationQueue.async {
                        assert(t != nil)
                        guard let t = t else {
                            group.leave()
                            return
                        }
                        
                        // Add test type and uid to result dictionary and store it
                        var result = t.result
                        result["test_type"] = t.group?.key ?? ""
                        result["qos_test_uid"] = t.uid
                        if t.durationNanos > 0 {
                            result["duration_ns"] = t.durationNanos
                        }
                        
                        self.results[t.uid] = result
                        
                        // Ensure test progress is complete
                        t.progress.completedUnitCount = t.progress.totalUnitCount
                        
                        group.leave()
                    }
                }
                
                self.queue.addOperation(t)
            }
        }

        queue.addOperation { [weak self] in
            guard let self = self else { return }
            group.wait()
            
            self.notificationQueue.async {
                self.delegate?.qosRunnerDidComplete(with: Array(self.results.values))
                self.done()
            }
        }
        
        queue.isSuspended = false
    }
}
