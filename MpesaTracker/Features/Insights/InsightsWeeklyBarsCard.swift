//
//  InsightsWeeklyBarsCard.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//

import SwiftUI
import Charts

struct InsightsWeeklyBarsCard: View {

    let data: [WeeklySpend]
    let month: MonthSelection

    private var maxAmount: Double {
        (data.map(\.amount).max() ?? 1) * 1.25
    }

    // Active week is whichever segment contains today 
    private var activeWeekID: Int? {
        let now = Date.now
        guard Calendar.current.component(.month, from: now) == month.month,
              Calendar.current.component(.year, from: now) == month.year else { return nil }
        return data.first { $0.weekStart <= now && now <= endDate(for: $0) }?.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader
                .padding(.bottom, 14)

            barsChart
                .padding(.bottom, 8)

            xLabels
        }
        .padding(DesignTokens.Spacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: month)
    }

    // MARK: - Header

    private var cardHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Weekly spend")
                    .font(.system(size: 11.5, weight: .semibold))
                    .tracking(0.06)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Text("\(data.count) weeks · \(month.shortDisplayName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            Spacer()

            Text("KES")
                .font(.system(size: 11.5, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Bar chart
    //
    // X-axis labels are hidden here — we draw our own below the chart
    // so we can show both the week label and the day range.

    private var barsChart: some View {
        Chart(data) { week in
            BarMark(
                x: .value("Week", week.label),
                y: .value("Amount", week.amount)
            )
            .foregroundStyle(barColor(for: week))
            .cornerRadius(8)
            .annotation(position: .top, alignment: .center) {
                if week.amount > 0 {
                    Text(compactAmount(week.amount))
                        .font(.system(size: 10.5, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(isActive(week) ? DesignTokens.Color.deepGreen : .secondary)
                }
            }
        }
        .chartYScale(domain: 0...maxAmount)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                AxisGridLine()
                    .foregroundStyle(Color(.separator).opacity(0.4))
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(compactAmount(amount))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartXAxis(.hidden)
        .frame(height: 160)
    }

    // MARK: - Custom X labels

    private var xLabels: some View {
        HStack(spacing: 0) {
            ForEach(data) { week in
                VStack(spacing: 1) {
                    Text(week.label)
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(isActive(week) ? .primary : .secondary)

                    Text(week.range)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Helpers

    private func isActive(_ week: WeeklySpend) -> Bool {
        week.id == activeWeekID
    }

    private func barColor(for week: WeeklySpend) -> Color {
        isActive(week)
            ? DesignTokens.Color.deepGreen
            : DesignTokens.Color.primaryGreen.opacity(0.25)
    }

    private func endDate(for week: WeeklySpend) -> Date {
        Calendar.current.date(byAdding: .day, value: 6, to: week.weekStart) ?? week.weekStart
    }

    private func compactAmount(_ amount: Double) -> String {
        switch amount {
        case 1_000_000...: return String(format: "%.1fM", amount / 1_000_000)
        case 1_000...:     return String(format: "%.0fK", amount / 1_000)
        default:           return String(format: "%.0f", amount)
        }
    }
}
