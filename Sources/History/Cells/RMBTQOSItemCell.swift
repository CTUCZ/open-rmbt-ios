//
//  RMBTQOSItemCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTQOSItemCell: UITableViewCell {

    static let ID = "RMBTQOSItemCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var item: RMBTHistoryQoSGroupResult? {
        didSet {
            guard let item = item else { return }
            let count = "\(item.succeededCount)/\(item.tests.count)"
            let name = item.name
            
            self.titleLabel.text = name
            self.subtitleLabel.text = count
        }
    }
    
}
