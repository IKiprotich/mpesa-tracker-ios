//
//  Transactionparser.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 19/05/2026.
//


import Foundation

struct TransactionParser {

    private static let headerRegex = try! NSRegularExpression(
        pattern: #"^([A-Z0-9]{8,12})\s+(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+(.*)$"#
    )

    private static let statusRegex = try! NSRegularExpression(
        pattern: #"^(Completed|Failed)\s+([-\d,]+\.\d{2})\s+([\d,]+\.\d{2})"#
    )

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "Africa/Nairobi")
        return f
    }()

    func parse(rawText: String) -> [ParsedRow] {
        let lines = rawText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !shouldDiscard($0) }

        let blocks = groupIntoBlocks(lines)
        return blocks.compactMap { parseBlock($0) }
    }

    private func shouldDiscard(_ line: String) -> Bool {
        guard !line.isEmpty else { return true }
        if line.hasPrefix("---PAGE BREAK") { return true }
        if line.hasPrefix("Receipt") && line.contains("Completion Time") { return true }
        if line.hasPrefix("Disclaimer:") { return true }
        if line.hasPrefix("For self-help dial") { return true }
        if line == "Balance" { return true }
        return false
    }

    private func groupIntoBlocks(_ lines: [String]) -> [[String]] {
        var blocks: [[String]] = []
        var current: [String] = []

        for line in lines {
            if isReceiptLine(line) {
                if !current.isEmpty { blocks.append(current) }
                current = [line]
            } else {
                current.append(line)
                if isStatusLine(line) {
                    blocks.append(current)
                    current = []
                }
            }
        }

        if !current.isEmpty { blocks.append(current) }
        return blocks
    }

    private func parseBlock(_ lines: [String]) -> ParsedRow? {
        guard !lines.isEmpty else { return nil }

        guard let headerLine = lines.first,
              let headerCaptures = captures(of: Self.headerRegex, in: headerLine),
              headerCaptures.count >= 3 else { return nil }

        let receiptNumber = headerCaptures[0]
        let dateString    = headerCaptures[1]
        let detailsStart  = headerCaptures[2]

        guard let completionTime = dateFormatter.date(from: dateString) else {
            print("⚠️ TransactionParser: could not parse date '\(dateString)' for receipt '\(receiptNumber)'")
            return nil
        }

        guard let statusLine = lines.last(where: { isStatusLine($0) }),
              let statusCaptures = captures(of: Self.statusRegex, in: statusLine),
              statusCaptures.count >= 3 else {
            print("⚠️ TransactionParser: no valid status line found in block for receipt '\(receiptNumber)'")
            return nil
        }

        let status  = ParsedRow.RowStatus(rawValue: statusCaptures[0]) ?? .unknown
        let amount  = AmountFormatter.parse(statusCaptures[1])
        let balance = AmountFormatter.parse(statusCaptures[2])
        let details = collectDetails(lines: lines, detailsStart: detailsStart)

        return ParsedRow(
            receiptNumber: receiptNumber,
            completionTime: completionTime,
            details: details,
            status: status,
            amount: amount,
            balance: balance
        )
    }

    private func collectDetails(lines: [String], detailsStart: String) -> String {
        var parts: [String] = []
        if !detailsStart.isEmpty { parts.append(detailsStart) }

        for line in lines.dropFirst() {
            if isStatusLine(line) { break }
            let t = line.trimmingCharacters(in: .whitespaces)
            if !t.isEmpty { parts.append(t) }
        }

        return parts.joined(separator: " ")
    }

    private func isReceiptLine(_ line: String) -> Bool {
        // A genuine receipt line begins with the receipt ID *and* a date/time.
        // Requiring the full header pattern (not just the ID prefix) prevents
        // continuation lines that happen to start with an all-caps word — e.g.
        // "NYANGATE MAGETO" or a reference like "P3E3367B5B Stockholm" — from
        // being mistaken for the start of a new transaction.
        let t = line.trimmingCharacters(in: .whitespaces)
        let range = NSRange(t.startIndex..., in: t)
        return Self.headerRegex.firstMatch(in: t, range: range) != nil
    }

    private func isStatusLine(_ line: String) -> Bool {
        let t = line.trimmingCharacters(in: .whitespaces)
        let range = NSRange(t.startIndex..., in: t)
        return Self.statusRegex.firstMatch(in: t, range: range) != nil
    }

    private func captures(of regex: NSRegularExpression, in string: String) -> [String]? {
        let t = string.trimmingCharacters(in: .whitespaces)
        let nsString = t as NSString
        let fullRange = NSRange(location: 0, length: nsString.length)
        guard let match = regex.firstMatch(in: t, range: fullRange) else { return nil }

        return (1..<match.numberOfRanges).compactMap { i in
            let range = match.range(at: i)
            guard range.location != NSNotFound else { return nil }
            return nsString.substring(with: range)
        }
    }
}
