//
//  TapticEngine.swift
//  AppCore
//
//  Created by Luminoid on 2019/2/22.
//  Copyright © 2019 若友网络科技有限公司. All rights reserved.
//

import UIKit

public class TapticEngine {
    // Use `#available(iOS 10.0.1, *)`
    // ref: https://stackoverflow.com/questions/40270596/uifeedbackgenerator-object-creation-crashes-on-ios-10-0
    @available(iOS 10.0.1, *)
    private static let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)

    @available(iOS 10.0.1, *)
    private static let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)

    @available(iOS 10.0.1, *)
    private static let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)

    @available(iOS 10.0.1, *)
    private static let selectionGenerator = UISelectionFeedbackGenerator()

    @available(iOS 10.0.1, *)
    private static var notificationGenerator = UINotificationFeedbackGenerator()

    public enum ImpactFeedbackGeneratorStyle {
        case light, medium, heavy
    }

    public enum NotificationFeedbackGeneratorType {
        case success, warning, error
    }

    public enum FeedbackGeneratorType {
        case impact(type: ImpactFeedbackGeneratorStyle)
        case selection
        case notification(type: NotificationFeedbackGeneratorType)
    }

    @available(iOS 10.0.1, *)
    private static func getGenerator(of type: FeedbackGeneratorType) -> UIFeedbackGenerator {
        switch type {
        case .impact(type: .light):
            return lightImpactGenerator
        case .impact(type: .medium):
            return mediumImpactGenerator
        case .impact(type: .heavy):
            return heavyImpactGenerator
        case .selection:
            return selectionGenerator
        case .notification:
            return notificationGenerator
        }
    }

    public static func prepare(type: FeedbackGeneratorType) {
        guard #available(iOS 10.0.1, *) else { return }

        let generator = getGenerator(of: type)
        generator.prepare()
    }

    public static func trigger(type: FeedbackGeneratorType = .impact(type: .light)) {
        guard #available(iOS 10.0.1, *) else { return }

        let generator = getGenerator(of: type)
        switch type {
        case .impact:
            (generator as? UIImpactFeedbackGenerator)?.impactOccurred()
        case .selection:
            (generator as? UISelectionFeedbackGenerator)?.selectionChanged()
        case .notification(type: .success):
            (generator as? UINotificationFeedbackGenerator)?.notificationOccurred(.success)
        case .notification(type: .warning):
            (generator as? UINotificationFeedbackGenerator)?.notificationOccurred(.warning)
        case .notification(type: .error):
            (generator as? UINotificationFeedbackGenerator)?.notificationOccurred(.error)
        }
    }
}
