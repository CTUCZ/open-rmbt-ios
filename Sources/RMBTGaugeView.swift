//
//  RMBTGaugeView.swift
//  RMBT
//
//  Created by Benjamin Pucher on 19.09.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import UIKit

@objc public class RMBTGaugeView: UIView {
    private var startAngle: CGFloat!

    private var endAngle: CGFloat!

    private var foregroundImage: UIImage!
    private var foregroundLayer: CALayer?

    private var backgroundImage: UIImage!
    private var backgroundLayer: CALayer?

    private var maskForegroundLayer: CAShapeLayer!

    private var backgroundView: UIView?
    
    @objc public var value: CGFloat = 0 {
        didSet {
            if value == oldValue {
                return
            }

            let ovalRect: CGRect = self.bounds
            let angle = startAngle + (endAngle - startAngle) * value
            
            let arcCenter = CGPoint(x: ovalRect.midX, y: ovalRect.midY)
            let path = UIBezierPath(
                arcCenter: arcCenter,
                radius: ovalRect.size.width,
                startAngle: startAngle,
                endAngle: angle,
                clockwise: true)
            path.addLine(to: arcCenter)
            path.close()
            maskForegroundLayer.path = path.cgPath
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.foregroundLayer?.frame = self.bounds
        self.backgroundLayer?.frame = self.bounds
        self.maskForegroundLayer.frame = self.bounds
        
        self.backgroundView?.frame = self.bounds
    }
    ///
    @objc public required init(frame: CGRect, name: String, startAngle: CGFloat, endAngle: CGFloat) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = UIColor.clear
        
        if name == "progress" {
            backgroundImage = UIImage(named: "gauge_\(name)_bg-1")
            foregroundImage = UIImage(named: "gauge_\(name)_fg-1")
        } else {
            backgroundImage = UIImage(named: "gauge_\(name)_bg-1")
            foregroundImage = UIImage(named: "gauge_\(name)_fg-1")
        }

        assert(foregroundImage != nil, "Couldn't load image")
        assert(backgroundImage != nil, "Couldn't load image")
        
        self.startAngle = (startAngle * CGFloat.pi) / 180.0
        self.endAngle = (endAngle * CGFloat.pi) / 180.0
        
        value = 0.0

        let foregroundLayer = CALayer()
        foregroundLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        foregroundLayer.contents = foregroundImage.cgImage
        foregroundLayer.contentsGravity = .resizeAspect
        self.foregroundLayer = foregroundLayer
        
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)

        backgroundLayer.contents = backgroundImage.cgImage
        backgroundLayer.contentsGravity = .resizeAspect
        
        self.backgroundLayer = backgroundLayer

        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(foregroundLayer)

        self.maskForegroundLayer = CAShapeLayer()
        maskForegroundLayer.contentsGravity = .resizeAspect
        foregroundLayer.mask = maskForegroundLayer
    }

    ///
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        assert(false, "init(code:) should never be used on class RMBTGaugeView")
    }

}
