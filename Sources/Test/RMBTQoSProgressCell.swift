//
//  RMBTQoSProgressCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTQoSProgressCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    var percentView = RMBTHistoryResultPercentView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.percentView.templateImage = UIImage(named: "traffic_lights_small_template")?.withRenderingMode(.alwaysTemplate)
        self.percentView.isHidden = false
        self.percentView.unfilledColor = UIColor.white.withAlphaComponent(0.4)
        self.percentView.filledColor = UIColor.white.withAlphaComponent(1.0)
        
        self.contentView.addSubview(self.percentView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.percentView.percents = 0.0;
    }

   
    override func layoutSubviews() {
        super.layoutSubviews()
    
        if percentView.isHidden == false {
            let padding = 20.0
            let width = 95.0
            let height = 11.0
            
            percentView.frame = CGRect(x: self.bounds.size.width - width - padding,
                                       y: (self.bounds.size.height - height) / 2,
                                       width: width,
                                       height: height)
            
            let widthWithPadding = percentView.frame.size.width + 20.0
            guard let label = self.detailTextLabel else { return }
            label.frameRight -= widthWithPadding - 10.0
        }
    }
}
