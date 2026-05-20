//
//  CategoryDetailView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI

// MARK: - CategoryDetailView

struct CategoryDetailView: View {
    let category: Category
    let month: MonthSelection
    let transactions: [Transaction]

    private var sortedTransactions: [Transaction] {
        transactions.sorted { $0.completionTime > $1.completionTime }
    }

    private var total: Double {
        transactions.reduce(0.0) { $0 + abs($1.amount) }
    }

    var body: some View {
        List {
            Section {
                header
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .listRowBackground(Color.clear)
            }

            Section("\(transactions.count) Transactions") {
                ForEach(sortedTransactions) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(category.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: category.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(category.color)
            }

            Text(AmountFormatter.formatKES(total))
                .font(.largeTitle.monospacedDigit())
                .fontWeight(.bold)

            Text(month.displayName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
