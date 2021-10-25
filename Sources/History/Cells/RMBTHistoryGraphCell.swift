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
    
    @IBOutlet weak var speedGraphView: RMBTSpeedGraphView!
    
    var graph: RMBTHistorySpeedGraph? {
        didSet {
            if let graph = graph {
                speedGraphView.clear()
                for t in graph.throughputs {
                    speedGraphView.addValue(Float(RMBTSpeedLogValue(t.kilobitsPerSecond())), atTimeInterval: Double(t.endNanos)/Double(NSEC_PER_SEC))
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
