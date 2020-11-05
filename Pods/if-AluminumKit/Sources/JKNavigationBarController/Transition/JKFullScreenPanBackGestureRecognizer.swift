//
//  JKFullScreenPanBackGestureRecognizer.swift
//  BaseUI
//
//  Created by Jason Yu on 11/14/17.
//  Copyright © 2017 若友网络科技有限公司. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

#if !AluminumKitCocoaPods
import Utilities
#endif

public enum PanBackMode: Int {
    case fullScreen
    case edge
    case disabled
}

public class JKFullScreenPanBackGestureRecognizer: UIPanGestureRecognizer {
    private var touchRegionFromLeft: CGFloat = ScreenWidth
    public var failPredicate: (() -> Bool)?
    
    public var panBackMode: PanBackMode = .fullScreen {
        didSet {
            switch panBackMode {
            case .fullScreen:
                self.isEnabled = true
                self.touchRegionFromLeft = ScreenWidth
            case .edge:
                self.isEnabled = true
                self.touchRegionFromLeft = 30
            case .disabled:
                self.isEnabled = false
            }
        }
    }
    
    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        self.delegate = self
    }
    
    // record first point
    private var initialPoint: CGPoint?
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let window = UIApplication.shared.keyWindow,
            let pointInWindow = touches.first?.location(in: window) {
            let predicateFail = self.failPredicate?() ?? false
            
            // if:
            // 1. not intended to recognize(predicate failed) --OR--
            // 2. not in allowed region
            // fail immediately on touchesBegan
            if predicateFail || pointInWindow.x > self.touchRegionFromLeft {
                self.state = .failed
            } else {
                self.initialPoint = pointInWindow
            }
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if let window = UIApplication.shared.keyWindow,
            let currentPoint = touches.first?.location(in: window),
            let initialPoint = self.initialPoint {
            
            // say initial point is p1
            //
            //                       /
            //                     /
            //                   /
            //   fail region   p1   allowed region
            //                   \
            //                     \
            //                       \
            //
            // now we need to decide the range of the slopes
            // and currentPoint.x must be greater than initialX
            // 1. the allowed region should be larger when panning at screen edge(makes it easier to recognize), say (-2, 2)
            // 2. normal range in other area, say (-1, 1)
            let isAtLeftEdge = initialPoint.x < 30
            let maxSlope: CGFloat = isAtLeftEdge ? 2 : 1
            let minSlope: CGFloat = isAtLeftEdge ? -2 : -1
            let isPanningToRight = (currentPoint.x - initialPoint.x) >= 0
            
            let currentSlope = (currentPoint.y - initialPoint.y) / (currentPoint.x - initialPoint.x)
            // set to fail if:
            // 1. currentSlope is not within the range --OR--
            // 2. panned to left
            if (currentSlope > maxSlope || currentSlope < minSlope || currentPoint.x < initialPoint.x || !isPanningToRight) && self.state == UIGestureRecognizer.State.possible {
                self.state = .failed
            }
        }
        
        super.touchesMoved(touches, with: event)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        self.initialPoint = nil
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        self.initialPoint = nil
    }
}

extension JKFullScreenPanBackGestureRecognizer: UIGestureRecognizerDelegate {
    public override func shouldBeRequiredToFail(by otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let pointInWindow = otherGestureRecognizer.location(in: UIApplication.shared.keyWindow)
        let isAtLeftEdge = pointInWindow.x < 30
        
        return isAtLeftEdge
    }
}

private var panBackModeKey: UInt8 = 0
extension UIViewController {
    public var panBackMode: PanBackMode {
        get {
            return objc_getAssociatedObject(self, &panBackModeKey) as? PanBackMode ?? .fullScreen
        }
        set {
            objc_setAssociatedObject(self, &panBackModeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

