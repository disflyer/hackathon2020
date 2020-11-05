//
//  JKPresentStyleNavigationAnimator.swift
//  AluminumKit-iOS
//
//  Created by ooatuoo on 2020/2/3.
//  Copyright © 2020 iftech.io. All rights reserved.
//

import UIKit

public class JKPresentStyleNavigationAnimator: NSObject, JKNavigationAnimator, UIViewControllerAnimatedTransitioning {
    
    public struct Config {
        public var maskCornerWhenIntransition = true
        public var conerRaidus: CGFloat = 12
        public var maskBackgroundColor = UIColor.black.withAlphaComponent(0.18)
        public var duration: TimeInterval = 0.4
        public init() { }
    }
    
    private var operation: UINavigationController.Operation = .push
    private weak var navigationController: UINavigationController?
    private lazy var percentDrivenTransition = UIPercentDrivenInteractiveTransition()
    private var isInteractive = false
    private var isInTransition = false

    private lazy var dismissPanGesture: JKFullScreenDismissPanGestureRecognizer = {
        let pan = JKFullScreenDismissPanGestureRecognizer(target: self, action: #selector(handleDimissPanGesture(_:)))
        return pan
    }()
    
    private lazy var bgView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.alpha = 0
        view.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        return view
    }()
    
    private lazy var maskLayer = CAShapeLayer()
    
    private let config: Config
    public init(configure: ((inout Config) -> Void)? = nil) {
        var config = Config()
        configure?(&config)
        self.config = config
        super.init()
    }

    public func interactiveTransitioning() -> UIViewControllerInteractiveTransitioning? {
        if operation == .pop, isInteractive { return percentDrivenTransition }
        return nil
    }

    public func animatedTransitioning(for operation: UINavigationController.Operation) -> UIViewControllerAnimatedTransitioning? {
        self.operation = operation
        return self
    }

    @objc private func handleDimissPanGesture(_ pan: UIPanGestureRecognizer) {
        guard let nav = navigationController, let view = pan.view else { return }
        // if previous transition hasn't finished(not interactive or has exited interactive), skip
        if !isInteractive && isInTransition { return }
        let percent = max(0, dismissPanGesture.translation(in: view).y / view.frame.height)
        let velocity = pan.velocity(in: view).y
        switch pan.state {
        case .began:
            isInteractive = true
            nav.popViewController(animated: true)
            percentDrivenTransition.update(0.01)
            
            // set corner when in transition
            if config.maskCornerWhenIntransition {
                setCornerMask(to: view)
            }

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
                if config.maskCornerWhenIntransition {
                    view.layer.mask = nil
                }
            }

            isInteractive = false
        default:
            print("go to default")
            break
        }
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        config.duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isInTransition { return }
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let toView = toVC.view, let fromView = fromVC.view else { return }

        isInTransition = true
        let containerView = transitionContext.containerView
        if operation == .push {
            let toViewFrame = transitionContext.finalFrame(for: toVC)
            toView.frame = toViewFrame
            toView.transform = CGAffineTransform(translationX: 0, y: toViewFrame.height)
            containerView.insertSubview(toView, aboveSubview: fromView)
            bgView.alpha = 0
            containerView.insertSubview(bgView, belowSubview: toView)
            if navigationController == nil {
                navigationController = fromVC.navigationController
                toView.addGestureRecognizer(dismissPanGesture)
            }
        } else {
            containerView.insertSubview(toView, belowSubview: fromView)
            containerView.insertSubview(bgView, aboveSubview: toView)
        }

        if isInteractive {
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear))
        } else {
            CATransaction.setAnimationTimingFunction(easeOutLikeSystemTimingFunction)
        }

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            if self.operation == .push {
                self.bgView.alpha = 1
                toView.transform = .identity
            } else {
                self.bgView.alpha = 0
                fromView.transform = CGAffineTransform(translationX: 0, y: fromView.frame.height)
            }
        }, completion: { finished in
            let success = !transitionContext.transitionWasCancelled
            if (self.operation == .push && !success) {
                toView.removeFromSuperview()
            }

            transitionContext.completeTransition(success)
            self.bgView.removeFromSuperview()
            self.isInTransition = false
        })
    }
    
    private func setCornerMask(to view: UIView) {
        maskLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: config.conerRaidus, height: config.conerRaidus)).cgPath
        view.layer.mask = maskLayer
        view.layer.masksToBounds = true
    }
}

