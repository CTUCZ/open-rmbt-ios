//
//  UIViewController+ModalBrowser.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 26.07.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

extension UIViewController {
    func openURL(_ url: URL?) {
        guard let url = url else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

private extension UIColor {
    static let tintColor = UIColor(named: "tintColor")
}
