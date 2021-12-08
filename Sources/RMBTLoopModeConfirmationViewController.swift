//
//  RMBTLoopModeConfirmationViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 08.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTLoopModeConfirmationViewController: UIViewController {
    private let acceptSegue = "accept"
    
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    lazy var webView: WKWebView = {
        let webView = WKWebView.wideWebView(with: self.view.bounds)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var isStep2 = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.acceptButton.setTitle(.accept, for: .normal)
        self.declineButton.setTitle(.decline, for: .normal)
        
        self.acceptButton.layer.cornerRadius = 8
        self.declineButton.layer.cornerRadius = 8
        self.createWebView()
        self.show()
    }
    
    private func createWebView() {
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.toolbar.topAnchor)
        ])
        
        self.view.bringSubviewToFront(toolbar)
    }


    private func show() {
        self.navigationController?.navigationBar.barStyle = .black
        
        self.navigationItem.prompt = nil
        self.navigationItem.title = .title1
        var html = "loop_mode_info"

        if isStep2 {
            self.navigationItem.title = .title2
            html = "loop_mode_info2"
        }

        guard let path = Bundle.main.path(forResource: html, ofType: "html") else { return }
        let url = URL(fileURLWithPath: path)
        self.webView.load(URLRequest(url: url))
    }
    
    @IBAction func accept(_ sender: Any) {
        if !isStep2 {
            isStep2 = true
            self.show()
        } else {
            self.performSegue(withIdentifier: acceptSegue, sender: self)
        }
    }
}

private extension String {
    static let accept = NSLocalizedString("text_button_accept", comment: "")
    static let decline = NSLocalizedString("text_button_decline", comment: "")
    
    static let title1 = NSLocalizedString("title_loop_instruction_1", comment: "Confirmation dialog title 1/2")
    static let title2 = NSLocalizedString("title_loop_instruction_2", comment: "Confirmation dialog title 2/2")
}
