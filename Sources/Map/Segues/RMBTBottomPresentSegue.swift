//
//  RMBTBottomPresentSegue.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 25.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class RMBTBottomPresentSegue: UIStoryboardSegue {

    private var selfRetainer: RMBTBottomPresentSegue? = nil
    
    override func perform() {
        selfRetainer = self
        destination.modalPresentationStyle = .overFullScreen
        destination.transitioningDelegate = self
        source.present(destination, animated: true, completion: nil)
    }
}

extension RMBTBottomPresentSegue: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        selfRetainer = nil
        return DismissAnimator()
    }
}

class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard
            let toViewController = transitionContext.viewController(forKey: .to)
        else {
            return
        }
        
        // Add dim view
        let dimView = UIView()
        dimView.tag = 1234
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.clear
        container.addSubview(dimView)
        NSLayoutConstraint.activate([
            container.bottomAnchor.constraint(equalTo: dimView.bottomAnchor),
            container.leftAnchor.constraint(equalTo: dimView.leftAnchor),
            container.rightAnchor.constraint(equalTo: dimView.rightAnchor),
            container.topAnchor.constraint(equalTo: dimView.topAnchor)
        ])
        
        container.layoutIfNeeded()
        
        // Add to view controller
        transitionContext.containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0

        var frame = transitionContext.finalFrame(for: toViewController)
        
        if let navController = toViewController as? UINavigationController,
           let vc = navController.topViewController as? RMBTBottomCardProtocol {
            if vc.contentSize.width > 0 {
                frame.size.width = vc.contentSize.width
            }
            if vc.contentSize.height > 0 {
                frame.size.height = vc.contentSize.height
            }
        } else if let vc = toViewController as? RMBTBottomCardProtocol {
            if vc.contentSize.width > 0 {
                frame.size.width = vc.contentSize.width
            }
            if vc.contentSize.height > 0 {
                frame.size.height = vc.contentSize.height
            }
        }
        
        // Set start frame
        frame.origin.y = container.frame.maxY
        toViewController.view.frame = frame
        
        toViewController.view.layer.cornerRadius = 8
        // Set final frame
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toViewController.view.alpha = 1
            frame.origin.y = container.frame.maxY - frame.size.height
            toViewController.view.frame = frame
            dimView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard
            let fromViewController = transitionContext.viewController(forKey: .from)
        else {
            return
        }
        
        let dimView = container.viewWithTag(1234)
        
        // Set start frame
        var frame = transitionContext.finalFrame(for: fromViewController)

        // Set final frame
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromViewController.view.alpha = 0
            frame.origin.y = dimView?.frame.maxY ?? container.frame.maxY
            fromViewController.view.frame = frame
            dimView?.backgroundColor = UIColor.clear
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}


class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else {
            return
        }
        
        container.addSubview(fromView)
        container.addSubview(toView)
        
        var frame = fromView.frame
        if let vc = toViewController as? RMBTBottomCardProtocol {
            if vc.contentSize.width > 0 {
                frame.size.width = vc.contentSize.width
            }
            if vc.contentSize.height > 0 {
                frame.size.height = vc.contentSize.height
            }
        }
        
        frame.origin.x = -40
        
        toView.layer.shadowOpacity = 0.0
        toView.layer.shadowRadius = 6.0
        toView.layer.shadowOffset = CGSize(width: -1, height: 0)
        
        toView.frame.origin.x = fromView.frame.maxX
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromView.frame.origin.x = -40
            
            let rootViewFrame: CGRect = (fromViewController.navigationController?.view.frame ?? fromView.window?.bounds) ?? CGRect()
            fromViewController.navigationController?.view.frame.origin.y = rootViewFrame.maxY - frame.size.height
            fromViewController.navigationController?.view.frame.size.height = frame.size.height
            toView.frame.origin.x = 0
            toView.frame.size.height = frame.size.height
            toView.layer.shadowOpacity = 0.3
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else {
            return
        }
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        var frame = fromView.frame
        if let vc = toViewController as? RMBTBottomCardProtocol {
            if vc.contentSize.width > 0 {
                frame.size.width = vc.contentSize.width
            }
            if vc.contentSize.height > 0 {
                frame.size.height = vc.contentSize.height
            }
        }
        
        frame.origin.x = -40
        
        fromView.layer.shadowOpacity = 0.0
        fromView.layer.shadowRadius = 6.0
        fromView.layer.shadowOffset = CGSize(width: -1, height: 0)
        
        toView.frame.origin.x = -40
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromView.frame.origin.x = fromView.frame.maxX
            fromView.frame.size.height = 800
            
            let rootViewFrame: CGRect = (fromViewController.navigationController?.view.frame ?? fromView.window?.bounds) ?? CGRect()
            fromViewController.navigationController?.view.frame.origin.y = rootViewFrame.maxY - frame.size.height
            fromViewController.navigationController?.view.frame.size.height = frame.size.height
            toView.frame.origin.x = 0
            toView.frame.size.height = rootViewFrame.height //frame.size.height
            
            fromView.layer.shadowOpacity = 0.3
        }, completion: { _ in
            toView.frame.size.height = frame.size.height
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
