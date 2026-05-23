//
//  CSVExportService.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//


import Foundation
import SwiftData

// MARK: - CSVExportError

enum CSVExportError: LocalizedError {
    case noTransactions
    case fileWriteFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .noTransactions:
            return "There are no transactions to export."
        case .fileWriteFailed:
            return "Could not write the CSV file. Please try again."
        }
    }
}

// MARK: - CSVExportService

final class CSVExportService {

    // MARK: - Public

    func exportAllTransactions(context: ModelContext) throws -> URL {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.completionTime, order: .reverse)]
        )
        let transactions = try context.fetch(descriptor)

        guard !transactions.isEmpty else {
            throw CSVExportError.noTransactions
        }

        let csv = makeCSV(from: transactions)
        return try writeToTemporaryFile(csv: csv)
    }

    // MARK: - CSV Construction

    private func makeCSV(from transactions: [Transaction]) -> String {
        var lines: [String] = [Self.header]
        lines.reserveCapacity(transactions.count + 1)

        for transaction in transactions {
            lines.append(row(for: transaction))
        }

        return lines.joined(separator: "\r\n")
    }

    private func row(for transaction: Transaction) -> String {
        let fields: [String] = [
            transaction.receiptNumber,
            Self.isoFormatter.string(from: transaction.completionTime),
            transaction.details,
            transaction.status.rawValue,
            transaction.type.rawValue,
            transaction.category.rawValue,
            Self.amountFormatter.string(from: NSNumber(value: transaction.amount)) ?? "0",
            Self.amountFormatter.string(from: NSNumber(value: transaction.balance)) ?? "0",
            transaction.isCategoryOverridden ? "true" : "false"
        ]
        return fields.map(Self.escape).joined(separator: ",")
    }

    // MARK: - File Writing

    private func writeToTemporaryFile(csv: String) throws -> URL {
        let filename = "MpesaTracker_\(Self.filenameFormatter.string(from: .now)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw CSVExportError.fileWriteFailed(underlying: error)
        }
        return url
    }

    // MARK: - Constants

    private static let header = [
        "Receipt",
        "Date",
        "Details",
        "Status",
        "Type",
        "Category",
        "Amount",
        "Balance",
        "CategoryOverridden"
    ].joined(separator: ",")

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    private static let filenameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - RFC 4180 Escaping

    private static func escape(_ field: String) -> String {
        let needsQuoting = field.contains(",")
            || field.contains("\"")
            || field.contains("\n")
            || field.contains("\r")

        guard needsQuoting else { return field }
        let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
