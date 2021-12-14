//
//  RMBTHistoryQoSGroupResult.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTHistoryQoSGroupResult: NSObject {
    private(set) var name: String = ""
    private(set) var about: String?
    @objc private(set) var tests: [RMBTHistoryQoSSingleResult] = []
    private(set) var succeededCount: UInt = 0
    
    private var item: RMBTHistoryResultItem?
    
    @objc(resultsWithResponse:)
    static func results(with response: [String: Any]) -> [RMBTHistoryQoSGroupResult] {
        var identifiers: [String] = []
        var resultsMap: [String: [String: Any]] = [:]
        var statusDetailsMap: [NSNumber: Any] = [:]
        
        let testDescs = response["testresultdetail_testdesc"] as? [[String: Any]] ?? []
        for testDesc in testDescs {
            let name = testDesc["name"] as? String ?? ""
            if let identifier = (testDesc["test_type"] as? String)?.uppercased() {
                resultsMap[identifier] = ["name": name, "tests": []]
                identifiers.append(identifier)
            }
        }
        
        let descs = response["testresultdetail_desc"] as? [[String: Any]] ?? []
        for info in descs {
            if let uids = info["uid"] as? [NSNumber] {
                for uid in uids {
                    statusDetailsMap[uid] = info["desc"] as? String ?? ""
                }
//            for (NSString *uid in info[@"uid"]) {
//                statusDetailsMap[uid] = info[@"desc"];
//            }
            }
        }
        
        let testresultdetail = response["testresultdetail"] as? [[String: Any]] ?? []
       
        for info in testresultdetail {
            let identifier = (info["test_type"] as? String)?.uppercased() ?? ""
            var data = resultsMap[identifier]
                let r = RMBTHistoryQoSSingleResult(with: info)
            r.statusDetails = statusDetailsMap[r.uid] as? String
            var tests: [RMBTHistoryQoSSingleResult] = (data?["tests"] as? [RMBTHistoryQoSSingleResult]) ?? []
            tests.append(r)
            data?["tests"] = tests
            resultsMap[identifier] = data
        }

        let testresultdetail_testdesc = response["testresultdetail_testdesc"] as? [[String: Any]] ?? []
        for info in testresultdetail_testdesc {
            let identifier = (info["test_type"] as? String)?.uppercased() ?? ""
            var data = resultsMap[identifier]
            data?["about"] = info["desc"]
            resultsMap[identifier] = data
        }
        
        var result: [RMBTHistoryQoSGroupResult] = []

        for identifier in identifiers {
            var tests = resultsMap[identifier]?["tests"] as? [RMBTHistoryQoSSingleResult] ?? []
            if tests.count > 0 {
                // Sort tests so that failed ones come first:
                tests.sort(by: { t1, t2 in
                    if (!t1.isSuccessful && t2.isSuccessful) {
                        return true
                    } else if (t1.isSuccessful && !t2.isSuccessful) {
                        return false
                    } else {
                        return t1.uid.compare(t2.uid) == .orderedAscending
                    }
                })
                
                result.append(RMBTHistoryQoSGroupResult(with: identifier,
                                                        name: resultsMap[identifier]?["name"] as? String ?? "",
                                                        about: resultsMap[identifier]?["about"] as? String ?? "",
                                                        tests: tests))
            }
        }

        return result
    }

    init(with identifier: String, name: String, about: String, tests: [RMBTHistoryQoSSingleResult]) {
        self.name = name
        self.about = about
        self.tests = tests
        self.succeededCount = UInt(tests.filter({ $0.isSuccessful }).count)
    }
    
    override var description: String {
        return "RMBTHistoryQoSGroupResult (name=\(String(describing: name)), about=\(String(describing: about)), \(succeededCount)/\(tests.count)"
    }
    
    func toResultItem() -> RMBTHistoryResultItem? {
        if item == nil {
            let count = "(\(succeededCount)/\(tests.count)"
            let classification = succeededCount != tests.count ? 1 : 3
            item = RMBTHistoryResultItem(title: name, value: count, classification: classification, hasDetails: true)
        }
        
        return item
    }
    
    static func summarize(_ results: [RMBTHistoryQoSGroupResult], with percentage: Bool) -> String? {
        var success = 0
        var total = 0
        
        for r in results {
            success += Int(r.succeededCount)
            total += r.tests.count
        }
        
        
        var result = "\(success)/\(total)"
        if (percentage) {
            result = "\(RMBTHelpers.RMBTPercent(success, total))% (\(result)"
        }
        return result
    }
    
    static func summarizePercents(_ results: [RMBTHistoryQoSGroupResult]) -> String? {
        guard results.count > 0 else { return nil }
        
        var success = 0
        var total = 0
        
        for r in results {
            success += Int(r.succeededCount)
            total += r.tests.count
        }
        return String(format: "%f", Double(success) / Double(total))
    }
}
