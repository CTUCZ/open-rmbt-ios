//
//  RMBTTestParams.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 17.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

@objc final class RMBTTestParams: NSObject {

    @objc private(set) var clientRemoteIp: String?
    @objc private(set) var pingCount: UInt = 0
    @objc private(set) var pretestDuration: TimeInterval = 0
    @objc private(set) var pretestMinChunkCountForMultithreading: UInt = 0
    @objc private(set) var serverAddress: String?
    @objc private(set) var serverEncryption: Bool = false
    @objc private(set) var serverName: String?
    @objc private(set) var serverPort: UInt = 0
    
    // New protocol
    @objc private(set) var serverIsRmbtHTTP: Bool = false

    @objc private(set) var resultURLString: String?
    @objc private(set) var testDuration: TimeInterval = 0
    @objc private(set) var testToken: String?
    @objc private(set) var testUUID: String?
    @objc private(set) var threadCount: UInt = 0
    @objc private(set) var waitDuration: TimeInterval = 0
    @objc private(set) var resultQoSURLString: String?

    init?(with response: [String: Any]) {
        super.init()
        guard (response["test_server_address"] != nil) else {
            // Probably invalid server response, return nil
            return nil
        }
        
        clientRemoteIp = response["client_remote_ip"] as? String
        pingCount = UInt(RMBT_TEST_PING_COUNT)
        pretestDuration = RMBT_TEST_PRETEST_DURATION_S
        pretestMinChunkCountForMultithreading = UInt(RMBT_TEST_PRETEST_MIN_CHUNKS_FOR_MULTITHREADED_TEST)
        serverAddress = response["test_server_address"] as? String
        serverEncryption = response["test_server_encryption"] as? Bool ?? false
        serverName = response["test_server_name"] as? String

        serverIsRmbtHTTP = (response["test_server_type"] as? String) == "RMBThttp"

        // We use -integerValue as it's defined both on NSNumber and NSString, so we're more resilient in parsing:
        serverPort = UInt(response["test_server_port"] as? Int ?? 0)
        resultURLString = response["result_url"] as? String
        testDuration = response["test_duration"] as? TimeInterval ?? 0.0
        
        testToken = response["test_token"] as? String
        testUUID = response["test_uuid"] as? String
        if let testNumThreads = response["test_numthreads"] {
            if let numString = testNumThreads as? String,
               let num = UInt(numString) {
                threadCount = num
            } else if let num = testNumThreads as? UInt {
                threadCount = num
            }
        }
        
        waitDuration = response["test_wait"] as? TimeInterval ?? 0
        
        resultQoSURLString = response["result_qos_url"] as? String
        
        // Validation
        guard testDuration > 0 && testDuration <= 100
        else {
            Log.logger.error("Invalid test duration")
            return nil
        }
            
        guard threadCount > 0 && threadCount <= 120
        else {
            Log.logger.error("Invalid thread duration")
            return nil
        }

        if !(waitDuration > 0 && waitDuration <= 128) {
            Log.logger.error("Invalid wait duration")
        }
        
    }
}
