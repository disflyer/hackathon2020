//
//  UIImageExtension.swift
//  Ruguo
//
//  Created by 李文韬 on 15/3/30.
//  Copyright (c) 2015年 若友网络科技有限公司. All rights reserved.
//

import UIKit
import Accelerate

// MARK: - Basic operation
public extension UIImage {
    var pixelLimit: CGFloat {
        // 10 million
        return 1000 * 10000
    }

    var pixelCount: CGFloat {
        return self.size.width * self.scale * self.size.height * self.scale
    }

    /// return image with up orientation
    public func toUpOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage!
    }
    
    /// Calculate the contentsRect for specified ratio around specified point. The returned value is as large as possible as long as it doesn't overflow. It's like getting visible contentsRect when putting the image in an imageView with contentMode = .scaleAspectFill(when centerPoint is at center)
    /// - parameter centerPoint: The target image center in original image's unit coordinate space.
    /// - parameter ratio: The width / height value for target image
    /// - returns: contentsRect for the originalImage to generate target image.
    func contentsRectFor(ratio: CGFloat, at centerPoint: CGPoint) -> CGRect {
        let (croppedWidth, croppedHeight): (CGFloat, CGFloat) = {
            // height too long
            if self.size.width / self.size.height < ratio {
                return (self.size.width, self.size.width / ratio)
            } else {
                return (self.size.height * ratio, self.size.height)
            }
        }()

        let centerX = centerPoint.x * self.size.width
        let centerY = centerPoint.y * self.size.height

        var supposedCroppedRect = CGRect(x: centerX - croppedWidth / 2, y: centerY - croppedHeight / 2, width: croppedWidth, height: croppedHeight)
        // check if croppedRect is within bounds
        // left
        supposedCroppedRect.origin.x = max(0, supposedCroppedRect.origin.x)
        // right
        let rightDistance = supposedCroppedRect.origin.x + croppedWidth - self.size.width
        if rightDistance > 0 {
            supposedCroppedRect.origin.x -= rightDistance
        }
        // up
        supposedCroppedRect.origin.y = max(0, supposedCroppedRect.origin.y)
        // down
        let bottomDistance = supposedCroppedRect.origin.y + croppedHeight - self.size.height
        if bottomDistance > 0 {
            supposedCroppedRect.origin.y -= bottomDistance
        }

        // now we get the rect, convert to contentsRect
        let contentsRect = CGRect(x: supposedCroppedRect.origin.x / self.size.width, y: supposedCroppedRect.origin.y / self.size.height, width: supposedCroppedRect.size.width / self.size.width, height: supposedCroppedRect.size.height / self.size.height)

        return contentsRect
    }

    /// For any image exceeding pixelLimit, resize to pixelLimit first
    func scaleToNormalSize() -> UIImage? {
        let ratio = self.size.width / self.size.height
        let scaledHeight = sqrt(self.pixelLimit / ratio) / self.scale
        let scaledWidth = scaledHeight * ratio
        let shortEdge = min(scaledWidth, scaledHeight)
        print("image is scaling from \(self.pixelCount) pixels to \(scaledWidth * self.scale) * \(scaledHeight * self.scale)")
        return self.limit(shortEdgeInPixel: shortEdge)
    }
}

// MARK: - Image cropping
public extension UIImage {
    /// Crop self to a square image, same center as original
    func cropSquareImage() -> UIImage {
        return self.crop(ratio: 1 / 1)
    }
    
    /// Crop self using a specified ratio, around specified point(as large as possible)
    func crop(ratio: CGFloat, centerPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> UIImage {
        let contentsRect = self.contentsRectFor(ratio: ratio, at: centerPoint)
        return self.crop(toContentsRect: contentsRect)
    }
    
    /// Crop self to a portion of whole image, area specified by contentsRect
    func crop(toContentsRect contentsRect: CGRect) -> UIImage {
        let cropRect = CGRect(
            x: contentsRect.origin.x * self.size.width * self.scale,
            y: contentsRect.origin.y * self.size.height * self.scale,
            width: contentsRect.size.width * self.size.width * self.scale,
            height: contentsRect.size.height * self.size.height * self.scale)
        if let imageRef = self.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        } else {
            return self
        }
    }
}

