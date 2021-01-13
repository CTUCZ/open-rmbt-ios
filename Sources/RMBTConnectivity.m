/*
 * Copyright 2013 appscape gmbh
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
 *
 */

#import <SystemConfiguration/CaptiveNetwork.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if_var.h>

#import "RMBTConnectivity.h"

@interface RMBTConnectivity()
@property (nonatomic, readonly) NSString *bssid;
@property (nonatomic, readonly) NSNumber *cellularCode;
@property (nonatomic, readonly) NSString *cellularCodeDescription;
//@property (nonatomic, readonly) NSString *cellularCodeGenerationString;
@property (nonatomic, readonly) NSString *telephonyNetworkSimOperator;
@property (nonatomic, readonly) NSString *telephonyNetworkSimCountry;
@property (nonatomic, readonly) BOOL dualSim;
@end

@implementation RMBTConnectivity

- (instancetype)initWithNetworkType:(RMBTNetworkType)networkType {
    if (self = [super init]) {
        _networkType = networkType;
        _timestamp = [NSDate date];
        [self getNetworkDetails];
    }
    return self;
}

- (NSString*)networkTypeDescription {
    switch (_networkType) {
        case RMBTNetworkTypeNone:
            return @"Not connected";
        case RMBTNetworkTypeWiFi:
            return @"Wi-Fi";
        case RMBTNetworkTypeCellular:
            if (_cellularCodeDescription) {
                return _cellularCodeDescription;
            } else {
                return @"Cellular";
            }
        default:
            NSLog(@"Invalid network type %ld", (long)_networkType);
            return @"Unknown";
    }
}

#pragma mark - Internal

- (void)getNetworkDetails {
    _networkName = nil;
    _bssid = nil;
    _cellularCode = nil;
    _cellularCodeDescription = nil;
    _dualSim = NO;
    
    switch (_networkType) {
        case RMBTNetworkTypeCellular: {
            // Get carrier name
            CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
            CTCarrier *carrier = nil;
            _dualSim = NO;
            
            //use new methods on iOS12, as subscriberCellularProvider is deprecated
            if (@available(iOS 12.1, *)) {
                //iOS 12: This is now deprecated, as it could esims are not
                //detected using this
                NSDictionary *carrierDict = netinfo.serviceSubscriberCellularProviders;
                if (carrierDict != nil) {
                    NSArray *allCarriers = carrierDict.allValues;
                    if (allCarriers.count == 1) {
                        //one SIM card - default case for now, use this
                        carrier = allCarriers[0];
                    }
                    else if (allCarriers.count > 1) { //iPhone 12 return 2 dictionaries. 1 for primary sim, 2 for eSim, but with empty values. We try find first with any carrier name. In the future we have to improve this code
                        //dual SIM, we cannot handle this at the moment
                        _dualSim = YES;
                        for (CTCarrier *c in allCarriers) {
                            if ((c.carrierName != nil) && (c.carrierName.length > 0)) {
                                carrier = c;
                            }
                        }
                    }
                    else {
                        //no SIM inserted
                    }
                }
            }
            else {
                carrier = [netinfo subscriberCellularProvider];
            }
            
            if (carrier) {
                _networkName = carrier.carrierName;
                _telephonyNetworkSimCountry = carrier.isoCountryCode;
                _telephonyNetworkSimOperator = [NSString stringWithFormat:@"%@-%@", carrier.mobileCountryCode, carrier.mobileNetworkCode];
            }
            
            if ([netinfo respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)] ||
                [netinfo respondsToSelector:@selector(currentRadioAccessTechnology)]) {
//                _cellularCodeGenerationString = [self cellularCodeGenerationString:netinfo.currentRadioAccessTechnology];
                
                //iOS12
                if (@available(iOS 12.1, *)) {
                    if ([netinfo respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)]) {
                        NSDictionary *accessDict = netinfo.serviceCurrentRadioAccessTechnology;
                       
                        //set cellular type for phones with one SIM card
                        if (accessDict != nil && accessDict.count == 1) {
                            NSString* currentAccessTechnology = accessDict.allValues[0];
                            _cellularCode = [self cellularCodeForCTValue:currentAccessTechnology];
                            _cellularCodeDescription = [self cellularCodeDescriptionForCTValue:currentAccessTechnology];
                        }
                    }
                }
                else {
                    // iOS7
                    _cellularCode = [self cellularCodeForCTValue:netinfo.currentRadioAccessTechnology];
                    _cellularCodeDescription = [self cellularCodeDescriptionForCTValue:netinfo.currentRadioAccessTechnology];
                }
            }

            break;
        }
            
        case RMBTNetworkTypeWiFi: {
            // If WLAN, then show SSID as network name. Fetching SSID does not work on the simulator.
            NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
            for (NSString *ifnam in ifs) {
                NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
                if (info) {
                    if (info[(NSString*)kCNNetworkInfoKeySSID]) _networkName = info[(NSString*)kCNNetworkInfoKeySSID];
                    if (info[(NSString*)kCNNetworkInfoKeyBSSID]) _bssid = RMBTReformatHexIdentifier(info[(NSString*)kCNNetworkInfoKeyBSSID]);
                    break;
                }
            }
            break;
        }
        case RMBTNetworkTypeNone:
            break;
        default:
            NSAssert1(false, @"Invalid network type %ld", (long)_networkType);
    }
}


