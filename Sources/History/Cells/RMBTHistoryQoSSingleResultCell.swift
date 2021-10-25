//
//  RMBTHistoryQoSSingleResultCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 16.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTHistoryQoSSingleResultCell: UITableViewCell {

    @IBOutlet weak var sequenceNumberLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var successImageView: UIImageView!

    public func set(result: RMBTHistoryQoSSingleResult?, sequenceNumber: UInt) {
        self.sequenceNumberLabel.text = "\(sequenceNumber)"
        self.summaryLabel.text = result?.summary
        self.successImageView.image = result?.statusIcon()
    }
}
