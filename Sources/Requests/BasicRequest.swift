/*****************************************************************************************************
 * Copyright 2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import Foundation
import ObjectMapper

///
public class BasicRequest: NSObject, Mappable {
    @objc var uuid:String?
    var loopUuid:String?

    var language: String? = RMBTHelpers.RMBTPreferredLanguage()
    
    var device: String?
    var model: String?
    var osVersion: String?

    var plattform: String? = "iOS"

    @objc var previousTestStatus: String?

    var timezone: String?
    
    var softwareVersion: String? // Application version
    var softwareRevision: String?
    var softwareVersionCode: Int?

    var name: String? = "RMBT"
    var client: String? = "RMBT"
    var clientName: String = "RMBT"
    var clientType: String? = "MOBILE"

    var capabilities: [String: Any] = [
        "classification": ["count": 4],
        "qos": [ "supports_info": true ],
        "RMBThttp": true
    ]
    
    var version: String = "0.3"
    var clientVersion: String? // Server side version
    
    override init() { }

    required public init?(map: Map) { }

    public func mapping(map: Map) {
        //
        uuid                <- map["uuid"]
        loopUuid            <- map["loop_uuid"]
        
        plattform           <- map["plattform"]
        plattform           <- map["platform"]
        osVersion           <- map["os_version"]
        model               <- map["model"]
        device              <- map["device"]
        language            <- map["language"]
        timezone            <- map["timezone"]
        name                <- map["name"]
        client              <- map["client"]
        clientVersion       <- map["client_version"]
        clientName          <- map["client_name"]
        language            <- map["client_language"]
        clientType          <- map["type"]
        version             <- map["version"]
        softwareVersion     <- map["client_software_version"]
        softwareVersion     <- map["softwareVersion"]
        softwareVersionCode <- map["softwareVersionCode"]
        softwareRevision    <- map["softwareRevision"]
        capabilities        <- map["capabilities"]
    }
}
