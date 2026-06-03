//
//  OnboardingScreen4Categories.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI

// MARK: - Screen 4: Category Picker

struct OnboardingScreen4Categories: View {
    @Binding var selectedCategories: Set<Category>

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: OSpacing.sm),
        count: OnboardingConstants.categoryColumns
    )

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                titleSection
                    .padding(.horizontal, OSpacing.xl)
                    .padding(.top, OSpacing.lg)

                LazyVGrid(columns: columns, spacing: OSpacing.sm) {
                    ForEach(Category.allCases) { category in
                        CategoryChip(
                            category: category,
                            isSelected: selectedCategories.contains(category),
                            onTap: { toggle(category) }
                        )
                    }
                }
                .padding(.horizontal, OSpacing.xl)
                .padding(.top, OSpacing.lg)

                helperText
                    .padding(.horizontal, OSpacing.xl)
                    .padding(.top, OSpacing.md)

                // Clear the bottom button stack
                Color.clear.frame(height: 120)
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: OSpacing.sm) {
            Text("What do you spend on?")
                .font(OFont.sectionTitle)
                .tracking(-0.3)

            Text("Pick the ones that matter to you. We'll put them front and centre.")
                .font(OFont.body)
                .foregroundStyle(Color(.secondaryLabel))
        }
    }

    private var helperText: some View {
        Text("Pick at least one to continue")
            .font(OFont.caption)
            .foregroundStyle(Color(.tertiaryLabel))
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(selectedCategories.isEmpty ? 1 : 0)
            .animation(
                .spring(response: OnboardingConstants.springResponse, dampingFraction: OnboardingConstants.springDamping),
                value: selectedCategories.isEmpty
            )
    }

    private func toggle(_ category: Category) {
        withAnimation(.spring(response: OnboardingConstants.catSpringResponse, dampingFraction: OnboardingConstants.catSpringDamping)) {
            if selectedCategories.contains(category) {
                selectedCategories.remove(category)
            } else {
                selectedCategories.insert(category)
            }
        }
    }
}

// MARK: - Category chip

private struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Spacer()

                Image(systemName: category.icon)
                    .font(.system(size: OnboardingConstants.categoryIconSize, weight: .medium))
                    .foregroundStyle(isSelected ? Color.accentColor : Color(.secondaryLabel))
                    .accessibilityHidden(true)

                Spacer()

                Text(category.displayName)
                    .font(OFont.caption)
                    .foregroundStyle(isSelected ? Color.accentColor : Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom, OSpacing.sm)
            }
            .padding(.top, OSpacing.md)
            .frame(maxWidth: .infinity)
            .frame(height: OnboardingConstants.chipHeight)
            .background(chipBackground)
            .scaleEffect(isSelected ? OnboardingConstants.selectedCategoryScale : 1.0)
            .animation(
                .spring(response: OnboardingConstants.catSpringResponse, dampingFraction: OnboardingConstants.catSpringDamping),
                value: isSelected
            )
        }
        .accessibilityLabel(category.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: OnboardingConstants.chipCornerRadius)
                .fill(Color("GreenTint"))
                .overlay(
                    RoundedRectangle(cornerRadius: OnboardingConstants.chipCornerRadius)
                        .strokeBorder(Color.accentColor, lineWidth: 1)
                )
        } else {
            RoundedRectangle(cornerRadius: OnboardingConstants.chipCornerRadius)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: OnboardingConstants.chipCornerRadius)
                        .strokeBorder(Color(.separator), lineWidth: 0.5)
                )
        }
    }
}

#Preview("Screen 4 Categories — Light") {
    @Previewable @State var selectedCategories: Set<Category> = []
    OnboardingScreen4Categories(selectedCategories: $selectedCategories)
        .preferredColorScheme(.light)
}

#Preview("Screen 4 Categories — Dark") {
    @Previewable @State var selectedCategories: Set<Category> = []
    OnboardingScreen4Categories(selectedCategories: $selectedCategories)
        .preferredColorScheme(.dark)
}

#Preview("Screen 4 Categories — Nothing selected") {
    @Previewable @State var selectedCategories: Set<Category> = []
    OnboardingScreen4Categories(selectedCategories: $selectedCategories)
}

#Preview("Screen 4 Categories — Some selected") {
    @Previewable @State var selectedCategories: Set<Category> = [.food, .transport, .utilities]
    OnboardingScreen4Categories(selectedCategories: $selectedCategories)
}
