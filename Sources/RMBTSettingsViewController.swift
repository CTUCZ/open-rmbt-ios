//
//  RMBTSettingsViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 27.10.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation

extension RMBTSettingsViewController {
    @objc func tapHandler(_ sender: UIGestureRecognizer) {
        _ = UIAlertController.presentAlertDevCode(nil, codeAction: { (textField) in
            if textField.text == RMBTConfig.shared.DEV_CODE {
                RMBTSettings.shared.isDevModeEnabled = true
                RMBTSettings.shared.debugUnlocked = true
                self.tableView.reloadData()
            }
        }, textFieldConfiguration: nil)
    }
}
