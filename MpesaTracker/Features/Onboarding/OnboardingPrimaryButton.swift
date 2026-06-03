//
//  OnboardingPrimaryButton.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

// MARK: - Primary CTA button

struct OnboardingPrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: OnboardingConstants.buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: OnboardingConstants.buttonCornerRadius)
                        .fill(isEnabled ? Color.accentColor : Color.accentColor.opacity(0.35))
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
        .frame(maxWidth: OnboardingConstants.buttonMaxWidth)
        .animation(.easeInOut(duration: 0.18), value: isEnabled)
        .accessibilityLabel(title)
    }
}

// MARK: - Secondary / ghost link button

struct OnboardingSecondaryLink: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color(.tertiaryLabel))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
        }
        .buttonStyle(ScaleButtonStyle(scaleFactor: 0.99))
        .frame(maxWidth: OnboardingConstants.buttonMaxWidth)
        .accessibilityLabel(title)
    }
}

// MARK: - Scale press style

private struct ScaleButtonStyle: ButtonStyle {
    var scaleFactor: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleFactor : 1.0)
            .animation(
                .spring(response: 0.2, dampingFraction: 0.85),
                value: configuration.isPressed
            )
    }
}

// MARK: - Bottom button stack

struct OnboardingBottomStack<Secondary: View>: View {
    let currentPage: Int
    let totalPages: Int
    let primaryTitle: String
    let isPrimaryEnabled: Bool
    let primaryAction: () -> Void
    let secondary: () -> Secondary

    init(
        currentPage: Int,
        totalPages: Int,
        primaryTitle: String,
        isPrimaryEnabled: Bool = true,
        primaryAction: @escaping () -> Void,
        @ViewBuilder secondary: @escaping () -> Secondary
    ) {
        self.currentPage      = currentPage
        self.totalPages       = totalPages
        self.primaryTitle     = primaryTitle
        self.isPrimaryEnabled = isPrimaryEnabled
        self.primaryAction    = primaryAction
        self.secondary        = secondary
    }

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    Color(.systemBackground).opacity(0),
                    Color(.systemBackground).opacity(0.95),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)
            .allowsHitTesting(false)

            VStack(spacing: OnboardingConstants.buttonToSecondaryGap) {
                OnboardingPageIndicator(
                    pageCount: totalPages, currentPage: currentPage
                )
                .padding(.bottom, OnboardingConstants.indicatorToButtonGap - OnboardingConstants.buttonToSecondaryGap)

                OnboardingPrimaryButton(
                    title: primaryTitle,
                    isEnabled: isPrimaryEnabled,
                    action: primaryAction
                )

                secondary()
            }
            .padding(.bottom, OSpacing.sm)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Previews

#Preview("Button States — Light") {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()

        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: OnboardingConstants.buttonToSecondaryGap) {
                OnboardingPageIndicator(pageCount: 5, currentPage: 0)
                    .padding(.bottom, OnboardingConstants.indicatorToButtonGap - OnboardingConstants.buttonToSecondaryGap)

                OnboardingPrimaryButton(
                    title: "Get started",
                    isEnabled: true,
                    action: {}
                )

                OnboardingSecondaryLink(title: "Skip for now", action: {})
            }
            .padding(.bottom, OSpacing.xl)
        }
    }
    .preferredColorScheme(.light)
}

#Preview("Button States — Dark") {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()

        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: OnboardingConstants.buttonToSecondaryGap) {
                OnboardingPageIndicator(pageCount: 5, currentPage: 2)
                    .padding(.bottom, OnboardingConstants.indicatorToButtonGap - OnboardingConstants.buttonToSecondaryGap)

                OnboardingPrimaryButton(
                    title: "These look right",
                    isEnabled: false,
                    action: {}
                )

                OnboardingSecondaryLink(title: "I'll do this later", action: {})
            }
            .padding(.bottom, OSpacing.xl)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Button Enabled → Disabled") {
    ButtonTogglePreview()
        .preferredColorScheme(.light)
}

private struct ButtonTogglePreview: View {
    @State private var enabled = true

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: OnboardingConstants.buttonToSecondaryGap) {
                Spacer()
                OnboardingPrimaryButton(
                    title: enabled ? "These look right" : "Select at least one",
                    isEnabled: enabled,
                    action: {}
                )
                OnboardingSecondaryLink(title: "Toggle state", action: { enabled.toggle() })
            }
            .padding(.bottom, OSpacing.xl)
        }
    }
}
