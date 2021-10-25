//
//  UIFont+Roboto.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 24.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation

extension UIFont {
    static func roboto(size: CGFloat, weight: Weight) -> UIFont {
        if weight == .medium {
            return UIFont(name: "Roboto-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        } else {
            return UIFont(name: "Roboto", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
}
