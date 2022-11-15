//
//  UITabBarItem.swift
//  RMBT
//
//  Created by Polina Gurina on 15.11.22.
//  Copyright © 2022 appscape gmbh. All rights reserved.
//

import UIKit

extension UITabBarItem {
    @IBInspectable var localizableAccessibilityLabel: String? {
        get { return accessibilityLabel }
        set {
            accessibilityLabel = NSLocalizedString(newValue!, comment: "")
        }
    }
}
