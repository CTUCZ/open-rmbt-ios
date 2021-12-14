//
//  RMBTHistoryResultItem.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 14.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTHistoryResultItem: NSObject {
    private(set) var title: String = ""
    private(set) var value: String = ""
    private(set) var classification: Int = -1
    private(set) var hasDetails: Bool = false
    
    init(with response: [String: Any]) {
        if let title = response["title"] as? String {
            if title == "Connection" {
                self.title = NSLocalizedString("history.result.connection", comment: "");
            } else if title == "Operator" {
                self.title = NSLocalizedString("history.result.operator", comment: "")
            } else {
                self.title = title
            }
        } else {
            assert(false, "title can't parse")
        }
            
        if let value = (response["value"] as? NSObject)?.description {
            self.value = value
        } else {
            assert(false, "value can't parse")
        }
        
        if let classification = response["classification"] as? Int {
            self.classification = classification
        }
    }
    
    init(title: String, value: String, classification: Int, hasDetails: Bool) {
        self.title = title
        self.value = value
        self.classification = classification
        self.hasDetails = hasDetails
    }
    
    //Get classification from percent
    static func classification(from percent: Double) -> Int {
        if (percent < 0.25) {
            return 1
        } else if (percent < 0.5) {
            return 2
        } else if (percent < 0.75) {
            return 3
        } else if (percent <= 1) {
            return 4
        } else {
            return -1
        }
    }
}
