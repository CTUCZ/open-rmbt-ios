//
//  RMBTNetInfoItemtCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTNetInfoItemtCell: UITableViewCell {

    static let ID = "RMBTNetInfoItemtCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var item: RMBTHistoryResultItem? {
        didSet {
            self.titleLabel.text = self.item?.title
            self.subtitleLabel.text = self.item?.value

            self.selectionStyle = .none
        }
    }
    
}
