//
//  AmountFormatter.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 19/05/2026.
//

import Foundation

// MARK: - AmountFormatter

enum AmountFormatter {

    // MARK: - Parsing
    static func parse(_ raw: String?) -> Double {
        guard let raw else { return 0.0 }

        let trimmed = raw.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty, trimmed != "-", trimmed != "–" else { return 0.0 }

        let cleaned = trimmed.replacingOccurrences(of: ",", with: "")

        guard let value = Double(cleaned) else {
            print("⚠️ AmountFormatter: could not parse '\(raw)' → returning 0.0")
            return 0.0
        }

        return value
    }

    // MARK: - Formatting for display
    static func formatKES(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."

        let formatted = formatter.string(from: NSNumber(value: abs(amount))) ?? "0.00"
        return "KES \(formatted)"
    }

    static func formatSigned(_ amount: Double) -> String {
        let prefix = amount >= 0 ? "+" : "-"
        return "\(prefix)\(formatKES(amount))"
    }
}
