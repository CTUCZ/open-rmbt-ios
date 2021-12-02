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
                RMBTSettings.shared.isDevModeEnabled = !RMBTSettings.shared.isDevModeEnabled
                RMBTSettings.shared.debugUnlocked = RMBTSettings.shared.isDevModeEnabled
                RMBTSettings.shared.debugForceIPv6 = false
                self.tableView.reloadData()
            }
        }, textFieldConfiguration: nil)
    }
    
    @objc var closeBarButtonItem: UIBarButtonItem {
        let closeBarButtonItem = UIBarButtonItem(image: .closeImage, style: .done, target: self, action: #selector(closeButtonClick(_:)))
        return closeBarButtonItem
    }
    
    @objc func closeButtonClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func updateLogging() {
        LogConfig.enableLogging = RMBTSettings.shared.debugLoggingEnabled
    }
}

private extension UIImage {
    static let closeImage = UIImage(named: "black_close_button")
}
