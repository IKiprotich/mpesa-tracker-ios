//
//  DashboardView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 21/05/2026.
//

import SwiftUI
import SwiftData

// MARK: - DashboardView

struct DashboardView: View {
    @Query(sort: \Transaction.completionTime, order: .reverse) private var allTransactions: [Transaction]
    @State private var selectedMonth: MonthSelection = .current()

    private var currentTransactions: [Transaction] {
        AnalyticsService.transactions(allTransactions, in: selectedMonth)
    }

    private var previousTransactions: [Transaction] {
        AnalyticsService.transactions(allTransactions, in: selectedMonth.previous())
    }

    private var comparison: MonthComparison {
        AnalyticsService.monthComparison(current: currentTransactions, previous: previousTransactions)
    }

    private var topCategory: CategorySummary? {
        AnalyticsService.topCategory(in: currentTransactions)
    }

    private var biggestTransaction: Transaction? {
        AnalyticsService.biggestTransaction(in: currentTransactions)
    }

    private var recentTransactions: [Transaction] {
        Array(currentTransactions.prefix(5))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    MonthPickerView(selection: $selectedMonth)
                        .padding(.top, 4)

                    if allTransactions.isEmpty {
                        emptyState
                    } else {
                        cards
                    }
                }
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: Cards

    @ViewBuilder
    private var cards: some View {
        VStack(spacing: 16) {
            spendCard
            if let top = topCategory { topCategoryCard(top) }
            if let biggest = biggestTransaction { biggestTransactionCard(biggest) }
            recentTransactionsCard
        }
        .padding(.horizontal)
    }

    // MARK: Spend card

    private var spendCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Spent")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(AmountFormatter.formatKES(comparison.currentSpend))
                .font(.system(size: 36, weight: .bold, design: .rounded).monospacedDigit())

            if comparison.hasComparison {
                HStack(spacing: 4) {
                    Image(systemName: comparison.isIncrease ? "arrow.up.right" : "arrow.down.right")
                    Text("\(String(format: "%.0f", abs(comparison.change)))% vs last month")
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(comparison.isIncrease ? .red : .green)
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Income")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(AmountFormatter.formatKES(CategorySummaryBuilder.totalIncome(from: currentTransactions)))
                        .font(.subheadline.monospacedDigit())
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Transactions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(currentTransactions.count)")
                        .font(.subheadline.monospacedDigit())
                        .fontWeight(.semibold)
                }
            }
        }
        .dashboardCard()
    }

    // MARK: Top category card

    private func topCategoryCard(_ summary: CategorySummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Top Spending Category", systemImage: "star.fill")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(summary.category.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: summary.category.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(summary.category.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(summary.category.displayName)
                        .font(.headline)
                    Text("\(summary.transactionCount) transactions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(AmountFormatter.formatKES(summary.totalSpent))
                        .font(.headline.monospacedDigit())
                    Text("\(Int(summary.percentageOfTotal))% of spend")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .dashboardCard()
    }

    // MARK: Biggest transaction card

    private func biggestTransactionCard(_ transaction: Transaction) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Biggest Transaction", systemImage: "arrow.up.circle.fill")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.counterparty)
                        .font(.headline)
                        .lineLimit(1)
                    Text(transaction.completionTime, format: .dateTime.day().month(.wide))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(AmountFormatter.formatKES(transaction.withdrawn))
                    .font(.headline.monospacedDigit())
            }
        }
        .dashboardCard()
    }

    // MARK: Recent transactions card

    private var recentTransactionsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Transactions")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)

            if recentTransactions.isEmpty {
                Text("No transactions this month")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(recentTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                        if transaction.id != recentTransactions.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .dashboardCard()
    }

    // MARK: Empty state

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Data Yet", systemImage: "chart.bar.xaxis")
        } description: {
            Text("Import an M-Pesa statement from the Activity tab to see your dashboard.")
        }
        .padding(.top, 40)
    }
}

// MARK: - Dashboard card style

private struct DashboardCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

extension View {
    func dashboardCard() -> some View {
        modifier(DashboardCardModifier())
    }
}
