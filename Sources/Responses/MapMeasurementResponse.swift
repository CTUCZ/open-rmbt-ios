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
@objc final class HistoryMeasurementResponse: BasicResponse {

    @objc func json() -> [String: Any] {
        return self.toJSON()
    }
    ///
    @objc var measurements: [SpeedMeasurementResultResponse]?

    ///
    override public func mapping(map: Map) {
        super.mapping(map: map)

        measurements <- map["testresult"]
    }
}

@objc final class MapMeasurementResponse: BasicResponse {

    @objc func json() -> [String: Any] {
        return self.toJSON()
    }
    ///
    @objc var measurements: [SpeedMeasurementResultResponse]?

    ///
    override public func mapping(map: Map) {
        super.mapping(map: map)

        measurements <- map["measurements"]
    }
}

@objc final class FullMapMeasurementResponse: BasicResponse {

    @objc func json() -> [String: Any] {
        return self.toJSON()
    }
    ///
    @objc var results: [[String: Any]] = []

    ///
    override public func mapping(map: Map) {
        super.mapping(map: map)

        results <- map["testresultdetail"]
    }
}
