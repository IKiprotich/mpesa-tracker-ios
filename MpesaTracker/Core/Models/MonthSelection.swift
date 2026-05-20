//
//  MonthSelection.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import Foundation

// MARK: - MonthSelection

struct MonthSelection: Hashable, Identifiable {
    let year: Int
    let month: Int

    var id: String { "\(year)-\(month)" }

    var startDate: Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: 1)) ?? .now
    }

    var endDate: Date {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: startDate),
              let end = calendar.date(from: DateComponents(year: year, month: month, day: range.count, hour: 23, minute: 59, second: 59))
        else { return startDate }
        return end
    }

    var dateInterval: DateInterval { DateInterval(start: startDate, end: endDate) }

    var displayName: String {
        startDate.formatted(.dateTime.month(.wide).year())
    }

    var shortDisplayName: String {
        startDate.formatted(.dateTime.month(.abbreviated).year(.twoDigits))
    }

    static func current() -> MonthSelection {
        let components = Calendar.current.dateComponents([.year, .month], from: .now)
        return MonthSelection(year: components.year ?? 2026, month: components.month ?? 1)
    }

    func previous() -> MonthSelection {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .month, value: -1, to: startDate) else { return self }
        let components = calendar.dateComponents([.year, .month], from: date)
        return MonthSelection(year: components.year ?? year, month: components.month ?? month)
    }

    func next() -> MonthSelection {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .month, value: 1, to: startDate) else { return self }
        let components = calendar.dateComponents([.year, .month], from: date)
        return MonthSelection(year: components.year ?? year, month: components.month ?? month)
    }
}
