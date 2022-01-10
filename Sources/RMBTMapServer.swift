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
import CoreLocation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

///
@objc final public class RMBTMapServer: NSObject {

    ///
    @objc public static let shared = RMBTMapServer()

    ///
    private let alamofireManager: Alamofire.Session

    ///
    private let settings = RMBTSettings.shared

    ///
    private var baseUrl: String? {
        return RMBTControlServer.shared.mapServerURL?.absoluteString // don't store in variable, could be changed in settings
    }

    ///
    private override init() {
        alamofireManager = ServerHelper.configureAlamofireManager()
    }

    ///
    deinit {
        alamofireManager.session.invalidateAndCancel()
    }

// MARK: MapServer
    
    ///
    @objc public func getMapOptions(success successCallback: @escaping (_ response: MapOptionResponse) -> (), error failure: @escaping ErrorCallback) {
        let request = BasicRequest()
        BasicRequestBuilder.addBasicRequestValues(request)
        self.request(HTTPMethod.post, path: "/v2/tiles/info", requestObject: request, success: { (response: MapOptionResponse) in
            successCallback(response)
        } , error: failure)
    }

    ///
    @objc public func getMeasurementsAtCoordinate(_ coordinate: CLLocationCoordinate2D, zoom: Int, params: [String: Any], success successCallback: @escaping (_ response: [SpeedMeasurementResultResponse]) -> (), error failure: @escaping ErrorCallback) {

        let mapMeasurementRequest = MapMeasurementRequest()
        mapMeasurementRequest.coords = MapMeasurementRequest.CoordObject()
        mapMeasurementRequest.coords?.latitude = coordinate.latitude
        mapMeasurementRequest.coords?.longitude = coordinate.longitude
        mapMeasurementRequest.coords?.zoom = zoom

        // TODO: Check request and response
        request(.post, path: "/tiles/markers", requestObject: mapMeasurementRequest, success: { (response: MapMeasurementResponse) in
            if let measurements = response.measurements {
                successCallback(measurements)
            } else {
                failure(NSError(domain: "no measurements", code: -12543, userInfo: nil))
            }
        }, error: failure)
    }

    public func getTileUrlTemplate(_ overlayType: String, params: [String: Any]?) -> String? {
        guard let base = baseUrl else { return nil }
        // baseUrl and layer
        var urlString = base + "/tiles/\(overlayType)?path={z}/{x}/{y}"
        
        // add params
        if let p = params, p.count > 0 {
            let paramString = p.map({ (key, value) in
                let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                var escapedValue: String?
                if let v = value as? String {
                    escapedValue = v.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) // TODO: does this need a cast to string?
                } else if let numValue = value as? NSNumber {
                    escapedValue = String(describing: numValue)
                }

                return "\(escapedKey ?? key)=\(escapedValue ?? value as! String)"
            }).joined(separator: "&")

            urlString += "&" + paramString
        }

        Log.logger.debug("Generated tile url: \(urlString)")

        print(urlString)
        
        return urlString
    }
    
    @objc public func getTileUrlForMapOverlayType(_ overlayType: String, x: UInt, y: UInt, zoom: UInt, params: [String: Any]?) -> URL? {
        if let base = baseUrl {
            // baseUrl and layer
            var urlString = base + "/tiles/\(overlayType)?path=\(zoom)/\(x)/\(y)"

            // add params
            if let p = params, p.count > 0 {
                let paramString = p.map({ (key, value) in
                    let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                    var escapedValue: String?
                    if let v = value as? String {
                        escapedValue = v.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) // TODO: does this need a cast to string?
                    } else if let numValue = value as? NSNumber {
                        escapedValue = String(describing: numValue)
                    }

                    return "\(escapedKey ?? key)=\(escapedValue ?? value as! String)"
                }).joined(separator: "&")

                urlString += "&" + paramString
            }

            Log.logger.debug("Generated tile url: \(urlString)")

            print(urlString)
            
            return URL(string: urlString)
        }

        return nil
    }

    @objc(getURLStringForOpenTestUUID:success:) public func getOpenTestUrl(_ openTestUuid: String, success successCallback: @escaping (_ response: String?) -> ()) {
        if let url = RMBTControlServer.shared.openTestBaseURL {
            let theURL = url + openTestUuid
            successCallback(theURL)
        } else {
            RMBTControlServer.shared.getSettings {
                if let url = RMBTControlServer.shared.openTestBaseURL {
                    let theURL = url + openTestUuid
                    successCallback(theURL)
                }
            } error: { error in
                Log.logger.error(error)
                successCallback(nil)
            }
        }
    }

    private func request<T: BasicResponse>(_ method: Alamofire.HTTPMethod, path: String, requestObject: BasicRequest?, success: @escaping (_ response: T) -> (), error failure: @escaping ErrorCallback) {
        ServerHelper.request(alamofireManager, baseUrl: baseUrl, method: method, path: path, requestObject: requestObject, success: success, error: failure)
    }
}
