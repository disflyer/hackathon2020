//
//  UIImage+ImageIO.swift
//  AppCore
//
//  Created by Hang Yu on 2018/7/6.
//  Copyright © 2018 若友网络科技有限公司. All rights reserved.
//

import UIKit
import MobileCoreServices

public class ImageUtil {
    public static let imageProcessingQueue = DispatchQueue(label: "com.okjike.imageprocessing")
    public static var enableHEICUpload = true
    public static let maximumImagePixelLimit: CGFloat = 15000000
    
    public static func getImage(fromCompressedImageData data: Data,
                                shortEdgeInPixel: CGFloat? = nil,
                                longEdgeInPixel: CGFloat? = nil,
                                totalPixelLimit: CGFloat = maximumImagePixelLimit,
                                decodeImage: Bool = false) -> UIImage? {
        
        guard let (cgImage, _) = self.getCGImageAndSource(fromCompressedImageData: data, shortEdgeInPixel: shortEdgeInPixel, longEdgeInPixel: longEdgeInPixel, totalPixelLimit: totalPixelLimit, transformImage: true, decodeImage: decodeImage) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
    
    public enum CompressOption {
        case sizeLimitInKb(Int)
        case compressQuality(Double)
    }
    
    public static func getDownsizedImageData(fromCompressedImageData data: Data,
                                             shortEdgeInPixel: CGFloat? = nil,
                                             longEdgeInPixel: CGFloat? = nil,
                                             totalPixelLimit: CGFloat = maximumImagePixelLimit,
                                             imageModificationBlock: ((UIImage) -> UIImage)? = nil,
                                             // based on tests, leaving this nil is equal to setting to 0.75. Seems system has a default value of 0.75.
                                             compressOption: CompressOption = .compressQuality(0.75)) -> Data {
        
        let startTime = Date()
        // 1. get resized cgImage, do not decode.
        guard let (cgImage, imageSource) = getCGImageAndSource(fromCompressedImageData: data,
                                                               shortEdgeInPixel: shortEdgeInPixel,
                                                               longEdgeInPixel: longEdgeInPixel,
                                                               totalPixelLimit: totalPixelLimit,
                                                               decodeImage: false),
            let imageSourceType = CGImageSourceGetType(imageSource) else {
                
//                RGLogger.error("get cgimage from compressed data failed", in: .imageIO)
                return data
        }
        
        // If the compress option is size limit,
        // and there's no modification block,
        // and the original data match all requirement,
        // then, just return the original data.
        if case let .sizeLimitInKb(sizeLimit) = compressOption,
            imageModificationBlock == nil,
            data.sizeInKb < sizeLimit,
            let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any],
            let width = properties[kCGImagePropertyPixelWidth as String] as? CGFloat,
            let height = properties[kCGImagePropertyPixelHeight as String] as? CGFloat {
            
            let originSize = CGSize(width: width, height: height)
            let calculatedSize = UIImage.calculatePixelSize(originalPixelSize: originSize, shortEdge: shortEdgeInPixel, longEdge: longEdgeInPixel)
            if originSize == calculatedSize {
                return data
            }
        }
        
        let metaData = CGImageSourceCopyMetadataAtIndex(imageSource, 0, nil)
        
        let image: CGImage
        if let imageModificationBlock = imageModificationBlock {
            /*
             UIImage can init from CGImage and CIImage, when it init with CGImage, it's cgImage value will not be nil,
             and this modification block are supposed to just modify the origin image, and return the image with the same type (which are supposed to have cgImage in it).
             so if the block not do that, we'd prefer to crash (And the developer can change the logic when debug) insteaded of return the wrong data.
             */
            image = imageModificationBlock(UIImage(cgImage: cgImage)).cgImage!
        } else {
            image = cgImage
        }
        
        // 2. encode the image with quality and original metadata
        let encodedData = self.encodeCGImage(image, compressOption: compressOption, imageSourceType: imageSourceType, metaData: metaData)
//        RGLogger.info("attempt to get downsized data with imageIO, original size: \(data.sizeInKb)KB", in: .imageIO)
        let elapsed = Date().timeIntervalSince(startTime) * 1000
//        RGLogger.info("get downsized image data with imageIO, elapsed: \(elapsed)ms", in: .imageIO)
        
        if let encodedData = encodedData {
            return encodedData
        } else {
//            RGLogger.info("get downsized image data failed, returning original data", in: .imageIO)
            return data
        }
    }
    
    static func getCGImageAndSource(fromCompressedImageData data: Data,
                                    shortEdgeInPixel: CGFloat? = nil,
                                    longEdgeInPixel: CGFloat? = nil,
                                    totalPixelLimit: CGFloat,
                                    transformImage: Bool = false,
                                    decodeImage: Bool = false) -> (CGImage, CGImageSource)? {
        // see WWDC18 session 219
        let sourceOptions: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
        ]
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary) else {
        
//            RGLogger.error("create CGImageSource failed", in: .imageIO)
            return nil
        }
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any],
            let width = properties[kCGImagePropertyPixelWidth as String] as? CGFloat,
            let height = properties[kCGImagePropertyPixelHeight as String] as? CGFloat else {
        
//            RGLogger.error("get properties from imageSource failed", in: .imageIO)
            return nil
        }
        
