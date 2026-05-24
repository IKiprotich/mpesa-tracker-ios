//
//  InsightsCategoryDonut.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//

import SwiftUI
import Charts

struct InsightsCategoryDonut: View {

    let summaries: [CategorySummary]
    let totalSpend: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader
                .padding(.bottom, 18)

            donut
                .frame(width: 188, height: 188)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 18)

            legendGrid
        }
        .padding(DesignTokens.Spacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var cardHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("By category")
                    .font(.system(size: 11.5, weight: .semibold))
                    .tracking(0.06)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Text("\(summaries.count) categories")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
    }

    private var donut: some View {
        ZStack {
            Chart(summaries) { summary in
                SectorMark(
                    angle: .value("Spend", summary.totalSpent),
                    innerRadius: .ratio(0.60),
                    angularInset: 1.5
                )
                .foregroundStyle(designColor(for: summary.category))
                .cornerRadius(3)
            }

            VStack(spacing: 4) {
                Text("Spent")
                    .font(.system(size: 10.5, weight: .semibold))
                    .tracking(0.06)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Text(totalSpend, format: .number.precision(.fractionLength(0)))
                    .font(.system(size: 28, weight: .semibold))
                    .tracking(-0.9)
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.6)

                Text("KES · \(Date.now.formatted(.dateTime.month(.abbreviated)).uppercased())")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var legendGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(summaries) { summary in
                legendItem(for: summary)
            }
        }
    }

    private func legendItem(for summary: CategorySummary) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(designColor(for: summary.category))
                .frame(width: 6, height: 6)

            Text(summary.category.displayName)
                .font(.system(size: 12.5, weight: .medium))
                .lineLimit(1)
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            Text("\(Int(summary.percentageOfTotal))%")
                .font(.system(size: 12, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }

    private func designColor(for category: Category) -> Color {
        switch category {
        case .food, .groceries: return DesignTokens.CategoryColor.food
        case .transport:        return DesignTokens.CategoryColor.transport
        case .utilities:        return DesignTokens.CategoryColor.utilities
        case .airtime:          return DesignTokens.CategoryColor.airtime
        case .shopping:         return DesignTokens.CategoryColor.shopping
        case .rent, .fees:      return DesignTokens.CategoryColor.bills
        default:                return DesignTokens.CategoryColor.other
        }
    }
}
