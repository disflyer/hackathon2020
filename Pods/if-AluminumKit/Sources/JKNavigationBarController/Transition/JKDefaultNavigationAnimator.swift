//
//  JKDefaultNavigationAnimator.swift
//  BaseUI
//
//  Created by Jason Yu on 11/15/17.
//  Copyright © 2017 若友网络科技有限公司. All rights reserved.
//

import UIKit

#if !AluminumKitCocoaPods
import Utilities
#endif

public class JKDefaultNavigationAnimator: NSObject, JKNavigationAnimator, UIViewControllerAnimatedTransitioning {
    
    public var panBackMode: PanBackMode {
        get { return fullScreenPopGestureRecognizer.panBackMode }
        set { fullScreenPopGestureRecognizer.panBackMode = newValue }
    }
    
    public func animatedTransitioning(for operation: UINavigationController.Operation) -> UIViewControllerAnimatedTransitioning? {
        self.operation = operation
        return self
    }
    
    public func interactiveTransitioning() -> UIViewControllerInteractiveTransitioning? {
        if operation == .pop && isInteractive {
            return percentDrivenTransition
        }
        return nil
    }

    var isInteractive = false
    var isInTransition = false
    var operation: UINavigationController.Operation = .push
    let percentDrivenTransition = UIPercentDrivenInteractiveTransition()
    weak var navigationController: UINavigationController?
    lazy var fullScreenPopGestureRecognizer: JKFullScreenPanBackGestureRecognizer = {
        let ges = JKFullScreenPanBackGestureRecognizer()
        ges.addTarget(self, action: #selector(handlePanBack(_:)))
        ges.failPredicate = { [weak self] in
            guard let strongSelf = self, let navigationController = strongSelf.navigationController else {
                return false
            }
            // fail the gesture if navigation is at root
            return navigationController.viewControllers.count <= 1
        }
        return ges
    }()
    
    public init(navigationController: UINavigationController) {
        super.init()
        self.navigationController = navigationController
        self.navigationController?.view.addGestureRecognizer(fullScreenPopGestureRecognizer)
    }
    
    deinit {
        fullScreenPopGestureRecognizer.view?.removeGestureRecognizer(fullScreenPopGestureRecognizer)
    }
    
    @objc func handlePanBack(_ pan: UIPanGestureRecognizer) {
        guard let navigationController = self.navigationController else {
            return
        }
        let translation = pan.translation(in: navigationController.view)
        let percent = max(0, translation.x / ScreenWidth)   // translation could be lower than 0, when moving to left where you started
        let velocity = pan.velocity(in: navigationController.view).x
        
        // if previous transition hasn't finished(not interactive or has exited interactive), skip
        if isInteractive == false && isInTransition {
            return
        }
        
        switch pan.state {
        case .began:
            isInteractive = true
            navigationController.popViewController(animated: true)
            percentDrivenTransition.update(0.01)
        case .changed:
            percentDrivenTransition.update(percent)
        case .ended, .cancelled, .failed:
            let shouldFinishAnimation: Bool
            
            // respect velocity first
            if abs(velocity) > 300 {
                shouldFinishAnimation = velocity > 0
            } else {
                // if velocity is low, respect animation percentage
                shouldFinishAnimation = percent > 0.4
            }

            // completion speed is determined by:
            // 1. how much distance left to final position. the larger the distance, the faster the speed.
            let percentLeft = shouldFinishAnimation ? (1 - percent) : percent
            // adjust by 0.5 so it won't affect too much
            let percentFactor = percentLeft * 0.5

            // 2. the velocity of user gesture. the faster the swipe, the faster the speed
            // the velocity is too small, limit to
            let velocityFactor: CGFloat = abs(velocity) / 5000
            
            self.percentDrivenTransition.completionSpeed = 0.05 + percentFactor + velocityFactor
            
            if shouldFinishAnimation {
                percentDrivenTransition.finish()
            } else {
                percentDrivenTransition.cancel()
            }
            isInteractive = false
        default:
            break
        }
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isInTransition {
            return
        }
        let containerView = transitionContext.containerView
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let fromView: UIView = fromVC.view
        let toView: UIView = toVC.view
        
        // add shadow
        let layer = operation == .push ? toView.layer : fromView.layer
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 1.0
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
        
        // add toVC view
        if operation == .push {
            containerView.insertSubview(toView, aboveSubview: fromView)
        } else {
            containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        // add mask
        let maskView = UIView()
        maskView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        if operation == .push {
            fromView.addSubview(maskView)
            maskView.frame = fromView.bounds
        } else {
            toView.addSubview(maskView)
            maskView.frame = toView.bounds
        }
        
        // set initial state
        fromView.transform = CGAffineTransform(translationX: 0, y: 0)
        toView.transform = CGAffineTransform(translationX: operation == .push ? ScreenWidth : -ScreenWidth / 2, y: 0)
        maskView.alpha = operation == .push ? 0 : 1
        
        //        CATransaction.begin()
        
        if isInteractive == false {
            CATransaction.setAnimationTimingFunction(easeOutLikeSystemTimingFunction)
        } else {
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear))
        }
        
        let duration = self.transitionDuration(using: nil)
        isInTransition = true
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        layer.shadowOpacity = 0.0
        CATransaction.commit()
        
        UIView.animate(withDuration: duration, delay: 0, options: [], animations: {
            fromView.transform = CGAffineTransform(translationX: self.operation == .push ? -ScreenWidth / 2 : ScreenWidth, y: 0)
            toView.transform = CGAffineTransform(translationX: 0, y: 0)
            maskView.alpha = self.operation == .push ? 1 : 0
        }, completion: { (_) in
            fromView.transform = CGAffineTransform.identity
            toView.transform = CGAffineTransform.identity
            maskView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.isInTransition = false
        })
    }
}


