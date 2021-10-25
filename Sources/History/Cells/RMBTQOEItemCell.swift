//
//  RMBTQOEItemCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTQOEItemCell: UITableViewCell {

    static let ID = "RMBTQOEItemCell"
    
    @IBOutlet weak var percentViewContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qoeImageView: UIImageView!
    
    lazy var percentView: RMBTHistoryResultPercentView = {
        let view = RMBTHistoryResultPercentView()
        view.unfilledColor = UIColor.rmbt_color(withRGBHex: 0xf2f2f2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var item: RMBTHistoryQOEResultItem? {
        didSet {
            guard let item = item else { return }
            self.titleLabel.text = self.categoryName(with: item.category)
            self.qoeImageView.image = self.categoryImage(with: item.category)
                
            if (item.classification != -1) {
                let color = self.classificationColor(for: item.classification)
                percentView.percents = CGFloat(Double(item.quality) ?? 0.0)
                percentView.filledColor = color ?? UIColor.white
                percentView.setNeedsDisplay()
            }
            
            self.selectionStyle = .none
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.percentViewContainer.addSubview(percentView)
        NSLayoutConstraint.activate([
            self.percentViewContainer.leftAnchor.constraint(equalTo: percentView.leftAnchor),
            self.percentViewContainer.rightAnchor.constraint(equalTo: percentView.rightAnchor),
            self.percentViewContainer.topAnchor.constraint(equalTo: percentView.topAnchor),
            self.percentViewContainer.bottomAnchor.constraint(equalTo: percentView.bottomAnchor)
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func categoryName(with identifier: String) -> String {
        return NSLocalizedString(identifier, comment: "")
    }
    
    func categoryImage(with identifier: String) -> UIImage? {
        var image: UIImage?
        if (identifier == "streaming_audio_streaming") {
            image = UIImage(named: "ic_qoe_music")
        } else if (identifier == "video_sd") {
            image = UIImage(named: "ic_qoe_video")
        } else if (identifier == "video_hd") {
            image = UIImage(named: "ic_qoe_video")
        } else if (identifier == "video_uhd") {
            image = UIImage(named: "ic_qoe_video")
        } else if (identifier == "gaming") {
            image = UIImage(named: "ic_qoe_game")
        } else if (identifier == "gaming_download") {
            image = UIImage(named: "ic_qoe_game")
        } else if (identifier == "gaming_cloud") {
            image = UIImage(named: "ic_qoe_game")
        } else if (identifier == "gaming_streaming") {
            image = UIImage(named: "ic_qoe_game")
        } else if (identifier == "voip") {
            image = UIImage(named: "ic_qoe_voip")
        } else if (identifier == "voip") {
            image = UIImage(named: "ic_qoe_voip")
        } else if (identifier == "video_telephony") {
            image = UIImage(named: "ic_qoe_voip")
        } else if (identifier == "video_conferencing") {
            image = UIImage(named: "ic_qoe_voip")
        } else if (identifier == "messaging") {
            image = UIImage(named: "ic_qoe_image")
        } else if (identifier == "web") {
            image = UIImage(named: "ic_qoe_image")
        } else if (identifier == "cloud") {
            image = UIImage(named: "ic_qoe_image")
        } else if (identifier == "qos") {
            image = UIImage(named: "ic_qoe")
        }
        
        return image;
    }

    func classificationColor(for classification: NSInteger) -> UIColor? {
        var color: UIColor?
        if (classification == 1) {
            color = UIColor.rmbt_color(withRGBHex:0xfc441e)
        } else if (classification == 2) {
            color = UIColor.rmbt_color(withRGBHex:0xddde2f)
        } else if (classification == 3) {
            color = UIColor.rmbt_color(withRGBHex:0x3cc828)
        } else if (classification == 4) {
            color = UIColor.rmbt_color(withRGBHex:0x2c941c)
        } else {
            color = UIColor.clear
        }
        
        return color
    }

}
