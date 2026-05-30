//
//  ThemeManager.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 30/05/2026.
//

import SwiftUI

// MARK: - ThemePreference

enum ThemePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
}

// MARK: - ThemeManager

@Observable
final class ThemeManager {

    static let shared = ThemeManager()

    private static let defaultsKey = "themePreference"

    var preference: ThemePreference {
        didSet {
            UserDefaults.standard.set(preference.rawValue, forKey: Self.defaultsKey)
        }
    }

    /// Resolves the stored preference to a SwiftUI color scheme.
    /// `nil` defers to the system setting.
    var colorScheme: ColorScheme? {
        switch preference {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    private init() {
        let stored = UserDefaults.standard.string(forKey: Self.defaultsKey)
        preference = stored.flatMap(ThemePreference.init) ?? .system
    }
}
