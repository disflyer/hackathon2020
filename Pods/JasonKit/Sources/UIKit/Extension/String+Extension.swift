//
//  StringExtension.swift
//  Ruguo
//
//  Created by Jason Yu on 8/5/15.
//  Copyright (c) 2015 若友网络科技有限公司. All rights reserved.
//

import UIKit

public enum JKFontWeight {
    case light
    case regular
    case medium
    case semibold
    case bold
    
    @available(iOS 8.2, *)
    var systemFontWeight: CGFloat {
        switch self {
        case .light: return UIFont.Weight.light.rawValue
        case .regular: return UIFont.Weight.regular.rawValue
        case .medium: return UIFont.Weight.medium.rawValue
        case .semibold: return UIFont.Weight.semibold.rawValue
        case .bold: return UIFont.Weight.bold.rawValue
        }
    }
}

public var defaultLineHeightMultiple: CGFloat = 3 / 2

public func lineHeightFrom(fontSize: CGFloat) -> CGFloat {
    return fontSize * defaultLineHeightMultiple
}

public enum TextAttributes: Hashable {
    
    public static let linkAttributeName = NSAttributedString.Key(rawValue: "customLinkAttributeName")
    public static let actionAttributeName = NSAttributedString.Key(rawValue: "customActionAttributeName")
    public static var defaultKerning: CGFloat = 0.2
    case fontSize(CGFloat)
    case color(UIColor)
    case lineSpacing(CGFloat)
    case fontWeight(JKFontWeight)
    case underline(NSUnderlineStyle)
    case underlineColor(UIColor)
    case strikeThrough(NSUnderlineStyle)
    case strikeThroughColor(UIColor)
    case backgroundColor(UIColor)
    /// Shadow color, offset, radius
    case shadow(UIColor, CGSize, CGFloat)
    case align(NSTextAlignment)
    case lineBreakMode(NSLineBreakMode)
    case lineHeight(CGFloat)
    /// Override all the other font related attributes
    case font(UIFont)
    case letterSpacing(CGFloat)
    case baselineOffset(CGFloat)
    case minimumLineHeight(CGFloat)
    case maximumLineHeight(CGFloat)

    public enum BaselineOffsetMode {
        case `default`
        case textField
        case asdk
    }
    case baselineOffsetMode(BaselineOffsetMode)
    public static let baselineOffsetForASDK: TextAttributes = .baselineOffsetMode(.asdk)
    public static let baselineOffsetForTextField: TextAttributes = .baselineOffsetMode(.textField)

