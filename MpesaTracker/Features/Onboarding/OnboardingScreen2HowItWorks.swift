//
//  OnboardingScreen2HowItWorks.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

// MARK: - Screen 2: How It Works

struct OnboardingScreen2HowItWorks: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 0) {
                Text("HOW IT WORKS")
                    .font(OFont.label)
                    .foregroundStyle(Color("GreenDeep"))
                    .padding(.bottom, OSpacing.sm)

                Text("Three steps to spending clarity")
                    .font(OFont.sectionTitle)
                    .tracking(-0.3)
                    .padding(.bottom, OSpacing.xl)

                stepsStack
            }
            .padding(.horizontal, OSpacing.xl)

            Spacer(minLength: 0)
        }
    }

    private var stepsStack: some View {
        VStack(spacing: OSpacing.xl) {
            ForEach(Array(HowItWorksStep.all.enumerated()), id: \.offset) { index, step in
                AccentBarStep(step: step)
                    .opacity(appeared ? 1 : 0)
                    .offset(x: appeared ? 0 : 32)
                    .animation(
                        .spring(response: OnboardingConstants.springResponse, dampingFraction: OnboardingConstants.springDamping)
                            .delay(Double(index) * OnboardingConstants.stepStagger),
                        value: appeared
                    )
            }
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Step data

private struct HowItWorksStep {
    let number: String
    let icon: String
    let title: String
    let body: String
    let barColor: Color

    static let all: [HowItWorksStep] = [
        HowItWorksStep(
            number: "1",
            icon: "arrow.up.doc.fill",
            title: "Export from M-Pesa",
            body: "Open the M-Pesa app or MySafaricom portal and export your statement as a PDF. Takes 30 seconds.",
            barColor: DesignTokens.CategoryColor.transport
        ),
        HowItWorksStep(
            number: "2",
            icon: "square.and.arrow.down.fill",
            title: "Import into Pesa Tracker",
            body: "Tap import and select your PDF from Files. Your transactions are read entirely on your device — never uploaded anywhere.",
            barColor: DesignTokens.CategoryColor.food
        ),
        HowItWorksStep(
            number: "3",
            icon: "chart.pie.fill",
            title: "See your spending",
            body: "Every transaction is automatically categorised. Charts and summaries are ready instantly.",
            barColor: Color.accentColor
        )
    ]
}

// MARK: - Accent bar step row

private struct AccentBarStep: View {
    let step: HowItWorksStep

    var body: some View {
        HStack(alignment: .top, spacing: OSpacing.md) {
            accentBar

            VStack(alignment: .leading, spacing: OSpacing.xs) {
                Text(step.number)
                    .font(OFont.caption)
                    .foregroundStyle(Color(.tertiaryLabel))
                Text(step.title)
                    .font(OFont.cardTitle)
                    .foregroundStyle(Color(.label))
                Text(step.body)
                    .font(OFont.body)
                    .foregroundStyle(Color(.secondaryLabel))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var accentBar: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(step.barColor)
            .frame(width: 3)
    }
}
