//
//  WKWebView+RMBTConfiguration.h
//  RMBT
//
//  Created by Sergey Glushchenko on 31.08.2020.
//  Copyright © 2020 appscape gmbh. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (RMBTConfiguration)

+(instancetype)wideWebViewWithFrame:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
