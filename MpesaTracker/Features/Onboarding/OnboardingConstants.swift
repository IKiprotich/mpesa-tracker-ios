//
//  OnboardingConstants.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

// MARK: - Spacing scale

enum OSpacing {
    static let xs:   CGFloat = 4
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 24
    static let xl:   CGFloat = 32
    static let xxl:  CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Type scale

enum OFont {
    static let heroTitle    = Font.system(size: 34, weight: .bold,     design: .default)
    static let sectionTitle = Font.system(size: 28, weight: .bold,     design: .default)
    static let cardTitle    = Font.system(size: 17, weight: .semibold, design: .default)
    static let body         = Font.system(size: 17, weight: .regular,  design: .default)
    static let caption      = Font.system(size: 13, weight: .regular,  design: .default)
    static let label        = Font.system(size: 12, weight: .semibold, design: .default).uppercaseSmallCaps()
}

// MARK: - OnboardingConstants

enum OnboardingConstants {

    // MARK: Layout
    static let buttonHeight: CGFloat         = 56
    static let buttonCornerRadius: CGFloat   = 14
    static let topBarHeight: CGFloat         = 44
    static let illustrationWidth: CGFloat    = 280
    static let illustrationHeight: CGFloat   = 160
    static let illustrationCornerRadius: CGFloat = 24
    static let illustrationInset: CGFloat    = 20
    static let cardCornerRadius: CGFloat     = 16
    static let chipCornerRadius: CGFloat     = 12
    static let chipHeight: CGFloat           = 80

    // MARK: Dots
    static let dotActiveWidth: CGFloat  = 24
    static let dotHeight: CGFloat       = 8
    static let dotInactiveSize: CGFloat = 8

    // MARK: Icons
    static let pillIconSize: CGFloat     = 13
    static let stepIconSize: CGFloat     = 24
    static let heroIconSize: CGFloat     = 64
    static let bannerIconSize: CGFloat   = 14
    static let categoryIconSize: CGFloat = 22
    static let badgeSize: CGFloat        = 13

    // MARK: Springs
    static let springResponse: Double    = 0.5
    static let springDamping: Double     = 0.78
    static let btnSpringResponse: Double = 0.2
    static let btnSpringDamping: Double  = 0.85
    static let dotSpringResponse: Double = 0.35
    static let dotSpringDamping: Double  = 0.7
    static let catSpringResponse: Double = 0.25
    static let catSpringDamping: Double  = 0.72
    static let dotMarkerSpringR: Double  = 0.4
    static let dotMarkerSpringD: Double  = 0.65

    // MARK: Animation timing
    static let illustrationDuration: Double = 0.9
    static let illustrationDelay: Double    = 0.2
    static let dotAppearDelay: Double       = illustrationDelay + illustrationDuration + 0.15
    static let stepStagger: Double          = 0.08
    static let enabledFadeDuration: Double  = 0.18
    static let pulseScale: CGFloat          = 1.06

    // MARK: Interaction
    static let pressedScale: CGFloat        = 0.97
    static let selectedCategoryScale: CGFloat = 1.05
    static let categoryColumns: Int         = 3
    static let minCategoryCount: Int        = 1

    // MARK: Navigation
    static let pageCount: Int        = 5
    static let skipTargetPage: Int   = 4
    static let categoryPage: Int     = 3

    // MARK: AppStorage keys
    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    static let preferredCategoriesKey    = "preferredCategories"
}
