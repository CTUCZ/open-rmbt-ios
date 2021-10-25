//
//  RMBTHistoryViewCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 06.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTHistoryViewCell: UICollectionViewCell {

    static let ID = "RMBTHistoryViewCell"
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        rootView.layer.cornerRadius = self.frame.height / 2.0
    }
}
