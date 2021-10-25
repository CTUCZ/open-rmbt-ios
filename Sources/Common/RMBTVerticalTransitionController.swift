//
//  RMBTVerticalTransitionController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 17.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

@objc final class RMBTVerticalTransitionController: NSObject {
    @objc var reverse = false
}

extension RMBTVerticalTransitionController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from)
        else {
            return
        }
        
        let endFrame = transitionContext.initialFrame(for: fromViewController)
        if (self.reverse == false) {
            transitionContext.containerView.addSubview(toViewController.view)
        }
        
        toViewController.view.frame = endFrame.offsetBy(dx: 0, dy: (self.reverse ? 1 : -1) * toViewController.view.frame.size.height)
            
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext)) {
            toViewController.view.frame = endFrame
            fromViewController.view.frame = fromViewController.view.frame.offsetBy(dx: 0, dy: (self.reverse ? -1 : 1) * toViewController.view.frame.size.height)
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
    }
    
}
