//
//  SettingsComponents.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//

import SwiftUI

// MARK: - SettingsCard

struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
    }
}

// MARK: - SettingsSectionHeader

struct SettingsSectionHeader: View {
    let label: String
    var hint: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.system(size: 11.5, weight: .semibold))
                .tracking(0.08)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            Spacer()

            if let hint {
                Text(hint)
                    .font(.system(size: 11.5, design: .monospaced))
                    .tracking(0.04)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        .padding(.top, 22)
        .padding(.bottom, 8)
    }
}

// MARK: - SettingsNavRow

struct SettingsNavRow: View {

    let icon: String
    let iconTone: SettingsIconTone
    let label: String
    var value: String? = nil
    var isLink: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            SettingsIconSquare(icon: icon, tone: iconTone)

            Text(label)
                .font(.system(size: 15.5, weight: .medium))
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            if let value {
                Text(value)
                    .font(.system(size: 13.5, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            if isLink {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}

// MARK: - SettingsIconSquare

struct SettingsIconSquare: View {

    let icon: String
    let tone: SettingsIconTone

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(tone.foreground)
            .frame(width: 30, height: 30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(tone.background)
            )
    }
}

// MARK: - SettingsIconTone

enum SettingsIconTone {
    case green, blue, violet, red, neutral

    var background: Color {
        switch self {
        case .green:   return DesignTokens.Color.softGreenTint
        case .blue:    return Color(hex: "#E1ECF4")
        case .violet:  return Color(hex: "#E9E4F2")
        case .red:     return DesignTokens.Color.expenseRed.opacity(0.1)
        case .neutral: return Color(.systemFill)
        }
    }

    var foreground: Color {
        switch self {
        case .green:   return DesignTokens.Color.deepGreen
        case .blue:    return Color(hex: "#2E5878")
        case .violet:  return Color(hex: "#564487")
        case .red:     return DesignTokens.Color.expenseRed
        case .neutral: return Color(.secondaryLabel)
        }
    }
}

// MARK: - Shared types

struct ShareableURL: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct SettingsError: Identifiable {
    let id = UUID()
    let message: String
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
