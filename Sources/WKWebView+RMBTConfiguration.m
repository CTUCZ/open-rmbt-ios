//
//  WKWebView+RMBTConfiguration.m
//  RMBT
//
//  Created by Sergey Glushchenko on 31.08.2020.
//  Copyright © 2020 appscape gmbh. All rights reserved.
//

#import "WKWebView+RMBTConfiguration.h"

@implementation WKWebView (RMBTConfiguration)

+(WKWebViewConfiguration *)configForWebView {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    NSString *jsString = @"var meta = document.createElement('meta'); meta.setAttribute('name','viewport'); meta.setAttribute ('content', 'width=device-width'); document.getElementsByTagName ('head')[0].appendChild(meta);";
    WKUserScript *changeDefaultViewPort = [[WKUserScript alloc] initWithSource:jsString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
    [[config userContentController] addUserScript:changeDefaultViewPort];
    
    return config;
}

+(instancetype)wideWebViewWithFrame:(CGRect)rect {
    WKWebViewConfiguration *config = [self configForWebView];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:rect configuration:config];
    return webView;
}
@end
