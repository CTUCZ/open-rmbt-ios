//
//  RMBTTOSViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 25.07.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit
import WebKit

class RMBTTOSViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var checkboxLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    
    @IBOutlet weak var toolBarView: UIView!

    @IBOutlet private weak var acceptIntroLabel: UILabel!
    
    @IBOutlet weak var scrollDownButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = self.navigationItem.title
        titleLabel.font = UIFont.roboto(size: 20, weight: .regular)
        titleLabel.textColor = UIColor(named: "titleNavigationBar")
        titleLabel.adjustsFontSizeToFitWidth = true
        return titleLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.modalPresentationCapturesStatusBarAppearance = true
        self.agreeButton.layer.cornerRadius = 8
        self.agreeButton.setTitle(.agree, for: .normal)
        self.declineButton.setTitle(.decline, for: .normal)
        self.checkboxLabel.text = .titleForSwitcher
        
        self.view.addSubview(webView)
        self.view.bringSubviewToFront(scrollDownButton)
        self.view.bringSubviewToFront(toolBarView)
        
        NSLayoutConstraint.activate([
            webView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        self.navigationItem.titleView = titleLabel
        
        guard let path = String.termsUrl else { return }
        let url = URL(fileURLWithPath: path)
        webView.load(URLRequest(url: url))
        webView.scrollView.delegate = self
        bottomConstraint.constant = -300
        
        self.updateAgreeButton()
    }
    
    @IBAction private func agree(_ sender: Any) {
        RMBTTOS.shared.acceptCurrentVersion()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func decline(_ sender: Any) {
        // quit app
        exit(EXIT_SUCCESS)
    }

    @IBAction func scrollDownButtonClick(_ sender: Any) {
        let bottom = self.view.safeAreaInsets.bottom
        let y = self.webView.scrollView.contentSize.height - self.webView.scrollView.bounds.height + self.toolBarView.frame.height + bottom
        let point = CGPoint(x: 0, y: y)
        self.webView.scrollView.setContentOffset(point, animated: true)
    }
    
    @IBAction func switcherChanged(_ sender: Any) {
        self.updateAgreeButton()
    }
    
    private func updateAgreeButton() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState) {
            self.agreeButton.alpha = self.switcher.isOn ? 1.0 : 0.3
            self.agreeButton.isEnabled = self.switcher.isOn
        } completion: { _ in }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var contentInset = self.webView.scrollView.contentInset
        contentInset.bottom = self.toolBarView.frame.height
        self.webView.scrollView.contentInset = contentInset
    }
}

extension RMBTTOSViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?
        defer {
            decisionHandler(action ?? .cancel)
        }

        guard let url = navigationAction.request.url else { return }
        
        guard let scheme: String = url.scheme else {
            return
        }
        if scheme == "file" {
            action = .allow
        } else if scheme == "mailto" {
            // TODO: Open compose dialog
            action = .cancel
        } else {
            guard let urlString = navigationAction.request.url?.absoluteString else { return }
            self.presentModalBrowser(with: urlString)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
}

extension RMBTTOSViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottom = self.view.safeAreaInsets.bottom
        let offset = scrollView.contentSize.height + bottom - (scrollView.contentOffset.y + scrollView.bounds.height)
        let maxOffset = self.toolBarView.frame.size.height + bottom
        if offset < 0 {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState) {
                self.scrollDownButton.alpha = 0.0
            } completion: { _ in
                self.toolBarView.isUserInteractionEnabled = true
            }

            if offset < -maxOffset {
                self.bottomConstraint.constant = 0
            } else {
                self.bottomConstraint.constant = 0 - offset - maxOffset
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState) {
                self.scrollDownButton.alpha = 1.0
                self.toolBarView.isUserInteractionEnabled = false
            } completion: { _ in }
            
            self.bottomConstraint.constant = -maxOffset
        }
    }
}

private extension String {
    static let termsUrl = Bundle.main.path(forResource: "terms_conditions_long", ofType: "html")
    static let agree = NSLocalizedString("tos.agree", comment: "")
    static let decline = NSLocalizedString("tos.decline", comment: "")
    static let titleForSwitcher = NSLocalizedString("tos.agreements.title", comment: "")
}