- (NSNumber*)cellularCodeForCTValue:(NSString*)value {
    static NSDictionary *lookup = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *_lookup = [NSMutableDictionary dictionaryWithDictionary:@{
            CTRadioAccessTechnologyGPRS:         @(1),
            CTRadioAccessTechnologyEdge:         @(2),
            CTRadioAccessTechnologyWCDMA:        @(3),
            CTRadioAccessTechnologyCDMA1x:       @(4),
            CTRadioAccessTechnologyCDMAEVDORev0: @(5),
            CTRadioAccessTechnologyCDMAEVDORevA: @(6),
            CTRadioAccessTechnologyHSDPA:        @(8),
            CTRadioAccessTechnologyHSUPA:        @(9),
            CTRadioAccessTechnologyCDMAEVDORevB: @(12),
            CTRadioAccessTechnologyLTE:          @(13),
            CTRadioAccessTechnologyeHRPD:        @(14),
        }];
        if (@available(iOS 14.0, *)) {
            _lookup[CTRadioAccessTechnologyNRNSA] = @(41);
            _lookup[CTRadioAccessTechnologyNR] = @(20);
        }
        
        lookup = _lookup;
    });
    return lookup[value];
}

- (NSString*)cellularCodeDescriptionForCTValue:(NSString*)value {
    static NSDictionary *lookup = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *_lookup = [NSMutableDictionary dictionaryWithDictionary:@{
            CTRadioAccessTechnologyGPRS:            @"GPRS (2G)",
            CTRadioAccessTechnologyEdge:            @"EDGE (2G)",
            CTRadioAccessTechnologyWCDMA:           @"UMTS (3G)",
            CTRadioAccessTechnologyCDMA1x:          @"CDMA (2G)",
            CTRadioAccessTechnologyCDMAEVDORev0:    @"EVDO0 (2G)",
            CTRadioAccessTechnologyCDMAEVDORevA:    @"EVDOA (2G)",
            CTRadioAccessTechnologyHSDPA:           @"HSDPA (3G)",
            CTRadioAccessTechnologyHSUPA:           @"HSUPA (3G)",
            CTRadioAccessTechnologyCDMAEVDORevB:    @"EVDOB (2G)",
            CTRadioAccessTechnologyLTE:             @"LTE (4G)",
            CTRadioAccessTechnologyeHRPD:           @"HRPD (2G)",
        }];
        if (@available(iOS 14.0, *)) {
            _lookup[CTRadioAccessTechnologyNRNSA] = @"NRNSA (5G)";
            _lookup[CTRadioAccessTechnologyNR] = @"NR (5G)";
        }
        
        lookup = _lookup;
    });
    return lookup[value];
}