// MARK: - Image processing
public extension UIImage {
    /// tint non-transparent pixels to tintColor
    func apply(tintOfColor tintColor: UIColor) -> UIImage {
        #if DEBUG
            assert(tintColor.cgColor.alpha == 1, "applied tintColor's alpha must be 1.0!")
        #endif
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let context = UIGraphicsGetCurrentContext()
        
        self.draw(in: rect)
        context!.setFillColor(tintColor.cgColor)
        context!.setBlendMode(CGBlendMode.sourceAtop)
        context!.fill(rect)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage!
    }
    
    /// mask the image with color
    func apply(maskOfColor maskColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -area.size.height)
        
        context.saveGState()
        context.clip(to: area, mask: self.cgImage!)
        
        maskColor.set()
        context.fill(area)
        
        context.restoreGState()
        
        context.setBlendMode(CGBlendMode.multiply)
        
        context.draw(self.cgImage!, in: area)
        
        let colorizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return colorizedImage!
    }
    
    func apply(alpha: CGFloat) -> UIImage {
        // keep the scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let ctx = UIGraphicsGetCurrentContext()
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        ctx!.scaleBy(x: 1, y: -1)
        ctx!.translateBy(x: 0, y: -area.size.height)
        ctx!.setBlendMode(CGBlendMode.multiply)
        ctx!.setAlpha(alpha)
        ctx!.draw(self.cgImage!, in: area)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    /// apply vertical gradient colors to image
    func apply(gradientColorsFromTopToBottom colors: [UIColor]) -> UIImage {
        return applyGradient(colors: colors) { context, gradient in
            context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: self.size.height), end: CGPoint.zero, options: .drawsBeforeStartLocation)
        }
    }
    
    /// apply radial gradient colors to image
    func apply(radialGradient colors: [UIColor], startCenter: CGPoint, startRadius: CGFloat, endCenter: CGPoint, endRadius: CGFloat) -> UIImage {
        return applyGradient(colors: colors) { context, gradient in
            context.drawRadialGradient(gradient, startCenter: startCenter, startRadius: startRadius, endCenter: endCenter, endRadius: endRadius, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
    }
    
    private func applyGradient(colors: [UIColor], with block: (CGContext, CGGradient) -> Void) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: self.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        
        context!.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context!.draw(self.cgImage!, in: rect)
        
        let colors = colors.map { $0.cgColor } as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil)
        
        block(context!, gradient!)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func apply(cornerRadiusInImageScale: CGFloat, roundingCorners: UIRectCorner = [.topLeft, .bottomLeft, .topRight, .bottomRight]) -> UIImage {
        // working in the scale of the input image(self)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let bounds = CGRect(origin: CGPoint.zero, size: self.size)
        UIBezierPath(roundedRect: bounds,
                     byRoundingCorners: roundingCorners,
                     cornerRadii: CGSize(width: cornerRadiusInImageScale, height: cornerRadiusInImageScale)).addClip()
        self.draw(in: bounds)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage!
    }
    
    /// produce an image with rounded corner by clipping
    func apply(cornerRadiusInScreenScale: CGFloat, roundingCorners: UIRectCorner = [.topLeft, .bottomLeft, .topRight, .bottomRight]) -> UIImage {
        let factor = UIScreen.main.scale / self.scale
        let cornerRadiusInImageScale = cornerRadiusInScreenScale * factor
        return self.apply(cornerRadiusInImageScale: cornerRadiusInImageScale, roundingCorners: roundingCorners)
    }
    
    func flippedVertically() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        context!.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: self.size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        return newImage
    }
    
    func rotate(by angle: CGFloat) -> UIImage {
        // Calculate the size of the rotated image.
        let rotatedView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        rotatedView.transform = CGAffineTransform(rotationAngle: angle)
        let rotatedViewSize = rotatedView.frame.size
        
        // Create a bitmap-based graphics context.
        UIGraphicsBeginImageContextWithOptions(rotatedViewSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Move the origin of the user coordinate system in the context to the middle.
        context?.translateBy(x: rotatedViewSize.width / 2, y: rotatedViewSize.height / 2)
        
        // Rotates the user coordinate system in the context.
        context?.rotate(by: angle)
        
        // Flip the handedness of the user coordinate system in the context.
        context?.scaleBy(x: 1.0, y: -1.0)
        
        // Draw the image into the context.
        context?.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return rotatedImage!
    }
}

