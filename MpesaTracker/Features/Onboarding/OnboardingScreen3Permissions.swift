//
//  OnboardingScreen3Permissions.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

// MARK: - Screen 3: Notifications

struct OnboardingScreen3Permissions: View {
    @State private var illustrationAppeared = false
    @State private var contentAppeared      = false
    @State private var cardAppeared         = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Illustration
                NotificationIllustration(appeared: illustrationAppeared)
                    .frame(height: 120)
                    .padding(.horizontal, OSpacing.xl)
                    .padding(.top, OSpacing.lg)
                    .accessibilityHidden(true)

                // Copy
                headlineBlock
                    .padding(.horizontal, OSpacing.xl)
                    .padding(.top, OSpacing.lg)

                //  What you'll get card
                benefitsCard
                    .padding(.horizontal, OSpacing.xl)
                    .padding(.top, OSpacing.lg)
                    .opacity(cardAppeared ? 1 : 0)
                    .offset(y: cardAppeared ? 0 : 16)
                    .animation(
                        .spring(response: 0.52, dampingFraction: 0.82).delay(0.32),
                        value: cardAppeared
                    )

                // Clear the bottom button stack
                Color.clear.frame(height: 140)
            }
        }
        .onAppear {
            illustrationAppeared = true
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82).delay(0.18)) {
                contentAppeared = true
            }
            withAnimation(.spring(response: 0.52, dampingFraction: 0.82).delay(0.32)) {
                cardAppeared = true
            }
        }
    }

    // MARK: Headline

    private var headlineBlock: some View {
        VStack(alignment: .leading, spacing: OSpacing.sm) {
            Text("Know before\nyou overspend.")
                .font(.system(size: 34, weight: .semibold))
                .tracking(-0.6)
                .foregroundStyle(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 16)
                .animation(.spring(response: 0.55, dampingFraction: 0.82).delay(0.18), value: contentAppeared)

            Text("Optional nudges keep you aware — without needing to open the app every day.")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color(.secondaryLabel))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 12)
                .animation(.spring(response: 0.55, dampingFraction: 0.82).delay(0.26), value: contentAppeared)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Benefits card

    private var benefitsCard: some View {
        VStack(spacing: 0) {
            benefitRow(
                icon: "calendar",
                iconColor: Color(red: 0.31, green: 0.56, blue: 0.71),
                title: "Monthly summary",
                body: "A quiet recap of where your money went each month."
            )

            Divider()
                .padding(.leading, 52)

            benefitRow(
                icon: "arrow.down.doc.fill",
                iconColor: Color(red: 0.88, green: 0.64, blue: 0.35),
                title: "Import reminder",
                body: "A nudge when a new statement is likely ready to import."
            )

            Divider()
                .padding(.leading, 52)

            benefitRow(
                icon: "lock.fill",
                iconColor: Color.accentColor,
                title: "Nothing else",
                body: "No marketing. No promotions. Notifications you actually want."
            )
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

    private func benefitRow(
        icon: String,
        iconColor: Color,
        title: String,
        body: String
    ) -> some View {
        HStack(alignment: .top, spacing: OSpacing.md) {
            // Icon
            RoundedRectangle(cornerRadius: 9)
                .fill(iconColor.opacity(0.12))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(iconColor)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(.label))
                Text(body)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, OSpacing.md)
        .padding(.vertical, OSpacing.md)
    }
}

// MARK: - Notification illustration

private struct NotificationIllustration: View {
    let appeared: Bool
    @State private var ringScale: CGFloat = 1.0
    @State private var badgeScale: CGFloat = 0.0

    var body: some View {
        ZStack {
            // Outer pulse ring
            Circle()
                .strokeBorder(Color.accentColor.opacity(0.12), lineWidth: 1)
                .frame(width: 110, height: 110)
                .scaleEffect(ringScale)
                .opacity(appeared ? 1 : 0)

            // Mid ring
            Circle()
                .fill(Color.accentColor.opacity(0.07))
                .frame(width: 88, height: 88)
                .scaleEffect(appeared ? 1 : 0.5)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.75), value: appeared)

            // Icon container
            Circle()
                .fill(Color("GreenTint"))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "bell.fill")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                )
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.55, dampingFraction: 0.72).delay(0.08), value: appeared)
                .accessibilityHidden(true)

            // Badge dot
            Circle()
                .fill(Color(.systemRed))
                .frame(width: 14, height: 14)
                .overlay(
                    Circle().strokeBorder(Color(.systemBackground), lineWidth: 2)
                )
                .scaleEffect(badgeScale)
                .offset(x: 18, y: -18)
                .accessibilityHidden(true)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.45)) {
                badgeScale = 1.0
            }
            withAnimation(
                .easeInOut(duration: 2.2)
                .repeatForever(autoreverses: true)
                .delay(0.8)
            ) {
                ringScale = 1.12
            }
        }
    }
}

// MARK: - Previews

#Preview("Screen 3 Permissions — Light") {
    OnboardingScreen3Permissions()
        .preferredColorScheme(.light)
}

#Preview("Screen 3 Permissions — Dark") {
    OnboardingScreen3Permissions()
        .preferredColorScheme(.dark)
}
