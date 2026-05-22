//
//  MonthSummaryCard.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 22/05/2026.
//

import SwiftUI

struct MonthSummaryCard: View {

    // MARK: - Properties

    let comparison: MonthComparison
    let month: MonthSelection

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(month.displayName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(comparison.currentSpend, format: .currency(code: "KES"))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            if comparison.hasComparison {
                HStack(spacing: 4) {
                    Image(systemName: comparison.isIncrease ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption.weight(.semibold))
                    Text(String(format: "%.0f%% vs last month", abs(comparison.change)))
                        .font(.subheadline)
                }
                .foregroundStyle(comparison.isIncrease ? Color(.systemRed) : Color(.systemGreen))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