// MARK: - Image blur
public extension UIImage {
    func apply(blurRadius: CGFloat) -> UIImage {
        guard let inputImage = CIImage(image: self) else { return self }
        let ciContext = CIContext(options: nil)
        
        // affineClampFilter produces an image with infinite extent to avoid a soft, black fringe along the edges.
        let affineClampFilter = CIFilter(name: "CIAffineClamp")
        let xform = CGAffineTransform.identity
        affineClampFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        affineClampFilter?.setValue(xform, forKey: "inputTransform")
        
        guard let affineClampImage = affineClampFilter?.outputImage else { return self }
        
        let ciFilter = CIFilter(name: "CIGaussianBlur")
        ciFilter?.setValue(affineClampImage, forKey: kCIInputImageKey)
        ciFilter?.setValue(blurRadius, forKey: "inputRadius")
        
        if let outputImage = ciFilter?.outputImage, let cgImage = ciContext.createCGImage(outputImage, from: inputImage.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            return self
        }
    }
}
    
// MARK: - Image extended operation
public extension UIImage {
    var qrcodeStrings: [String] {
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else { return [] }
        if let ciImage = CIImage(image: self) {
            let qrcodes = detector.features(in: ciImage).compactMap { ($0 as? CIQRCodeFeature)?.messageString }
            if qrcodes.isEmpty {
                // Binarize image and try again
                if let inputImage = self.pureBlackAndWhiteImage(), let ciImage = CIImage(image: inputImage) {
                    return detector.features(in: ciImage).compactMap { ($0 as? CIQRCodeFeature)?.messageString }
                }
            } else {
                // Return the detected QR Code
                return qrcodes
            }
        }
        return []
    }
    
    func pureBlackAndWhiteImage() -> UIImage? {
        let inputImage = self
        
        func getImageContext(for inputCGImage: CGImage) -> CGContext? {
            
            let colorSpace       = CGColorSpaceCreateDeviceRGB()
            let width            = inputCGImage.width
            let height           = inputCGImage.height
            let bytesPerPixel    = 4
            let bitsPerComponent = 8
            let bytesPerRow      = bytesPerPixel * width
            let bitmapInfo       = RGBA32.bitmapInfo
            
            guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
                print("unable to create context")
                return nil
            }
            
            context.setBlendMode(.copy)
            context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
            
            return context
        }
        
        guard let inputCGImage = inputImage.cgImage, let context = getImageContext(for: inputCGImage), let data = context.data else { return nil }
        
        let white = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
        let black = RGBA32(red: 0, green: 0, blue: 0, alpha: 255)
        
        let width = Int(inputCGImage.width)
        let height = Int(inputCGImage.height)
        let pixelBuffer = data.bindMemory(to: RGBA32.self, capacity: width * height)
        
        // determined through tests.
        let threshold: UInt8 = 36
        
        for x in 0 ..< height {
            for y in 0 ..< width {
                let offset = x * width + y
                if pixelBuffer[offset].red < threshold && pixelBuffer[offset].green < threshold && pixelBuffer[offset].blue < threshold {
                    pixelBuffer[offset] = black
                } else {
                    pixelBuffer[offset] = white
                }
            }
        }
        
        let outputCGImage = context.makeImage()
        let outputImage = UIImage(cgImage: outputCGImage!, scale: inputImage.scale, orientation: inputImage.imageOrientation)
        
        return outputImage
    }
    
    struct RGBA32: Equatable {
        var color: UInt32
        
        var red: UInt8 {
            return UInt8((color >> 24) & 255)
        }
        
        var green: UInt8 {
            return UInt8((color >> 16) & 255)
        }
        
        var blue: UInt8 {
            return UInt8((color >> 8) & 255)
        }
        
        var alpha: UInt8 {
            return UInt8((color >> 0) & 255)
        }
        
        init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            let r = UInt32(red) << 24
            let g = UInt32(green) << 16
            let b = UInt32(blue) << 8
            let a = UInt32(alpha) << 0
            color = r | g | b | a
        }
        
        static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        public static func == (lhs: RGBA32, rhs: RGBA32) -> Bool {
            return lhs.color == rhs.color
        }
    }
}

// MARK: - Static function
public extension UIImage {
    /// generate an image with solid color
    // swiftlint:disable:next jike_colors
    class func solidImage(withColor color: UIColor = UIColor.white, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
