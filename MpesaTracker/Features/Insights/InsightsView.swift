//
//  InsightsView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 21/05/2026.
//

import SwiftUI
import SwiftData

struct InsightsView: View {

    // MARK: - Query

    @Query(sort: \Transaction.completionTime, order: .reverse)
    private var allTransactions: [Transaction]

    // MARK: - State

    @State private var selectedMonth: MonthSelection = .current()
    @State private var selectedCategory: Category? = nil

    // MARK: - Computed

    private var monthTransactions: [Transaction] {
        AnalyticsService.transactions(allTransactions, in: selectedMonth)
    }

    private var summaries: [CategorySummary] {
        CategorySummaryBuilder.build(from: monthTransactions)
    }

    private var weeklyData: [WeeklySpend] {
        AnalyticsService.weeklySpend(for: monthTransactions, in: selectedMonth)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MonthPickerView(selection: $selectedMonth)

                Group {
                    if allTransactions.isEmpty {
                        emptyState
                    } else if monthTransactions.isEmpty {
                        ContentUnavailableView(
                            "No Data for \(selectedMonth.displayName)",
                            systemImage: "chart.pie",
                            description: Text("No transactions found for this month.")
                        )
                    } else {
                        scrollContent
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Sub-views

    private var scrollContent: some View {
        List {
            Section {
                WeeklyBarChart(data: weeklyData)
                    .padding(.vertical, 4)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedMonth)
            }

            Section {
                CategoryDonutChart(summaries: summaries)
                    .padding(.vertical, 4)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedMonth)
            }

            Section("Breakdown") {
                ForEach(summaries) { summary in
                    NavigationLink {
                        CategoryDetailView(
                            category: summary.category,
                            month: selectedMonth,
                            transactions: monthTransactions.filter { $0.category == summary.category }
                        )
                    } label: {
                        CategorySummaryRow(summary: summary, monthTotal: summaries.reduce(0) { $0 + $1.totalSpent })
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        EmptyStateView(
            systemImage: "chart.bar.xaxis",
            title: "No Spending Data Yet",
            subtitle: "Import an M-Pesa statement to see your spending breakdown by week and category."
        )
    }
}

// MARK: - CategorySummaryRow

private struct CategorySummaryRow: View {
    let summary: CategorySummary
    let monthTotal: Double

    private var percentage: Double {
        monthTotal > 0 ? (summary.totalSpent / monthTotal) * 100 : 0
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: summary.category.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(summary.category.color)
                .frame(width: 36, height: 36)
                .background(summary.category.color.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(summary.category.displayName)
                    .font(.subheadline.weight(.medium))
                Text("\(summary.transactionCount) transactions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(summary.totalSpent, format: .currency(code: "KES"))
                    .font(.subheadline.weight(.semibold))
                Text(String(format: "%.0f%%", percentage))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview("Empty") {
    InsightsView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
