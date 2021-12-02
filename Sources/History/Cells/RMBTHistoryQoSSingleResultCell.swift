//
//  RMBTHistoryQoSSingleResultCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 16.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTHistoryQoSSingleResultCell: UITableViewCell {

    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var successIcon: UIImageView!
    @IBOutlet weak var failureIcon: UIImageView!

    public func set(result: RMBTHistoryQoSSingleResult, sequenceNumber: UInt) {
        summaryLabel.text = "#\(sequenceNumber) \(result.summary ?? "")"
        successIcon.isHidden = !result.successful
        failureIcon.isHidden = result.successful
    }
}
