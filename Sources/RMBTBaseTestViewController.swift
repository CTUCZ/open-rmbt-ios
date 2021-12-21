//
//  RMBTBaseTestViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 15.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

protocol RMBTBaseTestViewControllerSubclass: AnyObject {

    func onTestUpdatedTotalProgress(_ percentage: UInt, gaugeProgress gaugePercentage: UInt)
    
    func onTestUpdatedStatus(_ status: String)
    func onTestUpdatedConnectivity(_ connectivity: RMBTConnectivity)
    func onTestUpdatedLocation(_ location: CLLocation)
    func onTestUpdatedServerName(_ name: String)

    func onTestStartedPhase(_ phase: RMBTTestRunnerPhase)
    func onTestFinishedPhase(_ phase: RMBTTestRunnerPhase)

    func onTestMeasuredLatency(_ nanos: UInt64)
    func onTestMeasuredTroughputs(_ throughputs: [Any], in phase: RMBTTestRunnerPhase)

    func onTestMeasuredDownloadSpeed(_ kbps: UInt32)
    func onTestMeasuredUploadSpeed(_ kbps: UInt32)

    func onTestStartedQoS(with groups: [RMBTQoSTestGroup])
    func onTestUpdatedProgress(_ progress: Float, in group: RMBTQoSTestGroup)
    
    func onTestCompleted(with result: RMBTHistoryResult!, qos qosPerformed: Bool)
    func onTestCancelled(with reason: RMBTTestRunnerCancelReason)
}

// A base class for both regular test view controller and loop view controller, which have different
// display logic. The behaviour is customized by implementing the RMBTBaseTestViewControllerSubclass protocol
class RMBTBaseTestViewController: UIViewController {

    private var finishedPercentage: UInt = 0
    private var finishedGaugePercentage: UInt = 0
    private var testRunner: RMBTTestRunner?
    private var qosPerformed: Bool = false
    private var qosWillPerformed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        qosWillPerformed = RMBTTestRunner.willQoSPerformed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true // Disallow turning off the screen
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Allow turning off the screen again.
        // Note that enabling the idle timer won't reset it, so if the device has alredy been idle the screen will dim
        // immediately. To prevent this, we delay enabling by 5s.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    func percentage(after phase: RMBTTestRunnerPhase) -> UInt {
        switch(phase) {
        case .none: return 0
        case .fetchingTestParams, .wait: return 4
        case .`init`: return 20
        case .latency: return 40
        case .down, .initUp:  // no visualization for init up
            return 70
        case .up: return 100
        case .qoS: return 100
        case .submittingTestResult:
            return 100 // also no visualization for submission
        @unknown default:
            return 0
        }
    }
    
    func percentageAfterPhaseWithQos(_ phase: RMBTTestRunnerPhase) -> UInt {
        switch(phase) {
        case .none: return 0
        case .fetchingTestParams, .wait: return 4
        case .`init`: return 15
        case .latency: return 30
        case .down, .initUp:  // no visualization for init up
            return 50
        case .up: return 75
        case .qoS: return 100
        case .submittingTestResult:
            return 100 // also no visualization for submission
        @unknown default:
            return 0
        }
    }
    
    func gaugePercentage(after phase: RMBTTestRunnerPhase) -> UInt {
        switch(phase) {
        case .none: return 0
        case .fetchingTestParams, .wait: return 4
        case .`init`: return 10
        case .latency: return 23
        case .down, .initUp:  // no visualization for init up
            return 49
        case .up: return 74
        case .qoS: return 100
        case .submittingTestResult:
            return 100 // also no visualization for submission
        @unknown default:
            return 0
        }
    }

    func percentage(for phase: RMBTTestRunnerPhase) -> UInt {
        switch (phase) {
        case .wait:    return 4 /* waiting phase, visualized as init */
        case .`init`:    return 16 /* waiting phase, visualized as init */
        case .latency: return 20
        case .down:    return 30
        case .up:      return 30
        case .qoS:     return 30
        default: return 0;
        }
    }
    
    func gaugePercentage(for phase: RMBTTestRunnerPhase) -> UInt {
        switch (phase) {
        case .wait:    return 4 /* waiting phase, visualized as init */
        case .`init`:    return 6 /* waiting phase, visualized as init */
        case .latency: return 13
        case .down:    return 26
        case .up:      return 25
        default: return 0
        }
    }

    func percentageForPhaseWithQos(_ phase: RMBTTestRunnerPhase) -> UInt {
        switch (phase) {
        case .wait:    return 4 /* waiting phase, visualized as init */
        case .`init`:    return 11 /* waiting phase, visualized as init */
        case .latency: return 15
        case .down:    return 20
        case .up:      return 25
        case .qoS:     return 25
        default: return 0;
        }
    }
    
    func gaugePercentageForPhaseWithQos(_ phase: RMBTTestRunnerPhase) -> UInt {
        switch (phase) {
        case .wait:    return 4 /* waiting phase, visualized as init */
        case .`init`:    return 6 /* waiting phase, visualized as init */
        case .latency: return 13
        case .down:    return 26
        case .up:      return 25
        case .qoS:      return 26
        default: return 0;
        }
    }
    
    func statusString(for phase: RMBTTestRunnerPhase) -> String {
        switch(phase) {
        case .none, .fetchingTestParams:
            return NSLocalizedString("Fetching test parameters", comment: "Phase status label")
        case .wait:
            return NSLocalizedString("Waiting for test server", comment: "Phase status label")
        case .`init`:
            return NSLocalizedString("Initializing", comment: "Phase status label")
        case .latency:
            return NSLocalizedString("Pinging", comment: "Phase status label")
        case .down:
            return NSLocalizedString("Download", comment: "Phase status label");
        case .initUp:
                return NSLocalizedString("Initializing Upload", comment: "Phase status label")
        case .up:
            return NSLocalizedString("Upload", comment: "Phase status label")
        case .qoS:
            return NSLocalizedString("measurement_qos", comment: "Phase status label");
        case .submittingTestResult:
            return NSLocalizedString("Finalizing", comment: "Phase status label")
        @unknown default:
            return ""
        }
    }
    
    func startTest(with extraParams: [String: Any]?) {
        finishedPercentage = 0
        finishedGaugePercentage = 0
        qosPerformed = false
        if let subself = self as? RMBTBaseTestViewControllerSubclass {
            subself.onTestUpdatedTotalProgress(0, gaugeProgress: 0)
            subself.onTestUpdatedServerName("-")
            subself.onTestUpdatedStatus("-")
        }
        testRunner = RMBTTestRunner(delegate: self)
        testRunner?.start(withExtraParams: extraParams)
    }
    
    func cancelTest() {
        RMBTControlServer.shared.cancelAllRequests()
        testRunner?.cancel() // TODO: move control server to runner
    }
}

