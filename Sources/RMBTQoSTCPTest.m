/*
 * Copyright 2017 appscape gmbh
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

#import "RMBTQoSTCPTest.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "RMBT-Swift.h"

@interface RMBTQoSTCPTest()<GCDAsyncSocketDelegate> {
    dispatch_semaphore_t _doneSem;
    NSString *_response;
}
@end

@implementation RMBTQoSTCPTest
-(instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super initWithParams:params]) {
        if (self.outPort > 0 && self.inPort == 0) {
            self.direction = RMBTQoSIPTestDirectionOut;
        } else if (self.inPort > 0 && self.outPort == 0) {
            self.direction = RMBTQoSIPTestDirectionIn;
        }
    }
    return self;
}

- (NSDictionary*)result {
    NSMutableDictionary *result = [@{@"tcp_objective_timeout": @(self.timeoutNanos)} mutableCopy];
    BOOL outgoing = (self.direction == RMBTQoSIPTestDirectionOut);

    if (outgoing) {
        [result addEntriesFromDictionary:@{
           @"tcp_result_out_response": RMBTValueOrNull(_response),
           @"tcp_objective_out_port": @(self.outPort),
           @"tcp_result_out": self.statusName
        }];
    } else {
        [result addEntriesFromDictionary:@{
           @"tcp_result_in_response": RMBTValueOrNull(_response),
           @"tcp_objective_in_port": @(self.inPort),
           @"tcp_result_in": self.statusName
       }];
    }

    return result;
}


- (void)ipMain:(BOOL)outgoing {
    NSUInteger port = outgoing ? self.outPort : self.inPort;

    NSError *error = nil;

    NSString *cmd = [NSString stringWithFormat:@"TCPTEST %@ %lu +ID%@", outgoing ? @"OUT" : @"IN",
                     (unsigned long)port,
                     self.uid];
    NSString *response1 = [self sendCommand:cmd readReply:outgoing ? YES : NO error:&error];
    if (error || (outgoing && ![response1 hasPrefix:@"OK"])) {
        [Log log:[NSString stringWithFormat:@"%@ failed: %@/%@", self, error, response1]];
        self.status = RMBTQoSTestStatusError;
        return;
    }

    dispatch_queue_t delegateQueue = dispatch_queue_create("at.rmbt.qos.tcp.delegate", DISPATCH_QUEUE_SERIAL);
    GCDAsyncSocket* socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:delegateQueue];

    if (outgoing) {
        [socket connectToHost:self.controlConnectionParams.serverAddress onPort:port withTimeout:self.timeoutSeconds error:&error];
    } else {
        [socket acceptOnPort:port error:&error];
    }

    if (error) {
        [Log log:[NSString stringWithFormat:@"%@ error connecting/binding: %@", self, error]];
        self.status = RMBTQoSTestStatusError;
        return;
    }

    _doneSem = dispatch_semaphore_create(0);
    if (dispatch_semaphore_wait(_doneSem, dispatch_time(DISPATCH_TIME_NOW, self.timeoutNanos)) != 0) {
        self.status = RMBTQoSTestStatusTimeout;
    } else if (_response && ![_response isEqualToString:@""]) {
        self.status = RMBTQoSTestStatusOk;
    }

    socket.delegate = nil;
    [socket disconnect];
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSParameterAssert(self.direction == RMBTQoSIPTestDirectionOut);
    [sock writeData:[@"PING\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:self.timeoutSeconds tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    [newSocket readDataToData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:self.timeoutSeconds tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    dispatch_semaphore_signal(_doneSem);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [sock readDataToData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:self.timeoutSeconds tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *line = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSParameterAssert(tag == 0);
    _response = [RMBTHelpers RMBTChomp:line];
    [sock disconnect];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"RMBTQoSTCPTest (uid=%@, cg=%ld, server=%@, out_port=%ld, in_port=%ld)",
            self.uid,
            (unsigned long)self.concurrencyGroup,
            self.controlConnectionParams,
            (unsigned long)self.outPort,
            (unsigned long)self.inPort
    ];
}

@end
