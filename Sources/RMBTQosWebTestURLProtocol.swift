//
//  RMBTQosWebTestURLProtocol.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 18.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

// Probably this class doesn't work
class RMBTQosWebTestURLProtocol: URLProtocol {
    enum RMBTQosWebTestURLProtocolKey: String {
        case tag = "tag"
        case status = "status"
        case rxBytes = "rx"
        case handled = "handled"
    }
    
    private var connection: NSURLConnection?
    
    static var results: [String: [String: Any]] = [:] // uid -> {url,status,rxbytes,txbytes}

    static func start() {
        assert(results.keys.count == 0)
        results = [:]
        URLProtocol.registerClass(RMBTQosWebTestURLProtocol.self)
    }
    
    static func stop() {
        URLProtocol.unregisterClass(RMBTQosWebTestURLProtocol.self)
        results = [:]
    }
    
    static func tag(request: NSMutableURLRequest, with value: String) {
        URLProtocol.setProperty(value, forKey: RMBTQosWebTestURLProtocolKey.tag.rawValue, in: request)
    }
    
    static func queryResult(with tag: String) -> [String: Any]? {
        return results[tag]
    }
    
    static override func canInit(with task: URLSessionTask) -> Bool {
        print("")
        return true
    }
    
    static override func canInit(with request: URLRequest) -> Bool {
        let tag = URLProtocol.property(forKey: RMBTQosWebTestURLProtocolKey.tag.rawValue, in: request) as? String ?? ""
        let handled = URLProtocol.property(forKey: RMBTQosWebTestURLProtocolKey.handled.rawValue, in: request) as? Bool ?? false

        let url = request.mainDocumentURL?.absoluteString ?? ""

        if handled {
            return false
        }

        if !tag.isEmpty {
            if (results[tag] != nil) {
                var entry: [String: Any] = [:]
                entry[RMBTQosWebTestURLProtocolResultKeys.status.rawValue] = -1
                entry[RMBTQosWebTestURLProtocolResultKeys.rxBytes.rawValue] = 0
                
                results[url] = entry
                results[tag] = entry
            }
            return true
        } else {
            let entry = results[url]
            return (entry != nil)
        }
    }
    
    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override var cachedResponse: CachedURLResponse? {
        return nil
    }
    
    static override func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
    override func stopLoading() {
        connection?.cancel()
    }

    override func startLoading() {
        var handledRequest = self.request
        URLProtocol.setProperty(true, forKey: RMBTQosWebTestURLProtocolKey.handled.rawValue, in: handledRequest as! NSMutableURLRequest)
        handledRequest.cachePolicy = .reloadIgnoringLocalCacheData
        connection = NSURLConnection(request: handledRequest, delegate: self)
    }
}

extension RMBTQosWebTestURLProtocol: NSURLConnectionDelegate {
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        if let currentURLString = connection.currentRequest.url?.absoluteString,
            currentURLString == connection.currentRequest.mainDocumentURL?.absoluteString,
            let response = response as? HTTPURLResponse {
            var entry = RMBTQosWebTestURLProtocol.results[currentURLString]
            assert(entry != nil)
            entry?[RMBTQosWebTestURLProtocolResultKeys.status.rawValue] = response.statusCode
        }
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    }

    func connection(_ connection: NSURLConnection, willSendRequest request: URLRequest, redirectResponse: URLResponse?) -> URLRequest? {
        if let response = redirectResponse {

            // Webview requests for page resources like images or stylesheets don't inherit NSURLProtocol properties
            // from the original request, so the only way to associate them with the webview is by comparing mainDocumentURL.
            //
            // For this reason, in the results dictionary we have the same entry under multiple keys (tag/uid as well as
            // mainDocumentURL).
            let url = connection.originalRequest.mainDocumentURL?.absoluteString ?? ""
            let entry = RMBTQosWebTestURLProtocol.results[url]
            if entry != nil {
                // Here we let the new URL also point to the same entry:
                RMBTQosWebTestURLProtocol.results[request.url?.absoluteString ?? ""] = entry
            }

            // We need to let webview know that the URL has been updated - so it can update its relative URLs.
            // However, webview will also start another request by itself, so we can return nil here to stop loading it ourselves.
            // The `request` is a copy of the original request, which means it will also have the NSURLProtocol property "handled"
            // set, which we need to unset and allow it to be handled by this protocol again.
            let unhandledRequest = request
            URLProtocol.removeProperty(forKey: RMBTQosWebTestURLProtocolKey.handled.rawValue, in: unhandledRequest as! NSMutableURLRequest)
            self.client?.urlProtocol(self, wasRedirectedTo: unhandledRequest, redirectResponse: response)
            connection.cancel()  // otherwise we receive didReceiveData: for the redirect page itself
            return nil
        }
        return request
    }
 
    func connection(_ connection: NSURLConnection, didReceiveData data: Data) {
        guard let url = connection.originalRequest.mainDocumentURL?.absoluteString else { return }
        var entry = RMBTQosWebTestURLProtocol.results[url]
        
        assert(entry != nil, "Expected entry for \( String(describing: connection.originalRequest.mainDocumentURL?.absoluteString))")
        let bytes = entry?[RMBTQosWebTestURLProtocolResultKeys.rxBytes.rawValue] as? Int ?? 0
        entry?[RMBTQosWebTestURLProtocolResultKeys.rxBytes.rawValue] = bytes + data.count
        self.client?.urlProtocol(self, didLoad: data)
        self.connection = nil
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        self.client?.urlProtocol(self, didFailWithError: error)
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        self.client?.urlProtocolDidFinishLoading(self)
    }
}