extension RMBTBaseTestViewController: RMBTTestRunnerDelegate {
    
    func testRunnerDidStart(_ phase: RMBTTestRunnerPhase) {
        guard let subself = self as? RMBTBaseTestViewControllerSubclass else { return }
        
        if (phase == .`init` || phase == .wait) {
            subself.onTestUpdatedServerName(testRunner?.testParams.serverName ?? "")
        }
        subself.onTestUpdatedStatus(self.statusString(for: phase))
        subself.onTestStartedPhase(phase)
    }
    
    func testRunnerDidFinish(_ phase: RMBTTestRunnerPhase) {
        guard let testRunner = self.testRunner else { return }
        if (qosWillPerformed) {
            finishedPercentage = self.percentageAfterPhaseWithQos(phase)
        } else {
            finishedPercentage = self.percentage(after: phase)
        }
        finishedGaugePercentage = self.gaugePercentage(after: phase)
        
        assert(finishedPercentage <= 100, "Invalid percentage")
        guard let subself = self as? RMBTBaseTestViewControllerSubclass else { return }
        
        subself.onTestUpdatedTotalProgress(finishedPercentage, gaugeProgress: finishedGaugePercentage)

        if (phase == .latency) {
            subself.onTestMeasuredLatency(testRunner.testResult.medianPingNanos)
        } else if (phase == .down) {
            subself.onTestMeasuredDownloadSpeed(UInt32(testRunner.testResult.totalDownloadHistory.totalThroughput.kilobitsPerSecond()))
        } else if (phase == .up) {
            subself.onTestMeasuredUploadSpeed(UInt32(testRunner.testResult.totalUploadHistory.totalThroughput.kilobitsPerSecond()))
        } else if (phase == .qoS) {
            qosPerformed = true
        }

        subself.onTestFinishedPhase(phase)
    }
    
    func testRunnerDidUpdateProgress(_ progress: Float, in phase: RMBTTestRunnerPhase) {
        var totalPercentage = Float(finishedPercentage)
        var totalGaugePercentage = Float(finishedGaugePercentage)
        if (qosWillPerformed) {
            totalPercentage += Float(self.percentageForPhaseWithQos(phase)) * progress
            totalGaugePercentage += Float(self.gaugePercentageForPhaseWithQos(phase)) * progress
        } else {
            totalPercentage += Float(self.percentage(for: phase)) * progress
            totalGaugePercentage += Float(self.gaugePercentage(for: phase)) * progress
        }
        assert(totalPercentage <= 100, "Invalid percentage")
        
        guard let subself = self as? RMBTBaseTestViewControllerSubclass else { return }
        subself.onTestUpdatedTotalProgress(UInt(totalPercentage), gaugeProgress: UInt( totalGaugePercentage))
    }
    
    func testRunnerDidMeasureThroughputs(_ throughputs: [Any]!, in phase: RMBTTestRunnerPhase) {
        guard let subself = self as? RMBTBaseTestViewControllerSubclass else { return }
        subself.onTestMeasuredTroughputs(throughputs, in: phase)
    }
    
    func testRunnerDidDetect(_ connectivity: RMBTConnectivity!) {
        guard let subself = self as? RMBTBaseTestViewControllerSubclass else { return }
        subself.onTestUpdatedConnectivity(connectivity)
    }
    
    func testRunnerDidDetect(_ location: CLLocation!) {
        guard let subself = self as? RMBTBaseTestViewControllerSubclass else { return }
        subself.onTestUpdatedLocation(location)
    }
    
    func testRunnerDidComplete(with result: RMBTHistoryResult!) {
        guard let subself = self as? RMBTBaseTestViewControllerSubclass else { return }
        subself.onTestCompleted(with: result, qos: qosPerformed)
    }
    
    func testRunnerDidCancelTest(with cancelReason: RMBTTestRunnerCancelReason) {
        guard let subself = self as? RMBTBaseTestViewControllerSubclass else { return }
        subself.onTestUpdatedStatus(NSLocalizedString("Aborted", comment: "Test status"))
        subself.onTestCancelled(with: cancelReason)
    }
    
    func testRunnerQoSDidStart(withGroups groups: [Any]!) {
        guard let subself = self as? RMBTBaseTestViewControllerSubclass else { return }
        subself.onTestStartedQoS(with: (groups as? [RMBTQoSTestGroup]) ?? [])
    }
    
    func testRunnerQoSGroup(_ group: RMBTQoSTestGroup!, didUpdateProgress progress: Float) {
        guard let subself = self as? RMBTBaseTestViewControllerSubclass else { return }
        subself.onTestUpdatedProgress(progress, in: group)
    }
    
    
}
