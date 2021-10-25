//
//  IpResponse.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 04.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation
import ObjectMapper

final public class IpResponse: BasicResponse {
    public var ip: String = ""
    public var version: String = ""

    override public func mapping(map: Map) {
        super.mapping(map: map)
        
        ip <- map["ip"]
        version <- map["v"]
    }
    
    override public var description: String {
        return "ip: \(ip), version: \(version)"
    }
}
