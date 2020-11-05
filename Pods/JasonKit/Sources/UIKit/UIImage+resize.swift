//
//  UIImage+resize.swift
//  AppCore
//
//  Created by Hang Yu on 2018/6/28.
//  Copyright © 2018 若友网络科技有限公司. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    public static func calculatePixelSize(originalPixelSize: CGSize, shortEdge: CGFloat? = nil, longEdge: CGFloat? = nil) -> CGSize {
        guard shortEdge != nil || longEdge != nil else {
            return originalPixelSize
        }
        
        // validate params
        if let shortEdge = shortEdge, shortEdge <= 0 {
            return originalPixelSize
        }
        
        if let longEdge = longEdge, longEdge <= 0 {
            return originalPixelSize
        }
        
        func getLongEdge(size: CGSize) -> CGFloat {
            return max(size.width, size.height)
        }
        
        func getShortEdge(size: CGSize) -> CGFloat {
            return min(size.width, size.height)
        }
        
        var scaledPixelSize = originalPixelSize
        
        // 1. check if shortEdge is satisfied
        if let toShortEdge = shortEdge {
            if toShortEdge < getShortEdge(size: scaledPixelSize) {
                let scaleDownFactor = toShortEdge / getShortEdge(size: scaledPixelSize)
                scaledPixelSize = scaledPixelSize.applying(CGAffineTransform(scaleX: scaleDownFactor, y: scaleDownFactor))
            }
        }
        
        // 2. check if longEdge is satisfied(after satisfying shortEdge)
        if let toLongEdge = longEdge {
            if toLongEdge < getLongEdge(size: scaledPixelSize) {
                let scaleDownFactor = toLongEdge / getLongEdge(size: scaledPixelSize)
                scaledPixelSize = scaledPixelSize.applying(CGAffineTransform(scaleX: scaleDownFactor, y: scaleDownFactor))
            }
        }
        return scaledPixelSize
    }
    
    /// Scale the image by constraining max short/long edge length in pixel.
    /// - parameter shortEdgeInPixel: Maximum short edge length. nil for unconstrained.
    /// - parameter longEdgeInPixel: Maximum long edge length. nil for unconstrained.
    /// - parameter opaque: If image has alpha channel, set to false. Setting this to false for images without alpha may result in an image with a pink hue.
    /// - returns: Scaled image
    public func limit(shortEdgeInPixel: CGFloat? = nil,
                      longEdgeInPixel: CGFloat? = nil,
                      opaque: Bool = true,
                      resultImageScale: CGFloat? = nil) -> UIImage {
        let originalPixelSize = self.size.applying(CGAffineTransform(scaleX: self.scale, y: self.scale))
        
        let scaledPixelSize = UIImage.calculatePixelSize(originalPixelSize: originalPixelSize, shortEdge: shortEdgeInPixel, longEdge: longEdgeInPixel)
        
        // only return if:
        // 1. pixel size doesn't change after satisfying constraints
        // 2. image scale equals result scale
        if originalPixelSize == scaledPixelSize && (resultImageScale == nil || resultImageScale == self.scale) {
            return self
        }
        
        // draw in scaled canvas
        // current scale is 1, need to render in original image scale(or specified scale), so finally we can get the result image with the desired scale
        // The image scale may be different with the device scale
        let resultImageScale = resultImageScale ?? self.scale
        let factor = 1 / resultImageScale
        let canvasSize = scaledPixelSize.applying(CGAffineTransform(scaleX: factor, y: factor))
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, opaque, resultImageScale)
        self.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }
    
    public func scale(toSizeInScreenScale: CGSize) -> UIImage {
        let factor = UIScreen.main.scale / self.scale
        let toSizeInSelfScale = CGSize(width: toSizeInScreenScale.width * factor,
                                       height: toSizeInScreenScale.height * factor)
        if toSizeInSelfScale == self.size {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(toSizeInSelfScale, true, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: toSizeInSelfScale.width, height: toSizeInSelfScale.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }
    
    /**
     Scale the image by constraining max short/long edge length in point. A wrapper function for limit(shortEdgeInPixel: CGFloat?, longEdgeInPixel: CGFloat?, opaque: Bool)
     */
    public func limitUsingPointOfCurrentDevice(shortEdgeInPoint: CGFloat? = nil, longEdgeInPoint: CGFloat? = nil, opaque: Bool = true) -> UIImage {
        
        let deviceScale = UIScreen.main.scale
        var shortPixel: CGFloat?
        if let short = shortEdgeInPoint {
            shortPixel = short * deviceScale
        }
        var longPixel: CGFloat?
        if let long = longEdgeInPoint {
            longPixel = long * deviceScale
        }
        return limit(shortEdgeInPixel: shortPixel, longEdgeInPixel: longPixel, opaque: opaque, resultImageScale: deviceScale)
    }
}
