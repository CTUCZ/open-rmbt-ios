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

#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "RMBTConnectivityTracker.h"
#import "RMBT-Swift.h"

// According to http://www.objc.io/issue-5/iOS7-hidden-gems-and-workarounds.html one should
// keep a reference to CTTelephonyNetworkInfo live if we want to receive radio changed notifications (?)
static CTTelephonyNetworkInfo *sharedNetworkInfo;

@interface RMBTConnectivityTracker() {
    __weak id<RMBTConnectivityTrackerDelegate> _delegate;
    dispatch_queue_t _queue;
    id _lastRadioAccessTechnology;
    RMBTConnectivity *_lastConnectivity;
    BOOL _stopOnMixed;
    BOOL _started;
}
@end

@implementation RMBTConnectivityTracker

- (instancetype)initWithDelegate:(id<RMBTConnectivityTrackerDelegate>)delegate stopOnMixed:(BOOL)stopOnMixed {
    if (self = [super init]) {
        _stopOnMixed = stopOnMixed;
        _delegate = delegate;
        _queue = dispatch_queue_create("at.rtr.rmbt.connectivitytracker", DISPATCH_QUEUE_SERIAL);
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        });
    }
    return self;
}

- (void)appWillEnterForeground:(NSNotification*)notification {
    dispatch_async(_queue, ^{
        // Restart various observartions and force update (if already started)
        if (_started) [self start];
    });
}

- (void)start {
    dispatch_async(_queue, ^{
        _started = YES;
        _lastRadioAccessTechnology = nil;

        // Re-Register for notifications
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];

        [NetworkReachability.shared addReachabilityCallback:^(NetworkReachabilityStatus status) {
            [self reachabilityDidChangeToStatus:status];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioDidChange:) name:CTServiceRadioAccessTechnologyDidChangeNotification object:nil];

        [self reachabilityDidChangeToStatus:NetworkReachability.shared.status];
    });
}

- (void)stop {
    dispatch_async(_queue, ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        _started = NO;
    });
}

- (void)forceUpdate {
//    if (_lastConnectivity == nil) { return; }
    dispatch_async(_queue, ^{
//        NSAssert(_lastConnectivity, @"Connectivity should be known by now");
        [self reachabilityDidChangeToStatus:NetworkReachability.shared.status];
        [_delegate connectivityTracker:self didDetectConnectivity:_lastConnectivity];
    });
}

- (void)radioDidChange:(NSNotification*)n {
    dispatch_async(_queue, ^{
        // Note:Sometimes iOS delivers multiple notification w/o radio technology actually changing
        if (n.object == _lastRadioAccessTechnology) return;
        _lastRadioAccessTechnology = n.object;
        [self reachabilityDidChangeToStatus:NetworkReachability.shared.status];
    });
}

- (void)reachabilityDidChangeToStatus:(NetworkReachabilityStatus)status {
    RMBTNetworkType networkType;
    switch (status) {
        case NetworkReachabilityStatusNotReachability:
        case NetworkReachabilityStatusUnknown:
            networkType = RMBTNetworkTypeNone;
            break;
        case NetworkReachabilityStatusWifi:
            networkType = RMBTNetworkTypeWiFi;
            break;
        case NetworkReachabilityStatusMobile:
            networkType = RMBTNetworkTypeCellular;
            break;
        default:
            // No assert here because simulator often returns unknown connectivity status
            [Log log:[NSString stringWithFormat:@"Unknown reachability status %d", status]];
            return;
    }

    if (networkType == RMBTNetworkTypeNone) {
        [Log log:@"No connectivity detected."];
        _lastConnectivity = nil;
        [_delegate connectivityTrackerDidDetectNoConnectivity:self];
        return;
    }

    RMBTConnectivity *connectivity = [[RMBTConnectivity alloc] initWithNetworkType:networkType];

    if ([connectivity isEqualToConnectivity:_lastConnectivity]) return;

    [Log log:[NSString stringWithFormat:@"New connectivity = %@", connectivity.testResultDictionary]];
    
    if (_stopOnMixed) {
        // Detect compatilibity
        BOOL compatible = YES;

        if (_lastConnectivity) {
            if (connectivity.networkType != _lastConnectivity.networkType) {
                [Log log:[NSString stringWithFormat:@"Connectivity network mismatched %@ -> %@", _lastConnectivity.networkTypeDescription, connectivity.networkTypeDescription]];
                compatible = NO;
            } else if ((![connectivity.networkName isEqualToString:_lastConnectivity.networkName]) && ((connectivity.networkName != nil) || (_lastConnectivity.networkName != nil))) {
                [Log log:[NSString stringWithFormat:@"Connectivity network name mismatched %@ -> %@", _lastConnectivity.networkName, connectivity.networkName]];
                compatible = NO;
            }
        }

        _lastConnectivity = connectivity;

        if (compatible) {
            [_delegate connectivityTracker:self didDetectConnectivity:connectivity];
        } else {
            // stop
            [self stop];
            [_delegate connectivityTracker:self didStopAndDetectIncompatibleConnectivity:connectivity];
        }
    } else {
        _lastConnectivity = connectivity;
        [_delegate connectivityTracker:self didDetectConnectivity:connectivity];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
