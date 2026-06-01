//
//  OnboardingScreen5Import.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

// MARK: - Screen 5: Import

struct OnboardingScreen5Import: View {
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.horizontal, OSpacing.xl)
                    .padding(.bottom, OSpacing.xl)

                PDFPreviewCard()
                    .padding(.horizontal, OSpacing.xl)
                    .padding(.bottom, OSpacing.xl)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.97)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: appeared)
                    .accessibilityHidden(true)

                privacyBanner
                    .padding(.horizontal, OSpacing.xl)
            }
            .padding(.top, OSpacing.lg)
            .padding(.bottom, OSpacing.lg)
        }
        .onAppear { appeared = true }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: OSpacing.sm) {
            Text("Import your first statement")
                .font(OFont.sectionTitle)
                .tracking(-0.3)

            Text("Open the M-Pesa app, tap My Account → M-Pesa Statement, choose a date range, and tap Send. Safaricom emails you the PDF.")
                .font(OFont.body)
                .foregroundStyle(Color(.secondaryLabel))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var privacyBanner: some View {
        HStack(spacing: OSpacing.sm) {
            Image(systemName: "lock.fill")
                .font(.system(size: OnboardingConstants.bannerIconSize, weight: .medium))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            Text("Your PDF is processed on this device only. It is never uploaded or shared.")
                .font(OFont.caption)
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding(OSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("GreenTint"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

// MARK: - PDF preview mockup

private struct PDFPreviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            fileHeader.padding(.bottom, OSpacing.lg)
            contentLines.padding(.bottom, OSpacing.lg)
            cardFooter
        }
        .padding(OSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(.separator), lineWidth: 0.5)
                )
        )
        .frame(maxWidth: .infinity)
    }

    private var fileHeader: some View {
        HStack(spacing: OSpacing.md) {
            Image(systemName: "doc.fill")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(Color(.systemRed))

            VStack(alignment: .leading, spacing: OSpacing.xs) {
                Text("MPESA_STATEMENT_MAY_2026.pdf")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.label))
                    .lineLimit(1)
                    .truncationMode(.middle)
                HStack(spacing: OSpacing.xs) {
                    Text("PDF")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(.systemRed)))
                    Text("64 KB")
                        .font(OFont.caption)
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }
        }
    }

    private var contentLines: some View {
        VStack(alignment: .leading, spacing: OSpacing.xs) {
            documentLine(trailingPad: 0)
            documentLine(trailingPad: OSpacing.xl)
            documentLine(trailingPad: OSpacing.md)
            documentLine(trailingPad: OSpacing.xxxl)
        }
    }

    private func documentLine(trailingPad: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color(.separator))
            .frame(height: 7)
            .padding(.trailing, trailingPad)
    }

    private var cardFooter: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("TRANSACTIONS")
                    .font(.system(size: 10, weight: .semibold).uppercaseSmallCaps())
                    .foregroundStyle(Color(.tertiaryLabel))
                Text("KES 48,210")
                    .font(.system(size: 17, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Color(.label))
            }
            Spacer()
            Text("Pesa Tracker")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, OSpacing.sm + OSpacing.xs)
                .padding(.vertical, OSpacing.xs + 2)
                .background(
                    Capsule()
                        .fill(Color("GreenTint"))
                        .overlay(Capsule().strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 0.5))
                )
        }
    }
}
