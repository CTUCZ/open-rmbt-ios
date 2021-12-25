//
//  RMBTStatsViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 25.07.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit
import SVWebViewController

class RMBTStatsWebViewController: SVWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isOpaque = false
        self.view.backgroundColor = UIColor.white
    }
}
    
final class RMBTStatsViewController: UINavigationController {

    private let unloadViewTimeout = 5.0
    
    override var prefersStatusBarHidden: Bool { return true }
    
    private var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tabBarItem.title = " "
        self.tabBarItem.image = .tabImage
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationBarHidden(true, animated: animated)
        
        if timer?.isValid == true {
            timer?.invalidate()
            timer = nil
        }
        
        if self.viewControllers.count == 0 {
            self.loadWebView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: unloadViewTimeout, repeats: false, block: { [weak self] _ in
            self?.unloadWebView()
        })
    }
    
    private func unloadWebView() {
        self.setViewControllers([], animated: false)
    }
    
    private func loadWebView() {
        guard let url = RMBTControlServer.shared.statsURL,
              let webView = RMBTStatsWebViewController(url: url)
        else { return }
        
        self.setViewControllers([webView], animated: false)
    }
}

private extension UIImage {
    static let tabImage = UIImage(named: "tab_stats")
}