    case link(String)
    case action(() -> Void)
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.toString())
    }
    
    // swiftlint:disable:next function_body_length
    public static func from(_ textAttributes: Set<TextAttributes>) -> [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()
        func setParagraphStyle(setParagraphStyleBlock: (NSMutableParagraphStyle) -> Void) {
            let paragraphStyle = (attributes[NSAttributedString.Key.paragraphStyle] as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
            setParagraphStyleBlock(paragraphStyle)
            attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        }
        func setAutoLineHeight() {
            var lineHeight: CGFloat = .nan
            var fontSize: CGFloat = UIFont.systemFontSize
            var baselineOffset: CGFloat = .nan
            var minimumLineHeight: CGFloat = .nan
            var maximumLineHeight: CGFloat = .nan
            var baselineOffsetMode: BaselineOffsetMode = .default
            textAttributes.forEach { textAttribute in
                switch textAttribute {
                case .fontSize(let size):
                    fontSize = size
                case .font(let font):
                    fontSize = font.pointSize
                case .baselineOffset(let offset):
                    baselineOffset = offset
                case .lineHeight(let height):
                    lineHeight = height
                case .minimumLineHeight(let height):
                    minimumLineHeight = height
                case .maximumLineHeight(let height):
                    maximumLineHeight = height
                case .baselineOffsetMode(let mode):
                    baselineOffsetMode = mode
                default: break
                }
            }

            // calculate line height where there's no user defined values
            lineHeight = lineHeight.isNaN ? lineHeightFrom(fontSize: fontSize) : lineHeight
            minimumLineHeight = minimumLineHeight.isNaN ? lineHeight : minimumLineHeight
            maximumLineHeight = maximumLineHeight.isNaN ? lineHeight : maximumLineHeight

            // set line height
            setParagraphStyle {
                $0.lineSpacing = 0
                // $0.lineHeightMultiple = height / fontSize
                $0.minimumLineHeight = minimumLineHeight
                $0.maximumLineHeight = maximumLineHeight
            }

            // calculate baseline offset when there's no user defined values
            if baselineOffset.isNaN { // claculate
                let lineHeightForCalc = baselineOffsetMode == .default
                    ? UIFont.systemFont(ofSize: fontSize).lineHeight
                    : fontSize
                baselineOffset = lineHeight > lineHeightForCalc
                    ? baselineOffsetMode == .textField
                        ? (lineHeight - lineHeightForCalc) / 2
                        : (lineHeight - lineHeightForCalc) / 4
                    : 0

                // visually higher is better (since character like A or 安 will have a lighter head),
                // so we'd better ceil it than round/floor. UIKit can't adopt this adjustment!
                if baselineOffsetMode == .asdk {
                    baselineOffset = ceil(baselineOffset)
                }
            }

            // set baseline offset
            attributes[NSAttributedString.Key.baselineOffset] = baselineOffset
        }

        if shouldUpdateAutoLineheight(for: textAttributes) {
            setAutoLineHeight() // help all attributedStrings to add auto line height
        }

        textAttributes.forEach { textAttribute in
            switch textAttribute {
            case .fontSize(let size):
                // when fontSize is specified(almost every time), see if fontWeight is also there
                var fontWeight = JKFontWeight.regular
                textAttributes.forEach { textAttribute in
                    switch textAttribute {
                    case .fontWeight(let weight): fontWeight = weight
                    default: break
                    }
                }
                
                let font = UIFont.systemFont(ofSize: size, weight: UIFont.Weight(rawValue: fontWeight.systemFontWeight))

                attributes[NSAttributedString.Key.font] = font
            case .color(let color):
                attributes[NSAttributedString.Key.foregroundColor] = color
            case .lineSpacing(let lineSpacing):
                setParagraphStyle { $0.lineSpacing = lineSpacing }
            case .shadow(let color, let offset, let radius):
                let shadow = NSShadow()
                shadow.shadowColor = color
                shadow.shadowOffset = offset
                shadow.shadowBlurRadius = radius
                attributes[NSAttributedString.Key.shadow] = shadow
            case .underline(let underlineStyle):
                attributes[NSAttributedString.Key.underlineStyle] = underlineStyle.rawValue
            case .underlineColor(let color):
                attributes[NSAttributedString.Key.underlineColor] = color
            case .strikeThrough(let style):
                attributes[NSAttributedString.Key.strikethroughStyle] = style.rawValue
            case .strikeThroughColor(let color):
                attributes[NSAttributedString.Key.strikethroughColor] = color
            case .backgroundColor(let color):
                attributes[NSAttributedString.Key.backgroundColor] = color
            case .align(let align):
                setParagraphStyle { $0.alignment = align }
            case .fontWeight: break  // fontWeight is handled in fontSize section
            case .lineBreakMode(let mode):
                setParagraphStyle { $0.lineBreakMode = mode }
            case .font(let font):
                attributes[NSAttributedString.Key.font] = font
            case .link(let linkString):
                attributes[linkAttributeName] = linkString
            case .action(let action):
                attributes[actionAttributeName] = action
            case .letterSpacing(let spacing):
                attributes[NSAttributedString.Key.kern] = spacing
            case .lineHeight,
                 .baselineOffset,
                 .baselineOffsetMode,
                 .minimumLineHeight,
                 .maximumLineHeight:
                // Ignore all line height related set-ups,
                // since they have all properly processed in `setAutoLineHeight`
                break
            }
        }

        return attributes
    }

    public static func stringKeyFrom(_ textAttributes: Set<TextAttributes>) -> [String: Any] {
        return self.from(textAttributes).reduce([:], { (result, kv) in
            var newR = result
            newR[kv.key.rawValue] = kv.value
            return newR
        })
    }
    
    func toString() -> String {
        switch self {
        case .fontSize: return "fontSize"
        case .color: return "color"
        case .lineSpacing: return "lineSpacing"
        case .fontWeight: return "fontWeight"
        case .underline: return "underline"
        case .underlineColor: return "underlineColor"
        case .backgroundColor: return "backgroundColor"
        case .shadow: return "shadow"
        case .align: return "align"
        case .lineBreakMode: return "lineBreakMode"
        case .font: return "font"
        case .link: return "link"
        case .action: return "action"
        case .letterSpacing: return "kern"
        case .lineHeight: return "lineHeight"
        case .baselineOffset: return "baselineOffset"
        case .minimumLineHeight: return "minimumLineHeight"
        case .maximumLineHeight: return "maximumLineHeight"
        case .baselineOffsetMode: return "baselineOffsetMode"
        case .strikeThrough: return "strikeThrough"
        case .strikeThroughColor: return "strikeThroughColor"
        }
    }
}

