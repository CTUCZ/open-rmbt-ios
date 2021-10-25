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

final class MapMeasurementRequest: BasicRequest {
    var size = "40"
    var coords: CoordObject?

    override func mapping(map: Map) {
        super.mapping(map: map)

        size            <- map["size"]
        coords          <- map["coords"]
    }

    internal class CoordObject: Mappable {
        var latitude: Double?
        var longitude: Double?
        var zoom: Int?

        init() { }

        required internal init?(map: Map) { }

        internal func mapping(map: Map) {
            latitude    <- map["lat"]
            longitude   <- map["lon"]
            zoom        <- map["z"]
        }
    }
}
