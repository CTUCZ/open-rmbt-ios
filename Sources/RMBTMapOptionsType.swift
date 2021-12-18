//
//  RMBTMapOptionsType.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 18.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

// Type = mobile|cell|browser
class RMBTMapOptionsType: NSObject {

    private(set) var title: String? // localized
    private(set) var identifier: String = "" // mobile|cell|browser
    private(set) var filters: [RMBTMapOptionsFilter] = []
    private(set) var subtypes: [RMBTMapOptionsSubtype] = []
    
    init(response: [String: Any]) {
        super.init()
        self.title = response["title"] as? String
        
        var subtypes: [RMBTMapOptionsSubtype] = []
        if let options = response["options"] as? [[String: Any]] {
            for subresponse in options {
                let subtype = RMBTMapOptionsSubtype(response: subresponse)
                subtype.type = self
                subtypes.append(subtype)
                
                let pathComponents = subtype.mapOptions.components(separatedBy: "/")
                if identifier == "" {
                    identifier = pathComponents[0]
                } else {
                    assert(identifier == pathComponents[0], "Subtype identifier invalid")
                }
            }
        }
        
        self.subtypes = subtypes
    }
    
    func add(_ filter: RMBTMapOptionsFilter) {
        filters.append(filter)
    }
    
    func paramsDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        for f in filters {
            f.activeValue?.info.forEach { item in
                dictionary[item.key] = item.value
            }
        }
        return dictionary
    }
    
}
