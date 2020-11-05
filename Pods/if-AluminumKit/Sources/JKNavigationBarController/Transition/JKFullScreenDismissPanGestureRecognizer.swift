//
//  JKFullScreenDismissPanGestureRecognizer.swift
//  Example
//
//  Created by ooatuoo on 2020/2/5.
//  Copyright © 2020 iftech.io. All rights reserved.
//

import UIKit

public class JKFullScreenDismissPanGestureRecognizer: UIPanGestureRecognizer {
    private var initialPoint: CGPoint?

    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        delegate = self
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first, let window = touch.window {
            let pointInWindow = touch.location(in: window)
            self.initialPoint = pointInWindow
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first, let window = touch.window,
            let initialPoint = self.initialPoint {
            let currentPoint = touch.location(in: window)
            if currentPoint != initialPoint {
                let isPanningDown = (currentPoint.y - initialPoint.y) > 0
                if self.state == .possible && !isPanningDown {
                    self.state = .failed
                }
            }
        }
        super.touchesMoved(touches, with: event)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
    }
}

extension JKFullScreenDismissPanGestureRecognizer: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let otherGes = otherGestureRecognizer as? UIPanGestureRecognizer,
            let sv = otherGes.view as? UIScrollView {
            
            let isAtTop = sv.contentOffset.y + sv.contentInset.top <= 0
            return isAtTop
        }
        
        return true
    }
}
