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
    
    @IBAction func expand(_ sender: UIButton) {
        expandButton.imageView!.transform = expandButton.imageView!.transform.rotated(by: .pi)
        onExpand?()
    }
}
