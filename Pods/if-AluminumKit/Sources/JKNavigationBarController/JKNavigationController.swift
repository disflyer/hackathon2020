//
//  JKNavigationController.swift
//  AluminumKit-iOS
//
//  Created by Kael Yang on 2019/12/2.
//  Copyright © 2019 iftech.io. All rights reserved.
//

import UIKit

public enum DefaultNavigationAnimatorType {
    case system
    case `default`
}

open class JKNavigationController: UINavigationController {
    open private(set) var defaultAnimatorType: DefaultNavigationAnimatorType = .system
    open private(set) var defaultAnimator: JKDefaultNavigationAnimator?
    open override func viewDidLoad() {
        if #available(iOS 11, *) {

        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        super.viewDidLoad()

        self.delegate = self
        self.isNavigationBarHidden = false
        self.navigationBar.isHidden = true
        
        setDefaultAnimatorType(defaultAnimatorType)
    }
    
    open func setDefaultAnimatorType(_ type: DefaultNavigationAnimatorType) {
        self.defaultAnimatorType = type
        switch type {
        case .system:
            defaultAnimator = nil
            self.interactivePopGestureRecognizer?.delegate = self
            self.interactivePopGestureRecognizer?.isEnabled = true
            
        case .default:
            defaultAnimator = JKDefaultNavigationAnimator(navigationController: self)
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
    }

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            (viewController as? JKNavigationBarContainer)?.shouldAddBackButton = true
        }
        super.pushViewController(viewController, animated: animated)
    }

    open override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: animated)
    }

    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }

    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return self.topViewController
    }

    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }

    open override var shouldAutorotate: Bool {
        return false
    }
}

extension JKNavigationController: UINavigationControllerDelegate {
    open func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        let animator = (animationController as? JKNavigationAnimator) ?? defaultAnimator
        return animator?.interactiveTransitioning()
    }

    open func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        let vc = operation == .push ? toVC : fromVC
        let animator = (vc as? JKNavigationAnimatorProvider)?.navigationAnimator ?? defaultAnimator
        return animator?.animatedTransitioning(for: operation)
    }
    
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    }
    
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let animatorProvider = viewController as? JKNavigationAnimatorProvider, animatorProvider.navigationAnimator != nil {
            // if vc has self animator, disable default animator for ges conflict
            defaultAnimator?.panBackMode = .disabled
        } else {
            defaultAnimator?.panBackMode = viewController.panBackMode
        }
    }
}

extension JKNavigationController: UIGestureRecognizerDelegate {
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

