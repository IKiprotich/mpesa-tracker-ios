//
//  CategorySummary.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import Foundation

// MARK: - CategorySummary

struct CategorySummary: Identifiable, Hashable {
    let category: Category
    let totalSpent: Double
    let transactionCount: Int
    let percentageOfTotal: Double

    var id: String { category.rawValue }
}

// MARK: - Builder

enum CategorySummaryBuilder {

    static func build(from transactions: [Transaction]) -> [CategorySummary] {
        let expenses = transactions.filter { $0.isDebit && $0.category.isExpense }
        guard !expenses.isEmpty else { return [] }

        let grouped = Dictionary(grouping: expenses, by: \.category)
        let totalSpend = expenses.reduce(0.0) { $0 + abs($1.amount) }

        return grouped
            .map { category, items in
                let spent = items.reduce(0.0) { $0 + abs($1.amount) }
                let percentage = totalSpend > 0 ? (spent / totalSpend) * 100 : 0
                return CategorySummary(
                    category: category,
                    totalSpent: spent,
                    transactionCount: items.count,
                    percentageOfTotal: percentage
                )
            }
            .sorted { $0.totalSpent > $1.totalSpent }
    }

    static func totalSpend(from transactions: [Transaction]) -> Double {
        transactions
            .filter { $0.isDebit && $0.category.isExpense }
            .reduce(0.0) { $0 + abs($1.amount) }
    }

    static func totalIncome(from transactions: [Transaction]) -> Double {
        transactions
            .filter { $0.isCredit }
            .reduce(0.0) { $0 + $1.amount }
    }
}
