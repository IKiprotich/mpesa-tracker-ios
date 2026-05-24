//
//  DashboardDonutCard.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 24/05/2026.
//


import SwiftUI
import Charts

// MARK: - DashboardDonutCard

struct DashboardDonutCard: View {

    let categories: [CategorySummary]
    let totalSpend: Double

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.bottom, 18)

            HStack(alignment: .center, spacing: 22) {
                donut
                    .frame(width: 128, height: 128)

                legend
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(DesignTokens.Spacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("By category")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Text("Top \(categories.count) of \(categories.count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            Spacer()

            Text("See all →")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DesignTokens.Color.deepGreen)
        }
    }

    // MARK: - Donut

    private var donut: some View {
        ZStack {
            Chart(categories) { summary in
                SectorMark(
                    angle: .value("Spend", summary.totalSpent),
                    innerRadius: .ratio(0.62),
                    angularInset: 1.5
                )
                .foregroundStyle(designColor(for: summary.category))
                .cornerRadius(3)
            }

            // Centre label
            VStack(spacing: 2) {
                Text("Spent")
                    .font(.system(size: 9.5, weight: .semibold))
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Text(totalSpend, format: .number.precision(.fractionLength(0)))
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.6)
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.7)
            }
        }
    }

    // MARK: - Legend

    private var legend: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(categories) { summary in
                legendRow(for: summary)
            }
        }
    }

    private func legendRow(for summary: CategorySummary) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(designColor(for: summary.category))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 1) {
                Text(summary.category.displayName)
                    .font(.system(size: 12.5, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                Text("\(Int(summary.percentageOfTotal))%")
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Text(summary.totalSpent, format: .number.precision(.fractionLength(0)))
                .font(.system(size: 12.5, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Helpers
    private func designColor(for category: Category) -> Color {
        switch category {
        case .food, .groceries: return DesignTokens.CategoryColor.food
        case .transport:        return DesignTokens.CategoryColor.transport
        case .utilities:        return DesignTokens.CategoryColor.utilities
        case .airtime:          return DesignTokens.CategoryColor.airtime
        case .shopping:         return DesignTokens.CategoryColor.shopping
        case .rent, .fees:      return DesignTokens.CategoryColor.bills
        case .health,
             .education,
             .entertainment,
             .savings,
             .transfers,
             .loans,
             .withdrawals:      return DesignTokens.CategoryColor.personal
        case .income, .other:   return DesignTokens.CategoryColor.other
        }
    }
}
