//
//  HapticFeedback.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 22/05/2026.
//


import UIKit

enum HapticFeedback {

    // MARK: - Notification haptics

    static func success() {
        notify(.success)
    }

    static func error() {
        notify(.error)
    }

    // MARK: - Impact haptics

    static func light() {
        impact(.light)
    }

    static func medium() {
        impact(.medium)
    }

    // MARK: - Private helpers

    private static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        Task { @MainActor in
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }

    private static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        Task { @MainActor in
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
}
