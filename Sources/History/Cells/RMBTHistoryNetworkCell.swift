//
//  RMBTHistoryNetworkCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 09.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTHistoryNetworkCell: UITableViewCell {

    static let ID = "RMBTHistoryNetworkCell"
    
    @IBOutlet private weak var networkImageView: UIImageView!
    @IBOutlet private weak var networkNameLabel: UILabel!
    @IBOutlet private weak var networkTypeLabel: UILabel!
    
    var networkName: String? {
        didSet {
            self.networkNameLabel.text = networkName
        }
    }
    
    var networkType: String? {
        didSet {
            self.networkTypeLabel.text = networkType
            let networTypeIcon = RMBTNetworkTypeConstants.networkTypeDictionary[networkType ?? ""]?.icon
            networkImageView.image = networTypeIcon
        }
    }
    
}
