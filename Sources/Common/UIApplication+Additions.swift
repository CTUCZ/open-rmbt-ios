//
//  UIApplication+Additions.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 23.10.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    var currentOrientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation ?? .portrait
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    var windowSize: CGSize {
        if #available(iOS 13.0, *) {
            if #available(iOS 15.0, *) {
                return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.bounds.size ?? CGSize()
            } else {
                return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds.size ?? CGSize()
            }
        } else {
            return UIApplication.shared.keyWindow?.bounds.size ?? CGSize()
        }
    }
}
