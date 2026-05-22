//
//  WeeklyBarChart.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 21/05/2026.
//

import SwiftUI
import Charts

// MARK: - WeeklyBarChart

struct WeeklyBarChart: View {
    let data: [WeeklySpend]

    private var maxAmount: Double {
        data.map(\.amount).max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Spending")
                .font(.subheadline)
                .fontWeight(.semibold)

            if data.allSatisfy({ $0.amount == 0 }) {
                emptyState
            } else {
                chart
            }
        }
    }

    private var chart: some View {
        Chart(data) { week in
            BarMark(
                x: .value("Week", week.label),
                y: .value("Amount", week.amount)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.accentColor, Color.accentColor.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(6)
            .annotation(position: .top, alignment: .center) {
                if week.amount > 0 {
                    Text(compactAmount(week.amount))
                        .font(.system(size: 9, weight: .medium).monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartYScale(domain: 0...(maxAmount * 1.25))
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(compactAmount(amount))
                            .font(.caption2.monospacedDigit())
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.caption2)
            }
        }
        .frame(height: 180)
    }

    private var emptyState: some View {
        Text("No spending data for this period")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 180)
    }

    private func compactAmount(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "%.1fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "%.0fK", amount / 1_000)
        }
        return String(format: "%.0f", amount)
    }
}
