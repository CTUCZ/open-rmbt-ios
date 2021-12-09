//
//  RMBTQoSCCTest.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 09.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

enum Errors: Error {
    case badResponse
    case error(_ error: Error?)
}

// Superclass for all tests requiring a connection to the QoS control server (UDP, VoIP etc.)
@objc class RMBTQoSCCTest: RMBTQoSTest {

    private(set) var controlConnectionParams: RMBTQoSControlConnectionParams?
    private var controlConnection: RMBTQoSControlConnection?
    
    override init?(with params: [String : Any]) {
        super.init(with: params)
        
        guard let server = params["server_addr"] as? String,
              let port  = params["server_port"] as? UInt
        else { return nil }
        controlConnectionParams = RMBTQoSControlConnectionParams(with: server, port: port)
    }
    
    func setControlConnection(_ connection: RMBTQoSControlConnection) {
        controlConnection = connection;
    }
    
    func send(command line: String, readReply: Bool) throws -> String {
        assert(controlConnection != nil)

        let sem = DispatchSemaphore(value: 0)
        
        var result: Any?
        var resultError: Error?
        //[NSString stringWithFormat:@"%@ +ID%@", line, self.uid]
        controlConnection?.sendCommand(line, readReply: readReply, success: { response in
            result = response
            sem.signal()
        }, error: { error, info in
            resultError = error
            sem.signal()
        })
        
        _ = sem.wait(timeout: .distantFuture)
        
        if resultError != nil {
            throw Errors.error(resultError)
        }
        if let r = result as? String {
            return r
        } else {
            throw Errors.badResponse
        }
    }

    func uuidFromToken() -> String? {
        assert(controlConnection?.token != nil)
        return controlConnection?.token?.components(separatedBy: "_")[0]
    }
    
}


//
//@interface RMBTQoSControlConnectionParams()
//@property (nonatomic, readwrite, copy) NSString *serverAddress;
//@property (nonatomic, readwrite) NSUInteger port;
//@end
