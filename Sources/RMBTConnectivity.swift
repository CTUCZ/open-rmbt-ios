//
//  RMBTConnectivity.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 21.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit
import CoreTelephony
import SystemConfiguration.CaptiveNetwork

enum RMBTNetworkType: Int {
    case unknown  = -1
    case none     = 0 // Used internally to denote no connection
    case browser  = 98
    case wifi     = 99
    case cellular = 105
}

enum RMBTConnectivityInterfaceInfoTraffic: UInt {
    case sent
    case received
    case total
}

struct RMBTConnectivityInterfaceInfo {
    var bytesReceived: UInt32
    var bytesSent: UInt32
}

class RMBTConnectivity: NSObject {
    private(set) var networkType: RMBTNetworkType = .none
    // Human readable description of the network type: Wi-Fi, Celullar
    private(set) var networkTypeDescription: String = ""
    
    // Carrier name for cellular, SSID for Wi-Fi
    private(set) var networkName: String?

    // Timestamp at which connectivity was detected
    private(set) var timestamp: Date = Date()

    private(set) var cellularCode: Int?
    private(set) var telephonyNetworkSimOperator: String?
    private(set) var telephonyNetworkSimCountry: String?
    
    private(set) var bssid: String?
    
    private var cellularCodeDescription: String?
//    private var cellularCodeGenerationString: String?
    
    private var dualSim: Bool = false
    
    init(networkType: RMBTNetworkType) {
        self.networkType = networkType
        super.init()
        self.getNetworkDetails()
    }
    
    func testResultDictionary() -> [String: Any] {
        var result: [String: Any] = [:]
        

        let code = self.networkType.rawValue
        if (code > 0) {
            result["network_type"] = code
        }

        if (self.networkType == .wifi) {
            result["wifi_ssid"] = networkName
            result["wifi_bssid"] = bssid
        } else if (self.networkType == .cellular) {
            //TODO: Imrove this code. Sometimes iPhone 12 always send two dictionaries as dial sim. We take first where we have carrier name
            if (dualSim) {
                result["dual_sim"] = true
            }

            result["network_type"] = cellularCode
            
            result["telephony_network_sim_operator_name"] = RMBTValueOrNull(networkName)
            result["telephony_network_sim_country"] = RMBTValueOrNull(telephonyNetworkSimCountry)
            result["telephony_network_sim_operator"] = RMBTValueOrNull(telephonyNetworkSimOperator)
            
        }
        return result
    }

    func isEqual(to connectivity: RMBTConnectivity?) -> Bool {
        if (connectivity == self) { return true }
        guard let connectivity = connectivity else {
            return false
        }

        return ((connectivity.networkTypeDescription == self.networkTypeDescription &&
                 connectivity.dualSim && self.dualSim) ||
                (connectivity.networkTypeDescription == self.networkTypeDescription && connectivity.networkName == self.networkName))
    }

    // Gets byte counts from the network interface used for the connectivity.
    // Note that the count refers to number of bytes since device boot.
    func getInterfaceInfo() -> RMBTConnectivityInterfaceInfo {
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        var stats: UnsafeMutablePointer<if_data>? = nil

        var bytesSent: UInt32 = 0
        var bytesReceived: UInt32 = 0
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                if let addr = ptr?.pointee.ifa_addr.pointee,
                    let value = ptr?.pointee.ifa_name {
                    if let name = String(cString: value, encoding: .ascii),
                        addr.sa_family == AF_LINK && (
                        (name.hasPrefix("en") && self.networkType == .wifi) ||
                        (name.hasPrefix("pdp_ip") && self.networkType == .cellular)
                    ) {
                        stats = unsafeBitCast(ptr?.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
                        bytesSent += stats?.pointee.ifi_obytes ?? 0
                        bytesReceived += stats?.pointee.ifi_ibytes ?? 0
                    }
                }
                ptr = ptr?.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        let result = RMBTConnectivityInterfaceInfo(bytesReceived: bytesReceived, bytesSent: bytesSent)
        return result
    }

    static private func WRAPPED_DIFF(_ x: UInt32, _ y: UInt32) -> UInt64 {
        if y > x {
            return UInt64(y - x)
        } else {
            let size = MemoryLayout.size(ofValue: x)
            let total: UInt64 = UInt64(1) << (size * 8)
            return total - UInt64(x) + UInt64(y)
        }
    }
    
    // Total (up+down) difference in bytes transferred between two readouts. If counter has wrapped returns 0.
    static func countTraffic(_ traffic: RMBTConnectivityInterfaceInfoTraffic, between info1: RMBTConnectivityInterfaceInfo, and info2: RMBTConnectivityInterfaceInfo) -> UInt64 {
        var result: UInt64 = 0
        if (traffic == .sent || traffic == .total) {
            result += WRAPPED_DIFF(info1.bytesSent, info2.bytesSent)
        }
        if (traffic == .received || traffic == .total) {
            result += WRAPPED_DIFF(info1.bytesReceived, info2.bytesReceived);
        }
        return result
    }
    
    fileprivate func updateCellularInfo() {
        let netinfo = CTTelephonyNetworkInfo()
        var carrier: CTCarrier?
        var radioAccessTechnology: String?
        
        if #available(iOS 13.0, *) {
            if let providers = netinfo.serviceSubscriberCellularProviders,
               let dataIndetifier = netinfo.dataServiceIdentifier {
                carrier = providers[dataIndetifier]
                radioAccessTechnology = netinfo.serviceCurrentRadioAccessTechnology?[dataIndetifier]
            }
        } else {
            carrier = netinfo.subscriberCellularProvider
            if netinfo.responds(to: #selector(getter: CTTelephonyNetworkInfo.currentRadioAccessTechnology)) {
                radioAccessTechnology = netinfo.currentRadioAccessTechnology
            }
        }
        if let carrier = carrier {
            if carrier.carrierName == "Carrier" {
                networkName = nil
            } else {
                networkName = carrier.carrierName
            }
            telephonyNetworkSimCountry = carrier.isoCountryCode
            telephonyNetworkSimOperator = String(format:"%@-%@", carrier.mobileCountryCode ?? "null", carrier.mobileNetworkCode ?? "null")
        }
        
        //Get access technology
        if let radioAccessTechnology = radioAccessTechnology {
            cellularCode = cellularCodeForCTValue(radioAccessTechnology)
            cellularCodeDescription = cellularCodeDescriptionForCTValue(radioAccessTechnology)
        }
    }
    
