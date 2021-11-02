//
//  RMBTConfig.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 04.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation

/// default qos socket character encoding
let QOS_SOCKET_DEFAULT_CHARACTER_ENCODING: UInt = String.Encoding.utf8.rawValue

public let DEFAULT_LANGUAGE = "en"
public let PREFFERED_LANGUAGE = Bundle.main.preferredLocalizations.first ?? DEFAULT_LANGUAGE

public class RMBTConfig {
    public static let shared: RMBTConfig = {
        let config = RMBTConfig()
        LogConfig.initLoggingFramework()
        return config
    }()
    
    var RMBT_USE_MAIN_LANGUAGE: Bool { return false }
    var RMBT_MAIN_LANGUAGE: String { return "en" }
    
    let RMBT_DEFAULT_IS_CURRENT_COUNTRY: Bool = true
    
    var RMBT_CHECK_IPV4_URL: String {
        return "\(RMBT_IPV4_URL_HOST)\(RMBT_CONTROL_SERVER_PATH)/ip"
    }
    
    var RMBT_CONTROL_SERVER_URL: String {
        return "\(RMBT_URL_HOST)\(RMBT_CONTROL_SERVER_PATH)"
    }
    
    var RMBT_MAP_SERVER_URL: String { return "\(RMBT_URL_HOST)\(RMBT_MAP_SERVER_PATH)" }
    
    // Control server base URL used per default
    
    var RMBT_URL_HOST: String { return "https://example.org:8080" }
    // Control server base URL used when user has enabled the "IPv4-Only" setting
    var RMBT_IPV4_URL_HOST: String { return "https://example.org:8080" }
    // Ditto for the (debug) "IPv6-Only" setting
    var RMBT_IPV6_URL_HOST: String { return "https://example.org:8080" }
    var RMBT_CONTROL_SERVER_PATH: String { return "/RMBTControlServer" }
    var RMBT_MAP_SERVER_PATH: String { return "/RMBTMapServer" }
    
    //Colors
    let darkColor = UIColor.rmbt_color(withRGBHex: 0xFFFFFF)
    let tintColor = UIColor.rmbt_color(withRGBHex: 0x424242)
    
    let DEV_CODE = "any_code"
    
    let RMBT_TEST_LOOPMODE_MIN_COUNT = 1
    let RMBT_TEST_LOOPMODE_DEFAULT_COUNT = 10
    let RMBT_TEST_LOOPMODE_MAX_COUNT = 100

    // Loop mode will stop automatically after this many seconds:
    let RMBT_TEST_LOOPMODE_MAX_DURATION_S = (48*60*60) // 48 hours

    // Minimum/maximum number of minutes that user can choose to wait before next test is started:
    let RMBT_TEST_LOOPMODE_MIN_DELAY_MINS = 15
    let RMBT_TEST_LOOPMODE_DEFAULT_DELAY_MINS = 30
    let RMBT_TEST_LOOPMODE_MAX_DELAY_MINS = (24 * 60) // one day

    // ... meters user locations must change before next test is started:
    let RMBT_TEST_LOOPMODE_MIN_MOVEMENT_M = 50
    let RMBT_TEST_LOOPMODE_DEFAULT_MOVEMENT_M = 250
    let RMBT_TEST_LOOPMODE_MAX_MOVEMENT_M = 10000
}
