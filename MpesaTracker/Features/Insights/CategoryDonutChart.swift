//
//    CategoryDonutChart.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 21/05/2026.
//

import SwiftUI
import Charts

// MARK: - CategoryDonutChart

struct CategoryDonutChart: View {
    let summaries: [CategorySummary]

    private var topSummaries: [CategorySummary] {
        let top = Array(summaries.prefix(5))
        let rest = summaries.dropFirst(5)
        guard !rest.isEmpty else { return top }

        let otherTotal = rest.reduce(0.0) { $0 + $1.totalSpent }
        let otherCount = rest.reduce(0) { $0 + $1.transactionCount }
        let otherPercentage = rest.reduce(0.0) { $0 + $1.percentageOfTotal }

        let other = CategorySummary(
            category: .other,
            totalSpent: otherTotal,
            transactionCount: otherCount,
            percentageOfTotal: otherPercentage
        )
        return top + [other]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Spending by Category")
                .font(.subheadline)
                .fontWeight(.semibold)

            if summaries.isEmpty {
                emptyState
            } else {
                HStack(alignment: .center, spacing: 20) {
                    donut
                    legend
                }
            }
        }
    }

    private var donut: some View {
        Chart(topSummaries) { summary in
            SectorMark(
                angle: .value("Amount", summary.totalSpent),
                innerRadius: .ratio(0.58),
                angularInset: 2
            )
            .foregroundStyle(summary.category.color)
            .cornerRadius(4)
        }
        .frame(width: 140, height: 140)
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(topSummaries) { summary in
                HStack(spacing: 6) {
                    Circle()
                        .fill(summary.category.color)
                        .frame(width: 8, height: 8)
                    Text(summary.category.displayName)
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                    Text("\(Int(summary.percentageOfTotal))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        Text("No spending data for this period")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 140)
    }
}
