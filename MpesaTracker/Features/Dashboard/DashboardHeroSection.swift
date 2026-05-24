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
    @Binding var selectedMonth: MonthSelection

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            monthPicker
                .padding(.bottom, 18)

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

    // MARK: - Month picker

    private var monthPicker: some View {
        Menu {
            ForEach(availableMonths, id: \.id) { month in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMonth = month
                    }
                } label: {
                    HStack {
                        Text(month.displayName)
                        if month == selectedMonth {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMonth = selectedMonth.previous()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)

                Text(selectedMonth.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                    .monospacedDigit()

                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)

                Button {
                    let next = selectedMonth.next()
                    let now  = MonthSelection.current()
                    guard next.year < now.year ||
                          (next.year == now.year && next.month <= now.month) else { return }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMonth = next
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.chip, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.chip, style: .continuous)
                            .strokeBorder(Color(.separator).opacity(0.5), lineWidth: 0.5)
                    )
            )
        }
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

    // MARK: - Available months

    private var availableMonths: [MonthSelection] {
        var months: [MonthSelection] = []
        var cursor = MonthSelection.current()
        for _ in 0..<12 {
            months.append(cursor)
            cursor = cursor.previous()
        }
        return months
    }
}
