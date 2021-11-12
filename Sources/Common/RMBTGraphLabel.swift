//
//  RMBTGraphLabel.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTGraphLabel: UILabel {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setupUI() {
        self.font = UIFont.roboto(size: 11, weight: .regular)
    }
    
    init(text: String, textColor: UIColor) {
        self.init()
        self.textColor = textColor
        self.text = text
    }
}
