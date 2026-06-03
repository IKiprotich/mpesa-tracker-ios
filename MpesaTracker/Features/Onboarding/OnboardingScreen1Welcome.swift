//
//  OnboardingScreen1Welcome.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

// MARK: - Screen 1: Welcome

struct OnboardingScreen1Welcome: View {
    @State private var cardAppeared    = false
    @State private var headlineAppeared = false
    @State private var pillsAppeared   = false

    var body: some View {
        VStack(spacing: 0) {

            //  Illustration
            AppPreviewIllustration()
                .padding(.horizontal, OSpacing.xl)
                .padding(.top, OSpacing.lg)
                .opacity(cardAppeared ? 1 : 0)
                .offset(y: cardAppeared ? 0 : 28)
                .animation(
                    .spring(response: 0.65, dampingFraction: 0.82),
                    value: cardAppeared
                )
                .accessibilityHidden(true)

            //  Headline
            headlineBlock
                .padding(.horizontal, OSpacing.xl)
                .padding(.top, OSpacing.xl)

            //  Pills
            FeaturePillRow(appeared: pillsAppeared)
                .padding(.horizontal, OSpacing.xl)
                .padding(.top, OSpacing.lg)

            Spacer(minLength: 0)
        }
        .onAppear {
            cardAppeared = true
            withAnimation(
                .spring(response: 0.55, dampingFraction: 0.8)
                .delay(0.22)
            ) { headlineAppeared = true }
            withAnimation(
                .spring(response: 0.55, dampingFraction: 0.8)
                .delay(0.42)
            ) { pillsAppeared = true }
        }
    }

    // MARK: Headline

    private var headlineBlock: some View {
        VStack(alignment: .leading, spacing: OSpacing.sm) {
            Text("Your M-Pesa.\nFinally make sense of it.")
                .font(.system(size: 34, weight: .semibold, design: .default))
                .tracking(-0.6)
                .foregroundStyle(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
                .opacity(headlineAppeared ? 1 : 0)
                .offset(y: headlineAppeared ? 0 : 18)
                .animation(
                    .spring(response: 0.55, dampingFraction: 0.8).delay(0.22),
                    value: headlineAppeared
                )

            Text("Paste in your M-Pesa statement. See every transaction sorted, totalled, and charted. Takes about a minute.")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color(.secondaryLabel))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(headlineAppeared ? 1 : 0)
                .offset(y: headlineAppeared ? 0 : 14)
                .animation(
                    .spring(response: 0.55, dampingFraction: 0.8).delay(0.32),
                    value: headlineAppeared
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - App preview illustration

private struct AppPreviewIllustration: View {
    var body: some View {
        VStack(spacing: 0) {
            // Status bar hint
            HStack {
                Text("Pesa Tracker")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.label))
                Spacer()
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.accentColor)
            }
            .padding(.horizontal, OSpacing.md)
            .padding(.top, OSpacing.md)
            .padding(.bottom, OSpacing.sm)

            Divider().opacity(0.4)

            // Category row
            categoryRow
                .padding(.horizontal, OSpacing.md)
                .padding(.vertical, OSpacing.sm + 2)

            Divider().opacity(0.4)

            // Spend block
            spendBlock
                .padding(.horizontal, OSpacing.md)
                .padding(.vertical, OSpacing.md)

            Divider().opacity(0.4)

            // Transaction row
            transactionRow
                .padding(.horizontal, OSpacing.md)
                .padding(.vertical, OSpacing.sm + 2)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
        )
        .shadow(color: Color(.label).opacity(0.07), radius: 20, x: 0, y: 6)
    }

    // Subviews

    private var categoryRow: some View {
        HStack(spacing: OSpacing.sm) {
            // Mini donut hint
            ZStack {
                Circle()
                    .stroke(Color.accentColor.opacity(0.15), lineWidth: 5)
                    .frame(width: 28, height: 28)
                Circle()
                    .trim(from: 0, to: 0.42)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 28, height: 28)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text("BY CATEGORY")
                    .font(.system(size: 9, weight: .semibold).uppercaseSmallCaps())
                    .foregroundStyle(Color(.tertiaryLabel))
                Text("4 areas")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(.secondaryLabel))
            }

            Spacer()

            // Income badge
            HStack(spacing: 3) {
                Text("+1,500 in")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.accentColor.opacity(0.6))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(Color("GreenTint"))
            )
        }
    }

    private var spendBlock: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                Text("SPENT IN MAY")
                    .font(.system(size: 9, weight: .semibold).uppercaseSmallCaps())
                    .foregroundStyle(Color(.tertiaryLabel))

                Text("KES 48,210")
                    .font(.system(size: 26, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Color(.label))
                    .tracking(-0.5)

                HStack(spacing: 5) {
                    HStack(spacing: 2) {
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 8, weight: .bold))
                        Text("12% vs Apr")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(Color(.systemRed))

                    Text("·")
                        .foregroundStyle(Color(.tertiaryLabel))
                    Text("21 transactions")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }

            Spacer()

            // Tiny spark bars — decorative
            HStack(alignment: .bottom, spacing: 3) {
                ForEach([0.45, 0.7, 0.55, 0.9, 0.65, 1.0, 0.8], id: \.self) { h in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor.opacity(0.18 + h * 0.3))
                        .frame(width: 4, height: 28 * h)
                }
            }
            .frame(height: 28)
            .accessibilityHidden(true)
        }
    }

    private var transactionRow: some View {
        HStack(spacing: OSpacing.sm) {
            // Merchant icon
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(.systemOrange).opacity(0.12))
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: "cart.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(.systemOrange))
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text("Naivas Westlands")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(.label))
                Text("BIGGEST TX")
                    .font(.system(size: 9, weight: .semibold).uppercaseSmallCaps())
                    .foregroundStyle(Color(.tertiaryLabel))
            }

            Spacer()

            Text("−7,840")
                .font(.system(size: 15, weight: .semibold).monospacedDigit())
                .foregroundStyle(Color(.systemRed))
        }
    }
}

// MARK: - Feature pills

private struct FeaturePillRow: View {
    let appeared: Bool

    private let pills: [(icon: String, label: String)] = [
        ("doc.fill",       "PDF import"),
        ("bolt.fill",      "Auto-categorised"),
        ("chart.bar.fill", "Smart charts")
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: OSpacing.sm) {
                ForEach(Array(pills.enumerated()), id: \.offset) { index, pill in
                    PillView(icon: pill.icon, label: pill.label)
                        .fixedSize()
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.88)
                        .animation(
                            .spring(response: 0.45, dampingFraction: 0.75)
                            .delay(Double(index) * 0.07),
                            value: appeared
                        )
                }
            }
        }
    }
}

private struct PillView: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.accentColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color("GreenTint"))
                .overlay(
                    Capsule().strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 0.75)
                )
        )
    }
}

// MARK: - Previews

#Preview("Screen 1 Welcome — Light") {
    OnboardingScreen1Welcome()
        .preferredColorScheme(.light)
}

#Preview("Screen 1 Welcome — Dark") {
    OnboardingScreen1Welcome()
        .preferredColorScheme(.dark)
}
