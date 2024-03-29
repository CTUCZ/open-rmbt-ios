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
import CoreLocation

///
@objc public class GeoLocation: NSObject, Mappable {

    ///
    var latitude: Double?

    ///
    var longitude: Double?

    ///
    var accuracy: Double?

    ///
    var altitude: Double?

    ///
    var heading: Double?

    ///
    var speed: Double?

    ///
    var provider: String?

    ///
    var relativeTimeNs: Int?

    /// NKOM uses  Date, the old solution NSNumber
    var time: Int? // Date? //

    ///
    override init() { }

    ///
    @objc init(location: CLLocation) {
        latitude        = location.coordinate.latitude
        longitude       = location.coordinate.longitude
        accuracy        = location.horizontalAccuracy
        altitude        = location.altitude

        #if os(iOS)
        heading         = location.course
        speed           = (location.speed > 0.0 ? location.speed : 0.0)
        provider        = "GPS"
        #else
        provider        = "WLAN"
        #endif

        relativeTimeNs  = 0 // TODO?
//        time            = location.timestamp
        
        // TODO: Maybe need remove it
        time = RMBTHelpers.RMBTTimestamp(with: location.timestamp)
    }

    ///
    required public init?(map: Map) { }

    ///
    public func mapping(map: Map) {
        // TODO: Maybe need remove it and choose one
//        if !RMBTConfig.shared.RMBT_VERSION_NEW {
            latitude        <- map["geo_lat"]
            longitude       <- map["geo_long"]
            accuracy        <- map["accuracy"]
            altitude        <- map["altitude"]
            heading         <- map["heading"]
            speed           <- map["speed"]
            provider        <- map["provider"]
            time            <- map["tstamp"]
            relativeTimeNs  <- map["time_ns"]
            
//            latitude        <- map["lat"]
//            longitude       <- map["long"]
//            accuracy        <- map["accuracy"]
//            altitude        <- map["altitude"]
//            heading         <- map["heading"]
//            speed           <- map["speed"]
//            provider        <- map["provider"]
//            time            <- map["time"]
//            relativeTimeNs  <- map["time_ns"]
            
//        } else {
            latitude        <- map["latitude"]
            longitude       <- map["longitude"]
            accuracy        <- map["accuracy"]
            altitude        <- map["altitude"]
            heading         <- map["heading"]
            speed           <- map["speed"]
            provider        <- map["provider"]
            time            <- map["time"]
            relativeTimeNs  <- map["relative_time_ns"]
//        }
    }
}
