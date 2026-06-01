//
//  OnboardingScreen1Welcome.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

// MARK: - Screen 1: Welcome

struct OnboardingScreen1Welcome: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            DashboardPreviewCard()
                .padding(.horizontal, OSpacing.xl)
                .padding(.bottom, OSpacing.xl)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1.0 : 0.95)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8).delay(0.1),
                    value: appeared
                )
                .accessibilityHidden(true)

            headlineBlock
                .padding(.horizontal, OSpacing.xl)
                .padding(.bottom, OSpacing.md)

            WelcomeFeaturePills(appeared: appeared)
                .padding(.horizontal, OSpacing.xl)

            Spacer(minLength: 0)
        }
        .onAppear { appeared = true }
    }

    private var headlineBlock: some View {
        VStack(spacing: OSpacing.sm) {
            Text("Your M-Pesa money, finally clear")
                .font(OFont.heroTitle)
                .tracking(-0.5)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(
                    .spring(response: OnboardingConstants.springResponse, dampingFraction: OnboardingConstants.springDamping)
                        .delay(0.25),
                    value: appeared
                )

            Text("Import your statement once. See exactly where every shilling went.")
                .font(OFont.body)
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(
                    .spring(response: OnboardingConstants.springResponse, dampingFraction: OnboardingConstants.springDamping)
                        .delay(0.38),
                    value: appeared
                )
        }
    }
}

// MARK: - Dashboard preview card

private struct DashboardPreviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topRow.padding(.bottom, OSpacing.xs)
            Text("4 areas").font(OFont.caption).foregroundStyle(Color(.tertiaryLabel)).padding(.bottom, OSpacing.md)
            spentSection.padding(.bottom, OSpacing.md)
            biggestTransaction
        }
        .padding(OSpacing.lg)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
        )
        .frame(maxWidth: .infinity)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.secondarySystemBackground))
            .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }

    private var topRow: some View {
        HStack {
            Text("BY CATEGORY")
                .font(.system(size: 11, weight: .semibold).uppercaseSmallCaps())
                .foregroundStyle(Color(.tertiaryLabel))
            Spacer()
            HStack(spacing: OSpacing.xs) {
                Text("+1,500 in")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.accentColor)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .padding(.horizontal, OSpacing.sm)
            .padding(.vertical, OSpacing.xs)
            .background(Capsule().fill(Color("GreenTint")))
        }
    }

    private var spentSection: some View {
        VStack(alignment: .leading, spacing: OSpacing.xs) {
            Text("SPENT IN MAY")
                .font(.system(size: 11, weight: .semibold).uppercaseSmallCaps())
                .foregroundStyle(Color(.tertiaryLabel))
            Text("KES 48,210")
                .font(.system(size: 32, weight: .semibold).monospacedDigit())
                .foregroundStyle(Color(.label))
                .tracking(-0.5)
            HStack(spacing: OSpacing.sm) {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.down").font(.system(size: 11, weight: .semibold))
                    Text("12% vs Apr").font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(Color(.systemRed))
                Text("· 21 transactions").font(.system(size: 13)).foregroundStyle(Color(.tertiaryLabel))
            }
        }
    }

    private var biggestTransaction: some View {
        VStack(alignment: .leading, spacing: OSpacing.xs) {
            Text("BIGGEST TX")
                .font(.system(size: 10, weight: .semibold).uppercaseSmallCaps())
                .foregroundStyle(Color(.tertiaryLabel))
            HStack {
                Text("Naivas Westlands")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(.label))
                Spacer()
                Text("−7,840")
                    .font(.system(size: 15, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Color(.systemRed))
            }
            .padding(OSpacing.sm)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.tertiarySystemBackground)))
        }
    }
}

// MARK: - Feature pills

private struct WelcomeFeaturePills: View {
    let appeared: Bool

    private let pills: [(icon: String, label: String)] = [
        ("doc.fill", "PDF import"),
        ("bolt.fill", "Auto-categorised"),
        ("chart.bar.fill", "Smart charts")
    ]

    var body: some View {
        HStack(spacing: OSpacing.sm) {
            ForEach(Array(pills.enumerated()), id: \.offset) { index, pill in
                pillView(pill: pill)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.85)
                    .animation(
                        .spring(response: OnboardingConstants.springResponse, dampingFraction: OnboardingConstants.springDamping)
                            .delay(0.55 + Double(index) * 0.1),
                        value: appeared
                    )
            }
        }
    }

    private func pillView(pill: (icon: String, label: String)) -> some View {
        HStack(spacing: OSpacing.xs) {
            Image(systemName: pill.icon)
                .font(.system(size: OnboardingConstants.pillIconSize, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            Text(pill.label)
                .font(OFont.caption)
                .foregroundStyle(Color.accentColor)
        }
        .padding(.horizontal, OSpacing.sm + OSpacing.xs)
        .padding(.vertical, OSpacing.xs + 2)
        .background(
            Capsule()
                .fill(Color("GreenTint"))
                .overlay(Capsule().strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 0.5))
        )
    }
}
