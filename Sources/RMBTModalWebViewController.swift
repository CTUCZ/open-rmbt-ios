//
//  RMBTModalWebViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 26.07.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit
import SVWebViewController

class RMBTModalWebViewController: SVModalWebViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithTransparentBackground()
            navigationBarAppearance.backgroundColor = .white
            navigationBarAppearance.titleTextAttributes = [
                .foregroundColor: UIColor(red: 66.0/255.0, green: 66.0/255.0, blue: 66.0/255.0, alpha: 1.0),
                .font: UIFont.roboto(size: 20, weight: .medium)
            ]
            
            self.navigationBar.standardAppearance = navigationBarAppearance
            self.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        }
    }
}
