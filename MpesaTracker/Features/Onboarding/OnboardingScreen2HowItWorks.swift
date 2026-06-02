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

            // Header
            VStack(alignment: .leading, spacing: OSpacing.xs) {
                Text("HOW IT WORKS")
                    .font(OFont.label)
                    .foregroundStyle(Color("GreenDeep"))

                Text("Three steps to\nspending clarity")
                    .font(.system(size: 34, weight: .semibold))
                    .tracking(-0.6)
                    .foregroundStyle(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, OSpacing.xl)
            .padding(.bottom, OSpacing.lg)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 14)
            .animation(.spring(response: 0.5, dampingFraction: 0.82), value: appeared)

            // Steps
            VStack(spacing: 0) {
                ForEach(Array(HowItWorksStep.all.enumerated()), id: \.offset) { index, step in
                    StepRow(step: step, isLast: index == HowItWorksStep.all.count - 1)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(
                            .spring(response: 0.52, dampingFraction: 0.8)
                            .delay(0.1 + Double(index) * 0.1),
                            value: appeared
                        )
                }
            }
            .padding(.horizontal, OSpacing.xl)
            .padding(.top, OSpacing.xl)

            Spacer(minLength: OSpacing.xxl)
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Step data

private struct HowItWorksStep {
    let number: String
    let title: String
    let body: String
    let accentColor: Color

    static let all: [HowItWorksStep] = [
        HowItWorksStep(
            number: "01",
            title: "Export from M-Pesa",
            body: "Open the M-Pesa app, tap Statements, choose a date range and hit Send. Safaricom emails you the PDF.",
            accentColor: Color(red: 0.31, green: 0.56, blue: 0.71) // dusty blue — transport
        ),
        HowItWorksStep(
            number: "02",
            title: "Save the PDF to Files",
            body: "Open the email on your iPhone, tap the attachment, then Share → Save to Files. Takes ten seconds.",
            accentColor: Color(red: 0.88, green: 0.64, blue: 0.35) // warm sand — food
        ),
        HowItWorksStep(
            number: "03",
            title: "Import and you're done",
            body: "Tap Import in Pesa Tracker, pick the PDF, and every transaction appears — categorised and ready.",
            accentColor: Color.accentColor
        )
    ]
}

// MARK: - Step row

private struct StepRow: View {
    let step: HowItWorksStep
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: OSpacing.md) {

            // Left column: number + connecting line
            VStack(spacing: 0) {
                // Number badge
                Text(step.number)
                    .font(.system(size: 12, weight: .bold).monospacedDigit())
                    .foregroundStyle(step.accentColor)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(step.accentColor.opacity(0.1))
                    )

                // Connecting line — hidden on last step
                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [step.accentColor.opacity(0.3), step.accentColor.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1.5)
                        .frame(height: OSpacing.xl)
                        .padding(.top, OSpacing.xs)
                }
            }
            .frame(width: 32)

            // Right column: content
            VStack(alignment: .leading, spacing: OSpacing.xs) {
                Text(step.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(.label))
                    .tracking(-0.2)

                Text(step.body)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, isLast ? 0 : OSpacing.xl)

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Previews

#Preview("Screen 2 How It Works — Light") {
    OnboardingScreen2HowItWorks()
        .preferredColorScheme(.light)
}

#Preview("Screen 2 How It Works — Dark") {
    OnboardingScreen2HowItWorks()
        .preferredColorScheme(.dark)
}
