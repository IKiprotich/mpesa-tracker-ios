//
//  InsightsView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 21/05/2026.
//

import SwiftUI
import SwiftData

struct InsightsView: View {

    @Query(sort: \Transaction.completionTime, order: .reverse)
    private var allTransactions: [Transaction]

    @State private var selectedMonth: MonthSelection = .current()

    private var monthTransactions: [Transaction] {
        AnalyticsService.transactions(allTransactions, in: selectedMonth)
    }

    private var summaries: [CategorySummary] {
        CategorySummaryBuilder.build(from: monthTransactions)
    }

    private var weeklyData: [WeeklySpend] {
        AnalyticsService.weeklySpend(for: monthTransactions, in: selectedMonth)
    }

    private var comparison: MonthComparison {
        AnalyticsService.monthComparison(
            current: monthTransactions,
            previous: AnalyticsService.transactions(allTransactions, in: selectedMonth.previous())
        )
    }

    private var dailyAverage: Double {
        guard !monthTransactions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let daysElapsed = max(1, calendar.component(.day, from: .now))
        return comparison.currentSpend / Double(daysElapsed)
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            if allTransactions.isEmpty {
                emptyState
            } else {
                scrollContent
            }
        }
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.sectionGap) {
                InsightsMonthPicker(selectedMonth: $selectedMonth)
                    .padding(.top, 4)

                InsightsHeroStat(
                    comparison: comparison,
                    dailyAverage: dailyAverage,
                    month: selectedMonth
                )

                if monthTransactions.isEmpty {
                    noMonthDataView
                } else {
                    InsightsWeeklyBarsCard(data: weeklyData, month: selectedMonth)

                    InsightsCategoryDonut(summaries: summaries, totalSpend: comparison.currentSpend)

                    InsightsCategoryList(
                        summaries: summaries,
                        monthTransactions: monthTransactions,
                        month: selectedMonth
                    )
                }

                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
    }

    private var noMonthDataView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.secondary)

            Text("No data for \(selectedMonth.displayName)")
                .font(.system(size: 17, weight: .semibold))

            Text("Import a statement that covers this month.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var emptyState: some View {
        EmptyStateView(
            systemImage: "chart.bar.xaxis",
            title: "No Spending Data Yet",
            subtitle: "Import an M-Pesa statement to see your spending breakdown by week and category."
        )
    }
}

// MARK: - InsightsMonthPicker

private struct InsightsMonthPicker: View {
    @Binding var selectedMonth: MonthSelection

    private var canGoForward: Bool {
        let now = MonthSelection.current()
        return selectedMonth.year < now.year
            || (selectedMonth.year == now.year && selectedMonth.month < now.month)
    }

    var body: some View {
        HStack {
            chevronButton(direction: .left) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedMonth = selectedMonth.previous()
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Month")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.06)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Text(selectedMonth.displayName)
                    .font(.system(size: 19, weight: .bold))
                    .tracking(-0.4)
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
            }

            Spacer()

            chevronButton(direction: .right) {
                guard canGoForward else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedMonth = selectedMonth.next()
                }
            }
            .opacity(canGoForward ? 1 : 0.3)
            .disabled(!canGoForward)
        }
    }

    private func chevronButton(direction: ChevronDirection, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 999, style: .continuous)
                                .strokeBorder(Color(.separator).opacity(0.4), lineWidth: 0.5)
                        )
                )
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }

    private enum ChevronDirection { case left, right }
}

// MARK: - InsightsHeroStat

private struct InsightsHeroStat: View {
    let comparison: MonthComparison
    let dailyAverage: Double
    let month: MonthSelection

    var body: some View {
        VStack(spacing: 0) {
            Text("Spent in \(month.shortDisplayName)")
                .font(.system(size: 11.5, weight: .semibold))
                .tracking(0.06)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("KES")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(comparison.currentSpend, format: .number.precision(.fractionLength(0)))
                    .font(.system(size: 52, weight: .semibold))
                    .tracking(-1.7)
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: comparison.currentSpend)
            }
            .padding(.bottom, 12)

            HStack(spacing: 10) {
                if comparison.hasComparison {
                    deltaChip
                }

                HStack(spacing: 4) {
                    Text("Avg")
                        .foregroundStyle(.secondary)
                    Text(dailyAverage, format: .number.precision(.fractionLength(0)))
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    Text("/ day")
                        .foregroundStyle(.secondary)
                }
                .font(.system(size: 12.5))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var deltaChip: some View {
        let isDown = !comparison.isIncrease
        let arrow  = isDown ? "▼" : "▲"
        let text   = "\(arrow) \(String(format: "%.0f", abs(comparison.change)))% vs last month"

        return Text(text)
            .font(.system(size: 12.5, weight: .semibold))
            .monospacedDigit()
            .foregroundStyle(isDown ? DesignTokens.Color.deepGreen : DesignTokens.Color.expenseRed)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(isDown ? DesignTokens.Color.softGreenTint : DesignTokens.Color.expenseRed.opacity(0.1))
            )
    }
}
