//
//  RMBTIntroLandscapeView.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 23.10.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTIntroLandscapeView: RMBTIntroPortraitView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.waveView.mode = .vertical
        self.wave2View.mode = .vertical
        self.gradientView.direction = .leftRight
    }
}
