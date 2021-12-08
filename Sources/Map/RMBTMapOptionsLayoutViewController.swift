//
//  RMBTMapOptions2LayoutViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 19.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTMapOptionsLayoutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonClick(_:))))
    }
    
    @objc func backButtonClick(_ sender: Any) {
//        self.performSegue(withIdentifier: "presentOptions", sender: self)
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    var constraint: NSLayoutConstraint?
}

protocol RMBTBottomCardProtocol {
    var contentSize: CGSize { get }
}

extension RMBTMapOptionsLayoutViewController: RMBTBottomCardProtocol {
    var contentSize: CGSize { return CGSize(width: 0, height: 600) }
}
