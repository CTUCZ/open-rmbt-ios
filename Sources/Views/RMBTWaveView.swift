//
//  RMBTWaveView.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 30.07.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTWaveView: UIView {
    enum Mode {
        case horizontal
        case vertical
    }
    
    private enum State {
        case start
        case process
        case shouldStop
        case shouldStart
        case stoping
        case stop
    }
    
    @IBInspectable var color: UIColor = UIColor.white
    var direction: CAMediaTimingFillMode = .forwards
    
    private let duration = 2.25
    
    private var state: State = .stop
    
    var mode: Mode = .horizontal
    
    override class var layerClass: AnyClass { return CAShapeLayer.self }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0, self.bounds.height, 0)
        transform = CATransform3DScale(transform, 1, 0, 1)
        self.layer.transform = transform
    }
    
    private func wave(_ offset: CGFloat) -> UIBezierPath {
        let bezPathStage0: UIBezierPath = UIBezierPath()
        if mode == .horizontal {
            bezPathStage0.move(to: CGPoint(x: offset + (-self.bounds.width), y: self.bounds.height / 2))
            bezPathStage0.addCurve(to: CGPoint(x: offset + 0, y: self.bounds.height / 2),
                    controlPoint1: CGPoint(x: offset + (-self.bounds.width * 0.66), y: 0),
                    controlPoint2: CGPoint(x: offset + (-self.bounds.width * 0.33), y: self.bounds.height))
            bezPathStage0.addCurve(to: CGPoint(x: offset + self.bounds.width, y: self.bounds.height / 2),
                   controlPoint1: CGPoint(x: offset + self.bounds.width * 0.33, y: 0),
                   controlPoint2: CGPoint(x: offset + self.bounds.width * 0.66, y: self.bounds.height))
            bezPathStage0.addCurve(to: CGPoint(x: offset + self.bounds.width * 2, y: self.bounds.height / 2),
                   controlPoint1: CGPoint(x: offset + self.bounds.width + self.bounds.width * 0.33, y: 0),
                   controlPoint2: CGPoint(x: offset + self.bounds.width + self.bounds.width * 0.66, y: self.bounds.height))
            bezPathStage0.addLine(to: CGPoint(x: offset + self.bounds.width * 2, y: self.bounds.height))
            bezPathStage0.addLine(to: CGPoint(x: offset + (-self.bounds.width), y: self.bounds.height))
            bezPathStage0.addLine(to: CGPoint(x: offset + (-self.bounds.width), y: self.bounds.height / 2))
        } else {
            bezPathStage0.move(to: CGPoint(x: self.bounds.width / 2, y: offset + (-self.bounds.height)))
            
            bezPathStage0.addCurve(to: CGPoint(x: self.bounds.width / 2, y: offset + 0),
                                   controlPoint1: CGPoint(x: 0, y: offset + (-self.bounds.height * 0.66)),
                                   controlPoint2: CGPoint(x: self.bounds.width, y: offset + (-self.bounds.height * 0.33)))
            
            bezPathStage0.addCurve(to: CGPoint(x: self.bounds.width / 2, y: offset + self.bounds.height),
                   controlPoint1: CGPoint(x: 0, y: offset + self.bounds.height * 0.33),
                   controlPoint2: CGPoint(x: self.bounds.width, y: offset + self.bounds.height * 0.66))

            bezPathStage0.addCurve(to: CGPoint(x: self.bounds.width / 2, y: offset + self.bounds.height * 2 ),
                   controlPoint1: CGPoint(x: 0, y: offset + self.bounds.height + self.bounds.height * 0.33),
                   controlPoint2: CGPoint(x: self.bounds.width, y: offset + self.bounds.height + self.bounds.height * 0.66))
            
            bezPathStage0.addLine(to: CGPoint(x: self.bounds.width, y: offset + self.bounds.height * 2))
            bezPathStage0.addLine(to: CGPoint(x: self.bounds.width, y: offset + (-self.bounds.height)))
            bezPathStage0.addLine(to: CGPoint(x: self.bounds.width / 2, y: offset + (-self.bounds.height)))
        }
        bezPathStage0.close()
        return bezPathStage0
    }
    
    private func waveAnimation() -> CAAnimation? {
        let bezPathStage0: UIBezierPath
        let bezPathStage1: UIBezierPath
        if mode == .horizontal {
            bezPathStage0 = wave(direction == .forwards ? 0 : self.bounds.width)
            bezPathStage1 = wave(direction == .forwards ? self.bounds.width : 0)
        } else {
            bezPathStage0 = wave(direction == .forwards ? 0 : self.bounds.height)
            bezPathStage1 = wave(direction == .forwards ? self.bounds.height : 0)
        }

        let animStage0: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage0.fromValue = bezPathStage0.cgPath
        animStage0.toValue = bezPathStage1.cgPath
        animStage0.beginTime = 0.0
        animStage0.duration = duration
        
        let waveAnimGroup: CAAnimationGroup = CAAnimationGroup()
        waveAnimGroup.animations = [animStage0]
        waveAnimGroup.duration = duration
        waveAnimGroup.fillMode = direction
        waveAnimGroup.repeatCount = .greatestFiniteMagnitude

        return waveAnimGroup
    }
    
    func startAnimation() {
        self.state = .start
        
        guard let layer = self.layer as? CAShapeLayer else { return }
        layer.path = wave(0).cgPath
        layer.strokeColor = self.color.cgColor
        layer.fillColor = self.color.cgColor
        layer.lineWidth = 1.0
        
        guard let animation = self.waveAnimation() else { return }
        layer.removeAnimation(forKey: "wave")
        layer.add(animation, forKey: "wave")
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowAnimatedContent, .beginFromCurrentState], animations: {
            var transform = CATransform3DIdentity
            transform = CATransform3DTranslate(transform, 0, 0, 0)
            transform = CATransform3DScale(transform, 1, 1, 1)
            self.layer.transform = transform
        }, completion: nil)
    }
    
    func stopAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowAnimatedContent, .beginFromCurrentState], animations: {
            var transform = CATransform3DIdentity
            transform = CATransform3DTranslate(transform, 0, self.bounds.height, 0)
            transform = CATransform3DScale(transform, 1, 0, 1)
            self.layer.transform = transform
        })
    }
}

