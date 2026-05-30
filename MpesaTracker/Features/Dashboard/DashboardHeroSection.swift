//
//  DashboardHeroSection.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 24/05/2026.
//

import SwiftUI

struct DashboardHeroSection: View {

    let comparison: MonthComparison
    let transactionCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Spent this month")
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)

            heroAmount
                .padding(.bottom, 14)

            deltaRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        .padding(.top, 12)
    }

    // MARK: - Hero amount

    private var heroAmount: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("KES")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.secondary)

            Text(comparison.currentSpend, format: .number.precision(.fractionLength(0)))
                .font(.system(size: 56, weight: .semibold))
                .tracking(-2)
                .monospacedDigit()
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: comparison.currentSpend)
        }
    }

    // MARK: - Delta row

    private var deltaRow: some View {
        HStack(alignment: .center, spacing: 10) {
            if comparison.hasComparison {
                deltaChip
            }

            Text("\(transactionCount) transaction\(transactionCount == 1 ? "" : "s")")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }

    private var deltaChip: some View {
        let isDown = !comparison.isIncrease
        let arrow  = isDown ? "▼" : "▲"
        let label  = String(format: "%@ %.0f%% vs last month", arrow, abs(comparison.change))

        return Text(label)
            .font(.system(size: 12.5, weight: .semibold))
            .monospacedDigit()
            .foregroundStyle(isDown ? DesignTokens.Color.deepGreen : DesignTokens.Color.expenseRed)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(isDown
                          ? DesignTokens.Color.softGreenTint
                          : DesignTokens.Color.expenseRed.opacity(0.1))
            )
    }
}
