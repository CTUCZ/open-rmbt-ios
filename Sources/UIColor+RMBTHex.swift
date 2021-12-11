//
//  UIColor+RMBTHex.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static func rmbt_color(withRGBHex: UInt32) -> Self {
        return self.rmbt_color(withRGBHex: withRGBHex, alpha: 1.0)
    }
    
    static func rmbt_color(withRGBHex: UInt32, alpha: CGFloat) -> Self {
        let r = (withRGBHex >> 16) & 0xFF
        let g = (withRGBHex >> 8) & 0xFF
        let b = (withRGBHex) & 0xFF

        return UIColor(red: CGFloat(r) / 255.0,
                       green: CGFloat(g) / 255.0,
                       blue: CGFloat(b) / 255.0,
                       alpha: alpha) as! Self
    }
}
