//
//  RMBTHistoryGraphCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 09.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTHistoryGraphCell: UICollectionViewCell {

    static let ID = "RMBTHistoryGraphCell"
    
    @IBOutlet weak var speedGraphView: RMBTHistorySpeedGraphView! {
        didSet {
            speedGraphView.labelsColor = UIColor.rmbt_color(withRGBHex: 0x424242, alpha: 0.56)
            speedGraphView.graphLinesColor = UIColor.rmbt_color(withRGBHex: 0xEEEEEE, alpha: 1.0)
        }
    }
    
    var graph: RMBTHistorySpeedGraph? {
        didSet {
            if let graph = graph {
                speedGraphView.clear()
                for p in graph.points {
                    speedGraphView.add(point: p)
                }
                
                self.speedGraphView.isHidden = false
            } else {
                self.speedGraphView.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        speedGraphView.clear()
    }

}
