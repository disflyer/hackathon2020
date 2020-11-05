//
//  JKNavigationAnimator.swift
//  AluminumKit-iOS
//
//  Created by ooatuoo on 2020/2/3.
//  Copyright © 2020 iftech.io. All rights reserved.
//

import UIKit

// TODO: - move to JasonKit
public let easeOutLikeSystemTimingFunction = CAMediaTimingFunction(controlPoints: 0.3, 0.6, 0.2, 1.0)

public protocol JKNavigationAnimator: class {
    func animatedTransitioning(for operation: UINavigationController.Operation) -> UIViewControllerAnimatedTransitioning?
    func interactiveTransitioning() -> UIViewControllerInteractiveTransitioning?
}

