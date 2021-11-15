//
//  UIView+XibLoadable.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 15.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation
import UIKit

protocol XibLoadable where Self: UIView {
}

extension XibLoadable {
    static var nibName: String { return String(describing: Self.self) }
    
    static func view() -> Self {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! Self
    }
}
