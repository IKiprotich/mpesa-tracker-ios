//
//  DesignTokens.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 24/05/2026.
//

import SwiftUI

// MARK: - DesignTokens

enum DesignTokens {

    // MARK: - Colour

    enum Color {
        // #00A651 — primary actions, income amounts, positive deltas
        static let primaryGreen     = SwiftUI.Color(hex: "#00A651")

        // #006837 — hero numbers, headers, FAB background
        static let deepGreen        = SwiftUI.Color(hex: "#006837")

        // #E8F5EE — income card tint, success state backgrounds
        static let softGreenTint    = SwiftUI.Color(hex: "#E8F5EE")

        // #DC2626 — outgoing amounts and negative deltas only
        static let expenseRed       = SwiftUI.Color(hex: "#DC2626")

        // #1A1A1A — primary text; never pure black
        static let charcoal         = SwiftUI.Color(hex: "#1A1A1A")

        // #6B7280 — captions, metadata, timestamps
        static let secondary        = SwiftUI.Color(hex: "#6B7280")

        // #FAFAFA / #0F0F0F — app background per theme
        static let backgroundLight  = SwiftUI.Color(hex: "#FAFAFA")
        static let backgroundDark   = SwiftUI.Color(hex: "#0F0F0F")

        // #FFFFFF / #1C1C1E — card surface per theme
        static let cardLight        = SwiftUI.Color.white
        static let cardDark         = SwiftUI.Color(hex: "#1C1C1E")

        // #EFEFEC / #2A2A2C — hairline borders per theme
        static let hairlineLight    = SwiftUI.Color(hex: "#EFEFEC")
        static let hairlineDark     = SwiftUI.Color(hex: "#2A2A2C")
    }

    // MARK: - Category palette

    enum CategoryColor {
        static let food         = SwiftUI.Color(hex: "#E0A458")  // warm sand
        static let transport    = SwiftUI.Color(hex: "#4F8FB4")  // dusty blue
        static let utilities    = SwiftUI.Color(hex: "#8B7AB8")  // soft violet
        static let airtime      = SwiftUI.Color(hex: "#C97C7C")  // muted coral
        static let shopping     = SwiftUI.Color(hex: "#6FA08C")  // sage
        static let bills        = SwiftUI.Color(hex: "#B8956A")  // taupe
        static let personal     = SwiftUI.Color(hex: "#D4A5C9")  // dusty pink
        static let other        = SwiftUI.Color(hex: "#9AA0A6")  // neutral
    }

    // MARK: - Radius

    enum Radius {
        static let card:    CGFloat = 18
        static let chip:    CGFloat = 999
        static let avatar:  CGFloat = 13
        static let button:  CGFloat = 14
    }

    // MARK: - Spacing

    enum Spacing {
        static let screenHorizontal: CGFloat = 20
        static let cardPadding:      CGFloat = 20
        static let sectionGap:       CGFloat = 14
    }
}

// MARK: - Color hex initialiser

extension SwiftUI.Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
