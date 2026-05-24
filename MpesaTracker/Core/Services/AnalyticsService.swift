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
    let range: String
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

    // MARK: - Weekly spend
    static func weeklySpend(for transactions: [Transaction], in month: MonthSelection) -> [WeeklySpend] {
        let calendar  = Calendar.current
        let expenses  = transactions.filter { $0.isDebit && $0.category.isExpense }
        let monthEnd  = month.endDate
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"

        var segments: [WeeklySpend] = []
        var segmentStart = month.startDate
        var weekIndex    = 1

        while segmentStart <= monthEnd {
            guard let segmentEnd = calendar.date(byAdding: .day, value: 6, to: segmentStart) else { break }
            let clampedEnd = min(segmentEnd, monthEnd)

            let interval = DateInterval(start: segmentStart, end: clampedEnd)
            let total    = expenses
                .filter { interval.contains($0.completionTime) }
                .reduce(0.0) { $0 + abs($1.amount) }

            let startDay = dayFormatter.string(from: segmentStart)
            let endDay   = dayFormatter.string(from: clampedEnd)
            let rangeLabel = "\(startDay)–\(endDay)"

            segments.append(WeeklySpend(
                id: weekIndex,
                label: "W\(weekIndex)",
                amount: total,
                weekStart: segmentStart,
                range: rangeLabel
            ))

            guard let next = calendar.date(byAdding: .day, value: 7, to: segmentStart) else { break }
            segmentStart = next
            weekIndex   += 1
        }

        return segments
    }

    // MARK: - Month comparison

    static func monthComparison(
        current: [Transaction],
        previous: [Transaction]
    ) -> MonthComparison {
        MonthComparison(
            currentSpend: CategorySummaryBuilder.totalSpend(from: current),
            previousSpend: CategorySummaryBuilder.totalSpend(from: previous)
        )
    }

    // MARK: - Biggest transaction

    static func biggestTransaction(in transactions: [Transaction]) -> Transaction? {
        transactions
            .filter { $0.isDebit }
            .max { abs($0.amount) < abs($1.amount) }
    }

    // MARK: - Top category

    static func topCategory(in transactions: [Transaction]) -> CategorySummary? {
        CategorySummaryBuilder.build(from: transactions).first
    }

    // MARK: - Filter by month

    static func transactions(
        _ transactions: [Transaction],
        in month: MonthSelection
    ) -> [Transaction] {
        transactions.filter { month.dateInterval.contains($0.completionTime) }
    }
}
