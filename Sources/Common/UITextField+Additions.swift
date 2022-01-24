//
//  UITextField.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 24.01.2022.
//  Copyright © 2022 appscape gmbh. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func goToEndPosition() {
        let offset = 0
        if let position = self.position(from: self.endOfDocument, offset: offset) {
            self.selectedTextRange = self.textRange(from: position, to: position)
        }
    }
}
