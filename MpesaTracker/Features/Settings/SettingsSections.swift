//
//  SettingsSections.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//

import SwiftUI

// MARK: - DataSection

struct DataSection: View {

    let isExporting: Bool
    let onExport: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(label: "Data")

            SettingsCard {
                Button(action: onExport) {
                    HStack {
                        SettingsNavRow(
                            icon: "square.and.arrow.up",
                            iconTone: .green,
                            label: "Export as CSV"
                        )
                        if isExporting {
                            ProgressView()
                                .padding(.trailing, 18)
                        }
                    }
                }
                .disabled(isExporting)
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - AboutSection

struct AboutSection: View {

    let version: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(label: "About")

            SettingsCard {
                SettingsNavRow(icon: "info.circle", iconTone: .neutral, label: "Version", value: version)

                Divider().padding(.leading, 60)

                SettingsNavRow(icon: "lock.shield", iconTone: .green, label: "Privacy policy", isLink: true)

                Divider().padding(.leading, 60)

                SettingsNavRow(icon: "star", iconTone: .neutral, label: "Rate Pesa Tracker", isLink: true)

                Divider().padding(.leading, 60)

                SettingsNavRow(icon: "envelope", iconTone: .neutral, label: "Send feedback", isLink: true)
            }
        }
    }
}

// MARK: - DangerSection

struct DangerSection: View {

    let onClearData: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(label: "Danger zone")

            SettingsCard {
                Button(action: onClearData) {
                    HStack(spacing: 14) {
                        SettingsIconSquare(icon: "trash", tone: .red)

                        Text("Clear all data")
                            .font(.system(size: 15.5, weight: .semibold))
                            .foregroundStyle(DesignTokens.Color.expenseRed)

                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }

            Text("Removes every statement and parsed transaction from this device. Can't be undone.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineSpacing(2)
                .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
                .padding(.top, 10)
        }
    }
}