    private func getWiFiParameters() -> (ssid: String, bssid: String)? {
        if let interfaces = CNCopySupportedInterfaces() as? [CFString] {
            for interface in interfaces {
                if let interfaceData = CNCopyCurrentNetworkInfo(interface) as? [CFString: Any],
                let currentSSID = interfaceData[kCNNetworkInfoKeySSID] as? String,
                let currentBSSID = interfaceData[kCNNetworkInfoKeyBSSID] as? String {
                    return (ssid: currentSSID, bssid: RMBTReformatHexIdentifier(currentBSSID))
                }
            }
        }
        return nil
    }
    
    private func getNetworkDetails() {
        self.networkName = nil
        self.bssid = nil
        self.cellularCode = nil
        self.cellularCodeDescription = nil
        self.dualSim = false
        
        switch networkType {
        case .cellular: self.updateCellularInfo()
        case .wifi:
            // If WLAN, then show SSID as network name. Fetching SSID does not work on the simulator.
            if let wifiParams = getWiFiParameters() {
                networkName = wifiParams.ssid
                bssid = wifiParams.bssid
            }
        case .none: break
        default:
            assert(false, "Invalid network type \(networkType)")
        }
    }

    fileprivate func cellularCodeForCTValue(_ value: String?) -> Int? {
        guard let value = value else { return nil }

        return cellularCodeTable[value]
    }

    fileprivate var cellularCodeTable: [String: Int] {
        //https://specure.atlassian.net/wiki/spaces/NT/pages/144605185/Network+types
        var table = [
            CTRadioAccessTechnologyGPRS:         1,
            CTRadioAccessTechnologyEdge:         2,
            CTRadioAccessTechnologyWCDMA:        3,
            CTRadioAccessTechnologyCDMA1x:       4,
            CTRadioAccessTechnologyCDMAEVDORev0: 5,
            CTRadioAccessTechnologyCDMAEVDORevA: 6,
            CTRadioAccessTechnologyHSDPA:        8,
            CTRadioAccessTechnologyHSUPA:        9,
            CTRadioAccessTechnologyCDMAEVDORevB: 12,
            CTRadioAccessTechnologyLTE:          13,
            CTRadioAccessTechnologyeHRPD:        14
        ]
        
        if #available(iOS 14.1, *) {
            table[CTRadioAccessTechnologyNRNSA] = 41
            table[CTRadioAccessTechnologyNR] = 20
        }
        return table
    }

    fileprivate func cellularCodeDescriptionForCTValue(_ value: String!) -> String? {
        if value == nil {
            return nil
        }

        return cellularCodeDescriptionTable[value] ?? nil
    }

    fileprivate var cellularCodeDescriptionTable: [String: String] {
        var table = [
            CTRadioAccessTechnologyGPRS:            "2G (GSM)",
            CTRadioAccessTechnologyEdge:            "2G (EDGE)",
            CTRadioAccessTechnologyWCDMA:           "3G (UMTS)",
            CTRadioAccessTechnologyCDMA1x:          "2G (CDMA)",
            CTRadioAccessTechnologyCDMAEVDORev0:    "2G (EVDO_0)",
            CTRadioAccessTechnologyCDMAEVDORevA:    "2G (EVDO_A)",
            CTRadioAccessTechnologyHSDPA:           "3G (HSDPA)",
            CTRadioAccessTechnologyHSUPA:           "3G (HSUPA)",
            CTRadioAccessTechnologyCDMAEVDORevB:    "2G (EVDO_B)",
            CTRadioAccessTechnologyLTE:             "4G (LTE)",
            CTRadioAccessTechnologyeHRPD:           "2G (HRPD)",
        ]
        
        if #available(iOS 14.1, *) {
            table[CTRadioAccessTechnologyNRNSA] = "5G (NRNSA)"
            table[CTRadioAccessTechnologyNR] = "5G (NR)"
        }
        
        return table
    }
}
