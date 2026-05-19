//
//  Parsedrow.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 19/05/2026.
//

import Foundation

// MARK: - ParsedRow
struct ParsedRow: Equatable {

    // MARK: Stored properties
    let receiptNumber: String
    let completionTime: Date
    let details: String
    let status: RowStatus
    let amount: Double
    let balance: Double

    // MARK: Computed properties
    var paidIn: Double { amount > 0 ? amount : 0.0 }
    var withdrawn: Double { amount < 0 ? abs(amount) : 0.0 }
    var isDebit: Bool { amount < 0 }
    var isCredit: Bool { amount > 0 }
    var uniqueKey: String { "\(receiptNumber)|\(details)" }

    // MARK: - RowStatus
    enum RowStatus: String, Equatable {
        case completed = "Completed"
        case failed    = "Failed"
        case unknown
    }
}

// MARK: - CustomStringConvertible

extension ParsedRow: CustomStringConvertible {
    var description: String {
        let sign = isCredit ? "+" : ""
        let amtStr = String(format: "%.2f", amount)
        let balStr = String(format: "%.2f", balance)
        let dateStr = ISO8601DateFormatter().string(from: completionTime)
        return "[\(receiptNumber)] \(dateStr) | \(sign)\(amtStr) | bal \(balStr) | \(details)"
    }
}