//        RGLogger.info("original pixel size width: \(width), height: \(height)", in: .imageIO)
        let originalPixelSize = CGSize(width: width, height: height)
        
        var scaledPixelSize = UIImage.calculatePixelSize(originalPixelSize: originalPixelSize, shortEdge: shortEdgeInPixel, longEdge: longEdgeInPixel)
        if scaledPixelSize.width * scaledPixelSize.height > totalPixelLimit {
            let scale = sqrt(scaledPixelSize.width * scaledPixelSize.height / totalPixelLimit)
            scaledPixelSize = CGSize(width: floor(scaledPixelSize.width / scale), height: floor(scaledPixelSize.height / scale))
        }
        
        // see WWDC18 session 219
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(scaledPixelSize.width, scaledPixelSize.height),
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: transformImage,
            kCGImageSourceShouldCacheImmediately: decodeImage,
        ]
        
//        RGLogger.info("creating thumbnail with scaledSize: \(scaledPixelSize), decodeImage: \(decodeImage)", in: .imageIO)
        guard let resultCGImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            
//            RGLogger.error("failed to call CGImageSourceCreateThumbnailAtIndex with options: \(options)", in: .imageIO)
            return nil
        }
        
        return (resultCGImage, imageSource)
    }
    
    private static func encodeCGImage(_ image: CGImage,
                                      compressOption: CompressOption,
                                      imageSourceType: CFString,
                                      metaData: CGImageMetadata?) -> Data? {
        var destOptions: [String: Any] = [:]
        
        if metaData != nil {
            destOptions[kCGImageMetadataShouldExcludeGPS as String] = true
        }
        
        var compressType: CFString
        let heifType = "public.heic" as CFString
        switch imageSourceType {
        case kUTTypeGIF:
            return encode(image: image, to: kUTTypeGIF, with: metaData, destOptions: destOptions)
        case kUTTypePNG, kUTTypeJPEG:
            // use original image type for png/jpeg/gif
            compressType = imageSourceType
        case heifType:
            // for heic, check if enabled. convert to jpeg if not.
            if enableHEICUpload {
                compressType = imageSourceType
            } else {
                compressType = kUTTypeJPEG
            }
        default:
            // for other image types, qiniu might not support them(Sean said). Just use jpeg.
            compressType = kUTTypeJPEG
        }
        
        switch compressOption {
        case .compressQuality(let compressQuality):
            destOptions[kCGImageDestinationLossyCompressionQuality as String] = compressQuality
            return encode(image: image, to: compressType, with: metaData, destOptions: destOptions)
        case .sizeLimitInKb(let size):
            // Try encode data first.
            destOptions[kCGImageDestinationLossyCompressionQuality as String] = 1.0
            let data = encode(image: image, to: compressType, with: metaData, destOptions: destOptions)
            if let data = data, data.sizeInKb < size {
                return data
            }
            
            // If the encoded png data not fit the size limit, try encoded as jpeg.
            if compressType == kUTTypePNG {
                compressType = kUTTypeJPEG
            }
            
            // Attempt to find the best compress quality.
            var compressQulity = 0.9
            
            while compressQulity > 0 {
                destOptions[kCGImageDestinationLossyCompressionQuality as String] = compressQulity
                let compressedData = encode(image: image, to: compressType, with: metaData, destOptions: destOptions)
                if let compressedData = compressedData, compressedData.sizeInKb < size {
                    return compressedData
                }
                compressQulity -= 0.1
            }
//            RGLogger.error("unable to compress the image data to fit the size limit.", in: .imageIO)
            return data
        }
    }
    
    private static func encode(image: CGImage, to compressType: CFString, with metaData: CGImageMetadata?, destOptions: [String: Any]) -> Data? {
        // encode to data buffer
        let newImageData = NSMutableData()
        if let cgImageDestination = CGImageDestinationCreateWithData(newImageData, compressType, 1, nil) {
            
            CGImageDestinationAddImageAndMetadata(cgImageDestination, image, metaData, destOptions as CFDictionary)
            CGImageDestinationFinalize(cgImageDestination)
            
            let result = newImageData as Data
            var qualityString = "default"
            if let quality = destOptions[kCGImageDestinationLossyCompressionQuality as String] as? Double {
                qualityString = "\(quality)"
            }
//            RGLogger.info("encoding image with type: \(compressType), quality: \(qualityString), to size: \(result)KB", in: .imageIO)
            return newImageData as Data
        } else {
//            RGLogger.error("failed to encode image with type: \(compressType)", in: .imageIO)
            // sometimes encode would fail(heic is not supported before iPhone 7)
            // fallback to jpeg instead
            if compressType != kUTTypeJPEG {
//                RGLogger.warn("fallback to jpeg", in: .imageIO)
                return self.encode(image: image, to: kUTTypeJPEG, with: metaData, destOptions: destOptions)
            } else {
                return nil
            }
        }
    }
    
    public static func getImageDataProperties(_ data: Data) -> [String: Any] {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            
//            RGLogger.error("create CGImageSource failed", in: .imageIO)
            return [:]
        }
        
        return CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] ?? [:]
    }
}
