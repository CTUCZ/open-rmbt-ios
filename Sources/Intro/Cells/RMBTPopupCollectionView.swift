//
//  RMBTPopupCollectionView.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.10.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTPopupCollectionView: UICollectionViewCell {
    public static let ID = "RMBTPopupCollectionView"
    
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!

    public var value: RMBTPopupInfo.Value? {
        didSet {
            self.titleLabel.text = value?.title
            self.valueLabel.text = value?.value
        }
    }
}
