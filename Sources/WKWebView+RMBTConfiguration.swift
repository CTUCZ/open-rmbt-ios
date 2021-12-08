//
//  WKWebView+RMBTConfiguration.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 08.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    static func configForWebView() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let jsString = "var meta = document.createElement('meta'); meta.setAttribute('name','viewport'); meta.setAttribute ('content', 'width=device-width'); document.getElementsByTagName ('head')[0].appendChild(meta);"
        let changeDefaultViewPort = WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(changeDefaultViewPort)
        return config
    }
   
    static func wideWebView(with frame: CGRect) -> Self {
        let config = self.configForWebView()
        let webView = WKWebView(frame: frame, configuration: config)
        return webView as! Self
    }
}
