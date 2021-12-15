//
//  RMBTHistoryQOEResultItem.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 14.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTHistoryQOEResultItem: NSObject {
    private(set) var category: String = ""
    private(set) var value: String?
    private(set) var quality: String = ""
    private(set) var classification: Int = -1
    
    init(with response: [String: Any]) {
        if let category = response["category"] as? String {
            self.category = category
        } else {
            assert(false, "category can't parse")
        }
            
        if let quality = (response["quality"] as? NSObject)?.description {
            self.quality = quality
        } else {
            assert(false, "quality can't parse")
        }
        
        if let classification = response["classification"] as? Int {
            self.classification = classification
        }
    }
    
    init(with category: String, quality: String, value: String, classification: Int) {
        self.category = category
        self.quality = quality
        self.value = value
        self.classification = classification
    }
}
