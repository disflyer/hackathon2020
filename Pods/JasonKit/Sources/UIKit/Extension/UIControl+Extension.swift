//
//  File.swift
//  JasonKit
//
//  Created by Luminoid on 2019/12/5.
//  Copyright © 2019 iftech. All rights reserved.
//

import Foundation
import UIKit

private var pTouchAreaEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero

extension UIControl {
    public var touchAreaEdgeInsets: UIEdgeInsets {
        get {
            if let value = objc_getAssociatedObject(self, &pTouchAreaEdgeInsets) as? NSValue {
                var edgeInsets = UIEdgeInsets.zero
                value.getValue(&edgeInsets)
                return edgeInsets
            } else {
                return UIEdgeInsets.zero
            }
        }
        set(newValue) {
            var newValueCopy = newValue
            let objCType = NSValue(uiEdgeInsets: UIEdgeInsets.zero).objCType
            let value = NSValue(&newValueCopy, withObjCType: objCType)
            objc_setAssociatedObject(self, &pTouchAreaEdgeInsets, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.touchAreaEdgeInsets == UIEdgeInsets.zero || !self.isEnabled || self.isHidden {
            let superPointInside = super.point(inside: point, with: event)
            return superPointInside
        }

        let relativeFrame = self.bounds
        let hitFrame = relativeFrame.inset(by: self.touchAreaEdgeInsets)

        let selfPointInside = hitFrame.contains(point)
        return selfPointInside
    }
}

