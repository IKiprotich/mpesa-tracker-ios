//
//  OnboardingScreen5Import.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

// MARK: - Screen 5: Import

struct OnboardingScreen5Import: View {
    @State private var cardAppeared    = false
    @State private var contentAppeared = false
    @State private var stepsAppeared   = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                //PDF → App transformation illustration
                TransformationIllustration(appeared: cardAppeared)
                    .frame(height: 180)
                    .padding(.horizontal, OSpacing.xl)
                    .padding(.top, OSpacing.lg)
                    .accessibilityHidden(true)

                // Headline
                headlineBlock
                    .padding(.horizontal, OSpacing.xl)
                    .padding(.top, OSpacing.xl)

                // How to get the PDF
                howToSection
                    .padding(.horizontal, OSpacing.xl)
                    .padding(.top, OSpacing.lg)

                // Privacy note
                privacyNote
                    .padding(.horizontal, OSpacing.xl)
                    .padding(.top, OSpacing.md)

                // Clear the bottom button stack
                Color.clear.frame(height: 140)
            }
            .padding(.bottom, OSpacing.xl)
        }
        .onAppear {
            cardAppeared = true
            withAnimation(.spring(response: 0.52, dampingFraction: 0.82).delay(0.18)) {
                contentAppeared = true
            }
            withAnimation(.spring(response: 0.52, dampingFraction: 0.82).delay(0.30)) {
                stepsAppeared = true
            }
        }
    }

    // MARK: Headline

    private var headlineBlock: some View {
        VStack(alignment: .leading, spacing: OSpacing.sm) {
            Text("Import your\nfirst statement.")
                .font(.system(size: 34, weight: .semibold))
                .tracking(-0.6)
                .foregroundStyle(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 16)
                .animation(.spring(response: 0.52, dampingFraction: 0.82).delay(0.18), value: contentAppeared)

            Text("Pick the PDF from Files. We read it on-device — nothing leaves your phone.")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color(.secondaryLabel))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 12)
                .animation(.spring(response: 0.52, dampingFraction: 0.82).delay(0.26), value: contentAppeared)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: How-to steps

    private var howToSection: some View {
        VStack(spacing: 0) {
            // Section label
            HStack {
                Text("HOW TO GET YOUR PDF")
                    .font(OFont.label)
                    .foregroundStyle(Color("GreenDeep"))
                Spacer()
            }
            .padding(.bottom, OSpacing.md)
            .opacity(stepsAppeared ? 1 : 0)
            .animation(.easeInOut(duration: 0.25).delay(0.30), value: stepsAppeared)

            // Steps card
            VStack(spacing: 0) {
                ForEach(Array(ImportStep.all.enumerated()), id: \.offset) { index, step in
                    ImportStepRow(step: step, isLast: index == ImportStep.all.count - 1)
                        .opacity(stepsAppeared ? 1 : 0)
                        .offset(y: stepsAppeared ? 0 : 12)
                        .animation(
                            .spring(response: 0.48, dampingFraction: 0.82)
                            .delay(0.32 + Double(index) * 0.07),
                            value: stepsAppeared
                        )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color(.separator), lineWidth: 0.5)
            )
        }
    }

    // MARK: Privacy note

    private var privacyNote: some View {
        HStack(spacing: OSpacing.sm) {
            Image(systemName: "lock.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            Text("Processed on-device only. Never uploaded or shared.")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color(.secondaryLabel))

            Spacer(minLength: 0)
        }
        .padding(.horizontal, OSpacing.md)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentColor.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.accentColor.opacity(0.18), lineWidth: 0.75)
                )
        )
        .opacity(stepsAppeared ? 1 : 0)
        .animation(.easeInOut(duration: 0.25).delay(0.6), value: stepsAppeared)
    }
}

// MARK: - Import step data

private struct ImportStep {
    let number: String
    let instruction: String
    let detail: String

    static let all: [ImportStep] = [
        ImportStep(
            number: "1",
            instruction: "Open M-Pesa → Statements",
            detail: "Tap the M-Pesa icon, then 'M-Pesa Statement'. Choose 'Email Statement'."
        ),
        ImportStep(
            number: "2",
            instruction: "Pick a date range",
            detail: "Last 1 month is usually enough. Enter your ID number to confirm."
        ),
        ImportStep(
            number: "3",
            instruction: "Save the PDF Safaricom sends you",
            detail: "Open the email on your iPhone, tap the PDF attachment, then Share → Save to Files."
        )
    ]
}

