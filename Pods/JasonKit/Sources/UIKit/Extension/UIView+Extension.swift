//
//  UIView+Extension.swift
//  JasonKit
//
//  Created by Luminoid on 2019/12/6.
//  Copyright © 2019 iftech. All rights reserved.
//

import UIKit

extension UIView {
    public func fadeIn(_ alpha: CGFloat = 1.0, duration: Double = 0.25) {
        self.isHidden = false
        
        if duration == 0.0 {
            self.alpha = alpha
        } else {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = alpha
            })
        }
    }
    
    public func fadeOut(_ alpha: CGFloat = 0.0, duration: Double = 0.25, shouldHide: Bool = false) {
        guard !self.isHidden else { return }
        
        if duration == 0.0 {
            self.alpha = alpha
            if shouldHide {
                self.isHidden = true
            }
        } else {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = alpha
            }, completion: { _ in
                if shouldHide {
                    self.isHidden = true
                }
            })
        }
    }
    
    public func fadeOutAndHide(duration: Double = 0.25) {
        self.fadeOut(duration: duration, shouldHide: true)
    }
}
