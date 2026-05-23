//
//  Transaction.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import Foundation
import SwiftData

// MARK: - Transaction

@Model
final class Transaction {
    @Attribute(.unique) var uniqueKey: String

    var receiptNumber: String
    var completionTime: Date
    var details: String
    var rawStatus: String
    var amount: Double
    var balance: Double
    var rawType: String
    var rawCategory: String
    var isCategoryOverridden: Bool
    var importedAt: Date

    init(
        uniqueKey: String,
        receiptNumber: String,
        completionTime: Date,
        details: String,
        status: ParsedRow.RowStatus,
        amount: Double,
        balance: Double,
        type: TransactionType,
        category: Category,
        isCategoryOverridden: Bool = false,
        importedAt: Date = .now
    ) {
        self.uniqueKey = uniqueKey
        self.receiptNumber = receiptNumber
        self.completionTime = completionTime
        self.details = details
        self.rawStatus = status.rawValue
        self.amount = amount
        self.balance = balance
        self.rawType = type.rawValue
        self.rawCategory = category.rawValue
        self.isCategoryOverridden = isCategoryOverridden
        self.importedAt = importedAt
    }

    // MARK: Computed

    var status: ParsedRow.RowStatus {
        ParsedRow.RowStatus(rawValue: rawStatus) ?? .unknown
    }

    var type: TransactionType {
        TransactionType(rawValue: rawType) ?? .other
    }

    var category: Category {
        get { Category(rawValue: rawCategory) ?? .other }
        set {
            rawCategory = newValue.rawValue
            isCategoryOverridden = true
        }
    }

    var paidIn: Double  { amount > 0 ? amount : 0 }
    var withdrawn: Double { amount < 0 ? abs(amount) : 0 }
    var isDebit: Bool  { amount < 0 }
    var isCredit: Bool { amount > 0 }

    var counterparty: String {
        Transaction.extractCounterparty(from: details, type: type)
    }
}

// MARK: - Counterparty extraction

extension Transaction {
    static func extractCounterparty(from details: String, type: TransactionType) -> String {
        let cleaned = details
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)

        switch type {
        case .transferFee:        return "Transfer Fee"
        case .paybillCharge:      return "Paybill Fee"
        case .withdrawalCharge:   return "Withdrawal Fee"
        case .airtime:            return "Airtime"
        case .overdraft:          return "Fuliza"
        case .unitTrustInvest:    return "Ziidi MMF"
        case .unitTrustWithdraw:  return "Ziidi MMF"
        case .cardPayment:        return extractAfter("Acc.", from: cleaned) ?? "Card Payment"
        default: break
        }

        if let merchant = extractMerchant(from: cleaned) { return merchant }
        if let name = extractPersonName(from: cleaned)   { return name }
        if let bank = extractBank(from: cleaned)         { return bank }

        return cleaned.prefix(40).description
    }

    private static func extractMerchant(from text: String) -> String? {
        guard let dashRange = text.range(of: " - ") else { return nil }
        let after = text[dashRange.upperBound...]
        let stop = after.range(of: " Acc.")?.lowerBound ?? after.endIndex
        return after[..<stop].trimmingCharacters(in: .whitespaces)
    }

    private static func extractPersonName(from text: String) -> String? {
        let pattern = #"\d{2,3}\*+\d{2,4}\s+(.+?)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges >= 2,
              let range = Range(match.range(at: 1), in: text) else { return nil }
        return text[range].trimmingCharacters(in: .whitespaces)
    }

    private static func extractBank(from text: String) -> String? {
        guard text.lowercased().contains("business payment from") else { return nil }
        if let dashRange = text.range(of: " - ") {
            let after = text[dashRange.upperBound...]
            let stop = after.range(of: " via")?.lowerBound ?? after.endIndex
            return after[..<stop].trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    private static func extractAfter(_ marker: String, from text: String) -> String? {
        guard let range = text.range(of: marker) else { return nil }
        return text[range.upperBound...].trimmingCharacters(in: .whitespaces).prefix(30).description
    }
}
