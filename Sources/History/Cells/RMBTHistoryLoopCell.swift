//
//  RMBTHistoryLoopCell.swift
//  RMBT
//
//  Created by Polina Gurina on 12.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTHistoryLoopCell: UITableViewHeaderFooterView {
    static let ID = "RMBTHistoryLoopCell"
    
    var onExpand: (()->Void)?
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    lazy var topBorder: UIView = {
        let topBorder = UIView()
        topBorder.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        topBorder.frame = CGRect(x: 0, y: 0, width: frame.width, height: 1)
        return topBorder
    }()
    lazy var bottomBorder: UIView = {
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        bottomBorder.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1)
        return bottomBorder
    }()
    
    @IBAction func expand(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.expandButton.imageView!.transform = self.expandButton.imageView!.transform.rotated(by: .pi)
            self.layoutIfNeeded()
        }
        onExpand?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(topBorder)
        addSubview(bottomBorder)
    }
}
