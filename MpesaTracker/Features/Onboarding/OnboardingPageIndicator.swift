//
//  OnboardingPageIndicator.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

struct OnboardingPageIndicator: View {
    let pageCount: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: OSpacing.sm) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.accentColor : Color(.tertiaryLabel))
                    .frame(
                        width: index == currentPage
                            ? OnboardingConstants.dotActiveWidth
                            : OnboardingConstants.dotInactiveSize,
                        height: OnboardingConstants.dotHeight
                    )
                    .animation(
                        .spring(
                            response: OnboardingConstants.dotSpringResponse,
                            dampingFraction: OnboardingConstants.dotSpringDamping
                        ),
                        value: currentPage
                    )
            }
        }
        .animation(
            .spring(
                response: OnboardingConstants.dotSpringResponse,
                dampingFraction: OnboardingConstants.dotSpringDamping
            ),
            value: currentPage
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of \(pageCount)")
    }
}

#Preview("Page Indicator") {
    VStack(spacing: 32) {
        OnboardingPageIndicator(pageCount: 5, currentPage: 0)
        OnboardingPageIndicator(pageCount: 5, currentPage: 2)
        OnboardingPageIndicator(pageCount: 5, currentPage: 4)
    }
    .padding(32)
    .preferredColorScheme(.light)
}

#Preview("Page Indicator — Dark") {
    VStack(spacing: 32) {
        OnboardingPageIndicator(pageCount: 5, currentPage: 0)
        OnboardingPageIndicator(pageCount: 5, currentPage: 2)
        OnboardingPageIndicator(pageCount: 5, currentPage: 4)
    }
    .padding(32)
    .preferredColorScheme(.dark)
}
