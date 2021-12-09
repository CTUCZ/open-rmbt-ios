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

public enum RMBTTestStatus: String {
    case None              = "NONE"
    case Aborted           = "ABORTED"
    case Error             = "ERROR"
    case ErrorFetching     = "ERROR_FETCH"
    case ErrorSubmitting   = "ERROR_SUBMIT"
    case ErrorBackgrounded = "ABORTED_BACKGROUNDED"
    case Ended             = "END"
}

///
class AbstractBasicRequestBuilder {

    ///
    class func addBasicRequestValues(_ basicRequest: BasicRequest) {
        let infoDictionary = Bundle.main.infoDictionary! // !

        if RMBTConfig.shared.RMBT_USE_MAIN_LANGUAGE == true {
            basicRequest.language = RMBTConfig.shared.RMBT_MAIN_LANGUAGE
        } else {
            basicRequest.language = PREFFERED_LANGUAGE
        }

        Log.logger.debug("ADDING PREVIOUS TEST STATUS: \(String(describing: RMBTSettings.shared.previousTestStatus))")

        basicRequest.previousTestStatus = RMBTSettings.shared.previousTestStatus ?? RMBTTestStatus.None.rawValue
        basicRequest.softwareRevision = RMBTHelpers.RMBTBuildInfoString()
        basicRequest.softwareVersion = infoDictionary["CFBundleShortVersionString"] as? String
        basicRequest.softwareVersionCode = infoDictionary["CFBundleVersion"] as? Int

        basicRequest.timezone = TimeZone.current.identifier
    }

}
