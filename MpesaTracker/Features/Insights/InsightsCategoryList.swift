//
//  InsightsCategoryList.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//

import SwiftUI

struct InsightsCategoryList: View {

    let summaries: [CategorySummary]
    let monthTransactions: [Transaction]
    let month: MonthSelection

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            listHeader
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(summaries.enumerated()), id: \.element.id) { index, summary in
                    NavigationLink {
                        CategoryDetailView(
                            category: summary.category,
                            month: month,
                            transactions: monthTransactions.filter { $0.category == summary.category }
                        )
                    } label: {
                        categoryRow(summary: summary)
                            .padding(.horizontal, 16)
                    }

                    if index < summaries.count - 1 {
                        Divider()
                            .padding(.leading, 66)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }

    private var listHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("All categories")
                .font(.system(size: 11.5, weight: .semibold))
                .tracking(0.06)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            Spacer()

            Text("KES · %")
                .font(.system(size: 11.5, design: .monospaced))
                .tracking(0.04)
                .foregroundStyle(.secondary)
        }
    }

    private func categoryRow(summary: CategorySummary) -> some View {
        HStack(spacing: 14) {
            categoryAvatar(for: summary.category)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(summary.category.displayName)
                        .font(.system(size: 14.5, weight: .semibold))
                        .tracking(-0.15)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(summary.totalSpent, format: .number.precision(.fractionLength(0)))
                        .font(.system(size: 14.5, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }

                progressBar(for: summary)

                HStack {
                    Text("\(summary.transactionCount) transactions")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(Int(summary.percentageOfTotal))%")
                        .font(.system(size: 11, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 12)
    }

    private func categoryAvatar(for category: Category) -> some View {
        let color = designColor(for: category)
        return Text(String(category.displayName.prefix(1)))
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(color, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
    }

    private func progressBar(for summary: CategorySummary) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemFill))
                    .frame(height: 4)

                Capsule()
                    .fill(designColor(for: summary.category))
                    .frame(width: geo.size.width * (summary.percentageOfTotal / 100), height: 4)
            }
        }
        .frame(height: 4)
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