//- (NSString*)cellularCodeGenerationString:(NSString*)value {
//    static NSDictionary *lookup = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSMutableDictionary *_lookup = [NSMutableDictionary dictionaryWithDictionary:@{
//            CTRadioAccessTechnologyGPRS:            @"2G",
//            CTRadioAccessTechnologyEdge:            @"2G",
//            CTRadioAccessTechnologyWCDMA:           @"3G",
//            CTRadioAccessTechnologyCDMA1x:          @"2G",
//            CTRadioAccessTechnologyCDMAEVDORev0:    @"2G",
//            CTRadioAccessTechnologyCDMAEVDORevA:    @"2G",
//            CTRadioAccessTechnologyHSDPA:           @"3G",
//            CTRadioAccessTechnologyHSUPA:           @"3G",
//            CTRadioAccessTechnologyCDMAEVDORevB:    @"2G",
//            CTRadioAccessTechnologyLTE:             @"4G",
//            CTRadioAccessTechnologyeHRPD:           @"2G",
//        }];
//        if (@available(iOS 14.0, *)) {
//            _lookup[CTRadioAccessTechnologyNRNSA] = @"5G";
//            _lookup[CTRadioAccessTechnologyNR] = @"5G";
//        }
//        
//        lookup = _lookup;
//    });
//    return lookup[value];
//}

- (NSDictionary*)testResultDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    NSInteger code = self.networkType;
    if (code > 0) result[@"network_type"] = [NSNumber numberWithInteger:code];

    if (self.networkType == RMBTNetworkTypeWiFi) {
        if (_networkName) result[@"wifi_ssid"] = _networkName;
        if (_bssid) result[@"wifi_bssid"] = _bssid;
    } else if (self.networkType == RMBTNetworkTypeCellular) {
        //TODO: Imrove this code. Sometimes iPhone 12 always send two dictionaries as dial sim. We take first where we have carrier name
        if (_dualSim) {
            result[@"dual_sim"] = @YES;
        }

        if (_cellularCode) {
            result[@"network_type"] = _cellularCode;
        }
        result[@"telephony_network_sim_operator_name"] = RMBTValueOrNull(self.networkName);
        result[@"telephony_network_sim_country"] = RMBTValueOrNull(_telephonyNetworkSimCountry);
        result[@"telephony_network_sim_operator"] = RMBTValueOrNull(_telephonyNetworkSimOperator);
        
    }
    return result;
}

- (BOOL)isEqualToConnectivity:(RMBTConnectivity*)other {
    if (other == self) return YES;
    if (!other) return NO;
    return (([other.networkTypeDescription isEqualToString:self.networkTypeDescription] &&
             other.dualSim && self.dualSim) ||
            ([other.networkTypeDescription isEqualToString:self.networkTypeDescription] && [other.networkName isEqualToString:self.networkName]));
}

#pragma mark - Interface values

- (RMBTConnectivityInterfaceInfo)getInterfaceInfo {
    RMBTConnectivityInterfaceInfo result = {0,0};

    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *stats;

    if (getifaddrs(&addrs) == 0) {
        cursor = addrs;
        while (cursor != NULL) {
            NSString *name=[NSString stringWithCString:cursor->ifa_name encoding:NSASCIIStringEncoding];
            // en0 is WiFi, pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK && (
                ([name hasPrefix:@"en"] && self.networkType == RMBTNetworkTypeWiFi) ||
                ([name hasPrefix:@"pdp_ip"] && self.networkType == RMBTNetworkTypeCellular)
            )) {
                stats = (const struct if_data *) cursor->ifa_data;
                result.bytesSent += stats->ifi_obytes;
                result.bytesReceived += stats->ifi_ibytes;
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return result;
}

#define WRAPPED_DIFF(x, y) ((y >= x) ? (y - x) : (((1LL << (sizeof(x) * 8)) - x)) + y)

+ (uint64_t)countTraffic:(RMBTConnectivityInterfaceInfoTraffic)traffic between:(RMBTConnectivityInterfaceInfo)info1 and:(RMBTConnectivityInterfaceInfo)info2 {
    uint64_t result = 0;
    if (traffic == RMBTConnectivityInterfaceInfoTrafficSent || traffic == RMBTConnectivityInterfaceInfoTrafficTotal) {
        result += WRAPPED_DIFF(info1.bytesSent, info2.bytesSent);
    }
    if (traffic == RMBTConnectivityInterfaceInfoTrafficReceived || traffic == RMBTConnectivityInterfaceInfoTrafficTotal) {
        result += WRAPPED_DIFF(info1.bytesReceived, info2.bytesReceived);
    }
    return result;
}

@end
