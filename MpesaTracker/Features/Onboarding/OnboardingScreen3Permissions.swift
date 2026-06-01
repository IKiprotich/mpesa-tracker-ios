//
//  OnboardingScreen3Permissions.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

// MARK: - Screen 3: Notifications

struct OnboardingScreen3Permissions: View {
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            bellIcon
                .padding(.bottom, OSpacing.xl)

            titleSection
                .padding(.horizontal, OSpacing.xl)
                .padding(.bottom, OSpacing.lg)

            checklistSection
                .padding(.horizontal, OSpacing.xl)

            Spacer()
        }
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(0.4))
                isPulsing = true
            }
        }
    }

    private var bellIcon: some View {
        Image(systemName: "bell.badge.fill")
            .font(.system(size: OnboardingConstants.heroIconSize, weight: .thin))
            .foregroundStyle(Color.accentColor)
            .accessibilityHidden(true)
            .keyframeAnimator(initialValue: CGFloat(1.0), trigger: isPulsing) { view, scale in
                view.scaleEffect(scale)
            } keyframes: { _ in
                KeyframeTrack {
                    LinearKeyframe(1.0, duration: 0.01)
                    SpringKeyframe(OnboardingConstants.pulseScale, duration: 0.28, spring: .bouncy)
                    SpringKeyframe(1.0, duration: 0.28, spring: .bouncy)
                    SpringKeyframe(OnboardingConstants.pulseScale, duration: 0.28, spring: .bouncy)
                    SpringKeyframe(1.0, duration: 0.28, spring: .bouncy)
                }
            }
    }

    private var titleSection: some View {
        VStack(spacing: OSpacing.sm) {
            Text("Stay on top of your spending")
                .font(OFont.sectionTitle)
                .tracking(-0.3)
                .multilineTextAlignment(.center)

            Text("Get a nudge when you haven't reviewed your spending in a while. No spam, just a gentle reminder.")
                .font(OFont.body)
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
    }

    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: OSpacing.md) {
            checkRow("Monthly spending summary")
            checkRow("Reminder to import new statements")
        }
    }

    private func checkRow(_ text: String) -> some View {
        HStack(spacing: OSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            Text(text)
                .font(OFont.body)
        }
    }
}
