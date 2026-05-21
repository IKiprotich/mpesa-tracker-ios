//
//  AnalyticsService.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 21/05/2026.
//

import Foundation

// MARK: - WeeklySpend

struct WeeklySpend: Identifiable {
    let id: Int
    let label: String
    let amount: Double
    let weekStart: Date
}

// MARK: - MonthComparison

struct MonthComparison {
    let currentSpend: Double
    let previousSpend: Double

    var change: Double {
        guard previousSpend > 0 else { return 0 }
        return ((currentSpend - previousSpend) / previousSpend) * 100
    }

    var isIncrease: Bool { currentSpend >= previousSpend }
    var hasComparison: Bool { previousSpend > 0 }
}

// MARK: - AnalyticsService

enum AnalyticsService {

    static func weeklySpend(for transactions: [Transaction], in month: MonthSelection) -> [WeeklySpend] {
        let calendar = Calendar.current
        let expenses = transactions.filter { $0.isDebit && $0.category.isExpense }

        let weeksInMonth = calendar.range(of: .weekOfMonth, in: .month, for: month.startDate)
        let weekCount = weeksInMonth?.count ?? 5

        return (1...weekCount).compactMap { week -> WeeklySpend? in
            guard let weekStart = calendar.date(
                from: DateComponents(
                    year: month.year,
                    month: month.month,
                    weekday: calendar.firstWeekday, weekOfMonth: week
                )
            ) else { return nil }

            guard let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else { return nil }
            let interval = DateInterval(start: weekStart, end: weekEnd)

            let weekTransactions = expenses.filter { interval.contains($0.completionTime) }
            let total = weekTransactions.reduce(0.0) { $0 + abs($1.amount) }

            return WeeklySpend(
                id: week,
                label: "Wk \(week)",
                amount: total,
                weekStart: weekStart
            )
        }
    }

    static func monthComparison(
        current: [Transaction],
        previous: [Transaction]
    ) -> MonthComparison {
        MonthComparison(
            currentSpend: CategorySummaryBuilder.totalSpend(from: current),
            previousSpend: CategorySummaryBuilder.totalSpend(from: previous)
        )
    }

    static func biggestTransaction(in transactions: [Transaction]) -> Transaction? {
        transactions
            .filter { $0.isDebit }
            .max { abs($0.amount) < abs($1.amount) }
    }

    static func topCategory(in transactions: [Transaction]) -> CategorySummary? {
        CategorySummaryBuilder.build(from: transactions).first
    }

    static func transactions(
        _ transactions: [Transaction],
        in month: MonthSelection
    ) -> [Transaction] {
        let interval = month.dateInterval
        return transactions.filter { interval.contains($0.completionTime) }
    }
}
