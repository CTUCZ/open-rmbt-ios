//
//  RMBTMapOptionsSubtype.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 18.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

// Subtype = type + up|down|signal etc. (depending on type)
class RMBTMapOptionsSubtype: NSObject {
    weak var type: RMBTMapOptionsType?
    private(set) var identifier: String?
    private(set) var title: String?
    private(set) var summary: String?
    private(set) var mapOptions: String = ""
    private(set) var overlayType: String?
    
    init(response: [String: Any]) {
        title = response["title"] as? String
        summary = response["summary"] as? String
        mapOptions = response["map_options"] as? String ?? ""
        overlayType = response["overlay_type"] as? String
        identifier = mapOptions
    }
    
    // TODO: move to map server it's responsibility of the api interface to build this params
    func paramsDictionary() -> [String: Any] {
        var result: [String: Any] = [:]
        result["map_options"] = mapOptions
        
        for f in self.type?.filters ?? [] {
            f.activeValue?.info.forEach { item in
                result[item.key] = item.value
            }
        }
        
        return result
    }
    
    func markerParamsDictionary() -> [String: Any] {
        var result: [String: Any] = [:]
        var mapOptions: [String: Any] = [:]
        mapOptions["map_options"] = self.mapOptions
        mapOptions["overlay_type"] = self.overlayType
        
        result["options"] = mapOptions
        
        var filterResult: [String: Any] = [:]
        
        for f in self.type?.filters ?? [] {
            f.activeValue?.info.forEach { item in
                filterResult[item.key] = item.value
            }
        }
        
        result["filter"] = filterResult
        
        return result
    }
    
}

