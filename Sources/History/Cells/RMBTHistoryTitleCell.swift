//
//  RMBTHistoryTitleCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTHistoryTitleCell: UITableViewCell {

    static let ID = "RMBTHistoryTitleCell"
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var textColor: UIColor? {
        didSet {
            titleLabel.textColor = textColor
        }
    }
    
    var font: UIFont? {
        didSet {
            titleLabel.font = font
        }
    }
    
}
