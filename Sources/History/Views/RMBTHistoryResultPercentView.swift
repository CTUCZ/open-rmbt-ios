//
//  RMBTHistoryResultPercentView.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 17.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

@objc final class RMBTHistoryResultPercentView: UIView {

    @objc public var percents: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @objc public var filledColor: UIColor = UIColor.white
    @objc public var unfilledColor: UIColor = UIColor.white.withAlphaComponent(0.3)
    @objc public var templateImage: UIImage? = UIImage(named: "traffic_lights_template")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let image = self.templateImage,
              let context = UIGraphicsGetCurrentContext()
        else {
            return
        }
        
        let pointSize = image.size.height
        let countPointsHorizontal: Int = Int(self.bounds.size.width / pointSize)
        let countPointsVertical = 2
        
        let countFillPointsHorizontal = (self.bounds.size.width * self.percents) / pointSize
        
        context.translateBy(x: 0, y: self.bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.copy)
        
        //Draw mask
        guard let cgImage = image.cgImage else { return }
        for i in 0..<countPointsHorizontal {
            for j in 0..<countPointsVertical {
                let x = CGFloat(i) * pointSize
                let y = CGFloat(j) * pointSize
                
                let imageRect = CGRect(x: x, y: y, width: pointSize, height: pointSize)
                context.draw(cgImage, in: imageRect)
            }
        }
        
        //Create mask
        guard let alphaMask = context.makeImage() else { return }
        
        //Append mask
        context.clip(to: self.bounds, mask: alphaMask)
        self.filledColor.setFill()
        
        //Draw filled area
        let fillRect = CGRect(x: 0, y: 0, width: countFillPointsHorizontal * pointSize, height: self.bounds.size.height)
        context.fill(fillRect)
        
        //Draw unfilled area
        self.unfilledColor.setFill()

        let unfillRect = CGRect(x: countFillPointsHorizontal * pointSize, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        context.fill(unfillRect)
    }
}
