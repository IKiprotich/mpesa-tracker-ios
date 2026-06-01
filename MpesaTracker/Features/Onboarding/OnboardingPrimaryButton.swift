//
//  OnboardingPrimaryButton.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

struct OnboardingPrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(OFont.cardTitle)
                .foregroundStyle(isEnabled ? Color.white : Color(.tertiaryLabel))
                .frame(maxWidth: .infinity)
                .frame(height: OnboardingConstants.buttonHeight)
                .background(buttonBackground)
        }
        .buttonStyle(OnboardingScaleStyle())
        .disabled(!isEnabled)
        .padding(.horizontal, OSpacing.xl)
        .animation(.easeInOut(duration: OnboardingConstants.enabledFadeDuration), value: isEnabled)
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var buttonBackground: some View {
        if isEnabled {
            RoundedRectangle(cornerRadius: OnboardingConstants.buttonCornerRadius)
                .fill(Color.accentColor)
        } else {
            RoundedRectangle(cornerRadius: OnboardingConstants.buttonCornerRadius)
                .fill(Color(.tertiarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: OnboardingConstants.buttonCornerRadius)
                        .strokeBorder(Color(.separator), lineWidth: 0.5)
                )
        }
    }
}

private struct OnboardingScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? OnboardingConstants.pressedScale : 1.0)
            .animation(
                .spring(
                    response: OnboardingConstants.btnSpringResponse,
                    dampingFraction: OnboardingConstants.btnSpringDamping
                ),
                value: configuration.isPressed
            )
    }
}
