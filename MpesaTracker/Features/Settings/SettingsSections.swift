//
//  SettingsSections.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//

import SwiftUI
import MessageUI

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
                            iconTone: .neutral,
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
    @Environment(\.openURL) private var openURL
    @State private var showMailCompose = false

    private let privacyURL = URL(string: "https://ikiprotich.github.io/pesa-tracker-legal/")!
    private let termsURL   = URL(string: "https://ikiprotich.github.io/pesa-tracker-legal/#terms")!

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(label: "About")

            SettingsCard {
                SettingsNavRow(icon: "info.circle", iconTone: .neutral, label: "Version", value: version)

                Divider().padding(.leading, 60)

                Button { openURL(privacyURL) } label: {
                    SettingsNavRow(icon: "lock.shield", iconTone: .neutral, label: "Privacy Policy", isLink: true)
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 60)

                Button { openURL(termsURL) } label: {
                    SettingsNavRow(icon: "doc.text", iconTone: .neutral, label: "Terms of Use", isLink: true)
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 60)

                SettingsNavRow(icon: "star", iconTone: .neutral, label: "Rate Pesa Tracker", isLink: true)

                Divider().padding(.leading, 60)

                Button { openContactMail() } label: {
                    SettingsNavRow(icon: "envelope", iconTone: .neutral, label: "Contact Support", isLink: true)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showMailCompose) {
            MailComposeView(toAddress: "ikiprotichian@gmail.com", subject: "Pesa Tracker \u{2014} Feedback")
        }
    }

    private func openContactMail() {
        if MFMailComposeViewController.canSendMail() {
            showMailCompose = true
        } else {
            openURL(URL(string: "mailto:ikiprotichian@gmail.com?subject=Pesa%20Tracker%20%E2%80%94%20Feedback")!)
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