private func shouldUpdateAutoLineheight(for textAttributes: Set<TextAttributes>) -> Bool {
    var shouldUpdate = false
    textAttributes.forEach { textAttribute in
        switch textAttribute {
        case .font,
             .fontSize,
             .fontWeight,
             .lineHeight,
             .baselineOffset,
             .baselineOffsetForASDK,
             .minimumLineHeight,
             .maximumLineHeight:
            // if contains anyone of these, means auto line height needs to be updated
            shouldUpdate = true
            return
        default:
            break
        }
    }
    return shouldUpdate
}

public func == (lhs: TextAttributes, rhs: TextAttributes) -> Bool {
    return lhs.toString() == rhs.toString()
}

public extension String {
    var length: Int {
        return self.count
    }
    var notEmptyString: String? {
        if isEmpty {
            return nil
        }
        return self
    }
    
    var isLineBreak: Bool {
        return ["\n", "\r", "\n\r", "\r\n"].contains(self)
    }
    
    func limitCharacterCount(_ count: Int) -> String {
        if self.length > count {
            let index: String.Index = self.index(self.startIndex, offsetBy: count)
            return self[..<index] + "..."
        }
        return self
    }
    
    // used when self is the value of a url query parameter
    var stringByAddingPercentEncodingForURLQueryValue: String? {
        // https://www.ietf.org/rfc/rfc3986.txt , "2.3.  Unreserved Characters"
        // Characters that are allowed in a URI but do not have a reserved purpose are called unreserved.  These include uppercase and lowercase letters, decimal digits, hyphen, period, underscore, and tilde.
        var unreservedCharacterSet = CharacterSet.alphanumerics
        unreservedCharacterSet.insert(charactersIn: "-._~")

        return addingPercentEncoding(withAllowedCharacters: unreservedCharacterSet)
    }
    
    func withAttributes(_ textAttributes: Set<TextAttributes>) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: TextAttributes.from(textAttributes))
    }

    func mutableWithAttributes(_ textAttributes: Set<TextAttributes>) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self, attributes: TextAttributes.from(textAttributes))
    }
    
    func versionToInt() -> [Int] {
        return self.components(separatedBy: ".")
            .map {
                Int.init($0) ?? 0
        }
    }
    
    func isLaterThanVersion(_ version: String) -> Bool {
        let selfVersionArray = self.versionToInt()
        let targetVersionArray = version.versionToInt()
        
        let longer = max(selfVersionArray.count, targetVersionArray.count)
        for i in 0..<longer {
            if i >= selfVersionArray.count {
                return false
            } else if i >= targetVersionArray.count {
                return true
            }
            let result = (selfVersionArray[i]) - (targetVersionArray[i])
            if result > 0 {
                return true
            } else if result < 0 {
                return false
            }
        }
        
        // is equal
        return false
    }

    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
    
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
        
        return results.map { result in
            (0..<result.numberOfRanges).map { index in
                let range = result.range(at: index)
                if range.location != NSNotFound {
                    let capturedString = nsString.substring(with: range)
                    return capturedString
                }
                return ""
            }
        }
    }
    
    func unsupportedCharacterIndices(fontName: String, fontSize: CGFloat) -> [String.Index] {
        return self.indices.filter { index in
            let ctFont = CTFontCreateWithName(fontName as CFString, fontSize, nil)
            let str = String(self[index])
            let chars = Array(str.utf16)
            var glyphs = [CGGlyph](repeating: 0, count: chars.count)
            return !CTFontGetGlyphsForCharacters(ctFont, chars, &glyphs, glyphs.count)
        }
    }
}

