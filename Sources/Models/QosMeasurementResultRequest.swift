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
class QosMeasurementResultRequest: BasicRequest {
    var testToken: String?
    var qosResultList: [QOSTestResults]?

    @objc public convenience init(withJSON: [String: Any]) {
        self.init(JSON: withJSON)!
    }
    
    ///
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        testToken       <- map["test_token"]
        qosResultList   <- map["qos_result"]
    }
}
