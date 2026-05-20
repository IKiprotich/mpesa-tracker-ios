//
//  CategoriesView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI
import SwiftData

// MARK: - CategoriesView

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.completionTime, order: .reverse) private var transactions: [Transaction]
    @State private var selectedMonth: MonthSelection = .current()

    private var transactionsInMonth: [Transaction] {
        let interval = selectedMonth.dateInterval
        return transactions.filter { interval.contains($0.completionTime) }
    }

    private var summaries: [CategorySummary] {
        CategorySummaryBuilder.build(from: transactionsInMonth)
    }

    private var totalSpend: Double {
        CategorySummaryBuilder.totalSpend(from: transactionsInMonth)
    }

    private var totalIncome: Double {
        CategorySummaryBuilder.totalIncome(from: transactionsInMonth)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MonthPickerView(selection: $selectedMonth)
                content
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var content: some View {
        if transactionsInMonth.isEmpty {
            emptyState
        } else {
            List {
                Section {
                    summaryHeader
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .listRowBackground(Color.clear)
                }
                Section("Spending Breakdown") {
                    ForEach(summaries) { summary in
                        NavigationLink {
                            CategoryDetailView(
                                category: summary.category,
                                month: selectedMonth,
                                transactions: transactionsInMonth.filter { $0.category == summary.category }
                            )
                        } label: {
                            CategoryRow(summary: summary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    private var summaryHeader: some View {
        VStack(spacing: 12) {
            HStack {
                summaryTile(
                    label: "Spent",
                    amount: totalSpend,
                    color: .primary
                )
                Divider().frame(height: 40)
                summaryTile(
                    label: "Received",
                    amount: totalIncome,
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func summaryTile(label: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(AmountFormatter.formatKES(amount))
                .font(.title3.monospacedDigit())
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Spending in \(selectedMonth.displayName)",
            systemImage: "chart.pie",
            description: Text("Import statements covering this month to see category breakdowns.")
        )
    }
}

// MARK: - CategoryRow

private struct CategoryRow: View {
    let summary: CategorySummary

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(summary.category.color.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: summary.category.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(summary.category.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(summary.category.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                    Text(AmountFormatter.formatKES(summary.totalSpent))
                        .font(.body.monospacedDigit())
                        .fontWeight(.semibold)
                }

                HStack {
                    progressBar
                    Text("\(Int(summary.percentageOfTotal))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 36, alignment: .trailing)
                }

                Text("\(summary.transactionCount) transaction\(summary.transactionCount == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.secondary.opacity(0.15))
                RoundedRectangle(cornerRadius: 3)
                    .fill(summary.category.color)
                    .frame(width: max(4, proxy.size.width * (summary.percentageOfTotal / 100)))
            }
        }
        .frame(height: 6)
    }
}