public extension NSAttributedString {
    var fullRange: NSRange {
        let nsString = self.string as NSString
        return NSRange(location: 0, length: nsString.length)
    }
    
    func addAttributes(_ textAttributes: Set<TextAttributes>) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.addAttributes(TextAttributes.from(textAttributes), range: fullRange)
        return mutable
    }

    func addAttributesForLinks(_ textAttributes: Set<TextAttributes>) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: self)

        let attrDict = TextAttributes.from(textAttributes)

        mutable.enumerateAttribute(TextAttributes.linkAttributeName, in: fullRange, options: []) { (link, range, _) in
            if link != nil {
                mutable.addAttributes(attrDict, range: range)
            }
        }
        return mutable
    }

    func addAttributesForActions(_ textAttributes: Set<TextAttributes>) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: self)

        let attrDict = TextAttributes.from(textAttributes)

        mutable.enumerateAttribute(TextAttributes.actionAttributeName, in: fullRange, options: []) { (action, range, _) in
            if action != nil {
                mutable.addAttributes(attrDict, range: range)
            }
        }
        return mutable
    }
    
    /// The desired effect is using current font whenever the code point is supported. When the code point is not supported, use fallback font instead.
    /// However, if simply set `UIFontDescriptor.AttributeName.cascadeList` as fallback font, the fallback font may be used once triggered fallback until dealing with a code point that it can not display.
    /// This seems a bug in the font fallback mechanism.
    /// Therefore, this function uses a workaround that only using fallback font when the glyph is not supported in current font.
    /// ref to: https://stackoverflow.com/questions/21299337/ios-how-can-i-set-a-fallback-font-for-my-custom-font
    func fallback(font: UIFont) -> NSAttributedString {
        let string = self.string
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        
        var currentFont = UIFont.systemFont(ofSize: font.pointSize)
        self.enumerateAttribute(NSAttributedString.Key.font, in: fullRange, options: []) { (value, _, _) in
            if let font = value as? UIFont {
                currentFont = font
            }
        }
        
        var attributes = [NSAttributedString.Key: Any]()
        attributes[NSAttributedString.Key.font] = font
        string.unsupportedCharacterIndices(fontName: currentFont.fontName, fontSize: currentFont.pointSize).forEach { index in
            let sRange = string.index(index, offsetBy: 0)..<string.index(index, offsetBy: 1)
            let range = NSRange(sRange, in: string)
            mutableAttributedString.addAttributes(attributes, range: range)
        }
        return mutableAttributedString
    }
}

public extension NSMutableAttributedString {
    func tap(block: (NSMutableAttributedString) -> Void) -> NSMutableAttributedString {
        block(self)
        return self
    }
}

public extension Array where Element: NSAttributedString {
    func joined(separator: String) -> NSAttributedString {
        let mutable = NSMutableAttributedString()
        for (index, attrString) in self.enumerated() {
            if index > 0 {
                mutable.append(NSAttributedString(string: separator))
            }
            mutable.append(attrString)
        }
        return mutable
    }
}

public func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSMutableAttributedString {
    let mutable = NSMutableAttributedString(attributedString: lhs)
    mutable.append(rhs)
    return mutable
}

public func + (lhs: NSAttributedString, rhs: String) -> NSMutableAttributedString {
    let mutable = NSMutableAttributedString(attributedString: lhs)
    mutable.append(NSAttributedString(string: rhs))
    return mutable
}

public func + (lhs: String, rhs: NSAttributedString) -> NSMutableAttributedString {
    let mutable = NSMutableAttributedString(string: lhs)
    mutable.append(rhs)
    return mutable
}

