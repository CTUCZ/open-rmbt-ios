//
//  RMBTGradientView.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 26.07.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTGradientView: UIView {
    enum Direction {
        case topBottom
        case bottomTop
        case leftRight
        case rightLeft
        case angle(_ angle: CGFloat)
    }
    
    @IBInspectable var fromColor: UIColor? {
        didSet {
            self.updateGradient()
        }
    }
    @IBInspectable var toColor: UIColor? {
        didSet {
            self.updateGradient()
        }
    }
    
    public var direction: Direction = .topBottom {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    private func updateGradient() {
        guard let layer = self.layer as? CAGradientLayer else { return }
        var colors: [CGColor] = []
        if let fromColor = fromColor {
            colors.append(fromColor.cgColor)
        }
        if let toColor = toColor {
            colors.append(toColor.cgColor)
        }
        layer.colors = colors
        layer.locations = [0.0, 1.0]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let layer = self.layer as? CAGradientLayer else { return }
        
        switch direction {
        case .topBottom:
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint(x: 0.5, y: 1)
        case .bottomTop:
            layer.startPoint = CGPoint(x: 0.5, y: 1)
            layer.endPoint = CGPoint(x: 0.5, y: 0)
        case .leftRight:
            layer.startPoint = CGPoint(x: 0.0, y: 0.5)
            layer.endPoint = CGPoint(x: 1, y: 0.5)
        case .rightLeft:
            layer.startPoint = CGPoint(x: 1.0, y: 0.5)
            layer.endPoint = CGPoint(x: 0, y: 0.5)
        case .angle(_): break
            // TODO: Implement it
        }
    }

}
