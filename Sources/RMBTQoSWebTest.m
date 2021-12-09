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

#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "RMBTQoSWebTest.h"
#import "RMBTQosWebTestURLProtocol.h"
#import "RMBT-Swift.h"

@interface RMBTQoSWebTest()<WKNavigationDelegate> {
    NSString *_url;
    WKWebView *_webView;
    NSUInteger _requestCount;
    dispatch_semaphore_t _sem;
    uint64_t _startedAt, _duration;
    NSDictionary *_protocolResult;
    NSNumber *_rxBytesCount;
    NSNumber *_statusCode;
}
@end


@implementation RMBTQoSWebTest

-(instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super initWithParams:params]) {
        _url = [params valueForKey:@"url"];
    }
    return self;
}

- (NSDictionary*)result {
    return @{
        @"website_objective_url": _url,
        @"website_objective_timeout": @(self.timeoutNanos),
        @"website_result_info": [self statusName],
        @"website_result_duration": @(_duration),
        @"website_result_status": RMBTValueOrNull(_protocolResult[RMBTQosWebTestURLProtocolResultStatusKey]),
        @"website_result_rx_bytes": RMBTValueOrNull(_protocolResult[RMBTQosWebTestURLProtocolResultRxBytesKey]),
        @"website_result_tx_bytes": [NSNull null]
    };
}

- (void)main {
    _startedAt = 0;
    _statusCode = @(200);
    _rxBytesCount = @(0);
    _sem = dispatch_semaphore_create(0);

    dispatch_sync(dispatch_get_main_queue(), ^{
        //_webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 1900, 1200) configuration:[]
        _webView = [[WKWebView alloc] init];
        _webView.navigationDelegate = self;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
        [_webView loadRequest:request];
    });

    if (dispatch_semaphore_wait(_sem, dispatch_time(DISPATCH_TIME_NOW, self.timeoutNanos)) != 0) {
        self.status = RMBTQoSTestStatusTimeout;
    } else {
        self.status = RMBTQoSTestStatusOk;
        _duration = [RMBTHelpers RMBTCurrentNanos] - _startedAt;
    };

    _protocolResult = @{
        RMBTQosWebTestURLProtocolResultStatusKey: _statusCode,
        RMBTQosWebTestURLProtocolResultRxBytesKey: _rxBytesCount
    };
    
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_webView stopLoading];
    });
    _webView = nil;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"RMBTQoSWebTest (uid=%@, cg=%ld, url=%@)",
            self.uid,
            (unsigned long)self.concurrencyGroup,
            _url];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSParameterAssert(self.status == RMBTQoSTestStatusUnknown);
    if (_startedAt == 0) {
        _startedAt = [RMBTHelpers RMBTCurrentNanos];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    _requestCount += 1;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self maybeDone];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.status = RMBTQoSTestStatusError;
    [self maybeDone];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {

    NSString *currentURLString = navigationResponse.response.URL.absoluteString;
    
    //Small hack to check is equal urls or not.
    //Sometimes url can be with slash in the end and without slash and it's different url
    //Example: http://google.com/ and http://google.com is not equal because different slash
    //We remove all slashes from urls and http:google.com is equal http:google.com
    
    NSString *currentURLStringWithoutSlash = [currentURLString stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *_URLStringWithoutSlash = [_url stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([currentURLStringWithoutSlash isEqualToString:_URLStringWithoutSlash] &&
        [navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        _statusCode = @(((NSHTTPURLResponse *)navigationResponse.response).statusCode);
    }
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]] && navigationResponse.response.expectedContentLength != -1) {
        _rxBytesCount = @(_rxBytesCount.longLongValue + navigationResponse.response.expectedContentLength);
    }
          
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)maybeDone {
    if (self.status == RMBTQoSTestStatusTimeout) {
        // Already timed out
        return;
    }

    NSParameterAssert(_requestCount > 0);
    NSParameterAssert(_sem);

    _requestCount -= 1;

    if (_requestCount == 0) {
        dispatch_semaphore_signal(_sem);
    }
}

@end