// MARK: - Import step row

private struct ImportStepRow: View {
    let step: ImportStep
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: OSpacing.md) {
            // Number badge
            Text(step.number)
                .font(.system(size: 12, weight: .bold).monospacedDigit())
                .foregroundStyle(Color.accentColor)
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.accentColor.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(step.instruction)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(.label))
                Text(step.detail)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, OSpacing.md)
        .padding(.vertical, OSpacing.md)
        .overlay(alignment: .bottom) {
            if !isLast {
                Divider().padding(.leading, 58)
            }
        }
    }
}

// MARK: - Transformation illustration

private struct TransformationIllustration: View {
    let appeared: Bool

    var body: some View {
        HStack(spacing: 0) {
            // PDF file card
            pdfCard
                .opacity(appeared ? 1 : 0)
                .offset(x: appeared ? 0 : -20)
                .animation(.spring(response: 0.58, dampingFraction: 0.80), value: appeared)

            // Arrow connector
            arrowConnector
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.6)
                .animation(.spring(response: 0.48, dampingFraction: 0.75).delay(0.22), value: appeared)

            // App result card
            resultCard
                .opacity(appeared ? 1 : 0)
                .offset(x: appeared ? 0 : 20)
                .animation(.spring(response: 0.58, dampingFraction: 0.80).delay(0.1), value: appeared)
        }
        .frame(maxWidth: .infinity)
    }

    // PDF card

    private var pdfCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // PDF badge row
            HStack(spacing: 6) {
                Text("PDF")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color(.systemRed)))
                Text("64 KB")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(.secondaryLabel))
                Spacer()
            }
            .padding(.bottom, 8)

            // Filename
            Text("MPESA_STATEMENT\n_MAY_2026.pdf")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(.label))
                .lineLimit(2)
                .padding(.bottom, 10)

            // Skeleton lines
            VStack(spacing: 5) {
                skeletonLine(width: 1.0)
                skeletonLine(width: 0.75)
                skeletonLine(width: 0.88)
                skeletonLine(width: 0.55)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(.separator), lineWidth: 0.5)
                )
        )
    }

    private func skeletonLine(width: CGFloat) -> some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(.separator))
                .frame(width: geo.size.width * width, height: 6)
        }
        .frame(height: 6)
    }

    // Arrow connector

    private var arrowConnector: some View {
        VStack(spacing: 4) {
            Image(systemName: "arrow.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.accentColor)
            Text("parsed")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 8)
    }

    //  Result card

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App label row
            HStack(spacing: 5) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.accentColor)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 7, weight: .medium))
                            .foregroundStyle(.white)
                    )
                Text("Pesa Tracker")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(.label))
                Spacer()
            }
            .padding(.bottom, 8)

            // Amount
            Text("KES 48,210")
                .font(.system(size: 17, weight: .semibold).monospacedDigit())
                .foregroundStyle(Color(.label))
                .tracking(-0.3)
                .padding(.bottom, 2)

            Text("TOTAL OUT · MAY 2026")
                .font(.system(size: 9, weight: .semibold).uppercaseSmallCaps())
                .foregroundStyle(Color(.tertiaryLabel))
                .padding(.bottom, 10)

            // Mini category bars
            VStack(spacing: 4) {
                categoryBar(label: "Food", width: 0.72, color: Color(red: 0.88, green: 0.64, blue: 0.35))
                categoryBar(label: "Transport", width: 0.44, color: Color(red: 0.31, green: 0.56, blue: 0.71))
                categoryBar(label: "Utilities", width: 0.58, color: Color(red: 0.55, green: 0.48, blue: 0.72))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func categoryBar(label: String, width: CGFloat, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(Color(.tertiaryLabel))
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(0.5))
                    .frame(width: geo.size.width * width, height: 5)
            }
            .frame(height: 5)
        }
    }
}

// MARK: - Previews

#Preview("Screen 5 Import — Light") {
    OnboardingScreen5Import()
        .preferredColorScheme(.light)
}

#Preview("Screen 5 Import — Dark") {
    OnboardingScreen5Import()
        .preferredColorScheme(.dark)
}

#Preview("Screen 5 Import — Scrolled") {
    ScrollView {
        OnboardingScreen5Import()
    }
    .preferredColorScheme(.light)
}
