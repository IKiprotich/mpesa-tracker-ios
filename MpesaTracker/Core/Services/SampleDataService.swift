//
//  SampleDataService.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 04/06/2026.
//

import Foundation
import SwiftData

/// Generates and manages a realistic demo dataset so the app can be explored
/// without importing a real M-Pesa statement PDF.
///
/// Every generated transaction is tagged with ``keyPrefix`` in both its
/// `receiptNumber` and `uniqueKey`, which lets the demo data be detected and
/// removed independently of any real, imported transactions.
enum SampleDataService {

    /// Prefix stamped onto every sample transaction so it can be identified.
    static let keyPrefix = "SAMPLE-"

    /// Filename used for the demo `StatementImport` record.
    static let filename = "Sample data"

    // MARK: - Public

    /// Loads the demo dataset into `context` unless it is already present.
    /// Mirrors `ImportService`: dedups against existing keys and records a
    /// `StatementImport` so the demo appears in the statements history.
    @discardableResult
    static func loadSampleData(into context: ModelContext) throws -> Int {
        let existingKeys = try fetchExistingUniqueKeys(context: context)

        // Already loaded — nothing to do.
        if existingKeys.contains(where: { $0.hasPrefix(keyPrefix) }) {
            return 0
        }

        let transactions = generateSampleTransactions()
        let importedAt = Date.now
        var dates: [Date] = []

        for transaction in transactions where !existingKeys.contains(transaction.uniqueKey) {
            transaction.importedAt = importedAt
            context.insert(transaction)
            dates.append(transaction.completionTime)
        }

        let sortedDates = dates.sorted()
        let record = StatementImport(
            filename: filename,
            importedAt: importedAt,
            transactionCount: dates.count,
            dateRangeStart: sortedDates.first,
            dateRangeEnd: sortedDates.last
        )
        context.insert(record)

        try context.save()
        return dates.count
    }

    /// Removes every sample transaction and the demo `StatementImport` record,
    /// leaving any real or manually-added transactions untouched.
    static func removeSampleData(from context: ModelContext) throws {
        let transactions = try context.fetch(FetchDescriptor<Transaction>())
        for transaction in transactions where transaction.uniqueKey.hasPrefix(keyPrefix) {
            context.delete(transaction)
        }

        let imports = try context.fetch(FetchDescriptor<StatementImport>())
        for record in imports where record.filename == filename {
            context.delete(record)
        }

        try context.save()
    }

    /// Returns `true` when demo data is present in `context`.
    static func hasSampleData(in context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Transaction>()
        guard let transactions = try? context.fetch(descriptor) else { return false }
        return transactions.contains { $0.uniqueKey.hasPrefix(keyPrefix) }
    }

    // MARK: - Generation

    /// Builds a deterministic, realistic set of ~55 transactions spanning the
    /// last ~75 days. Types and categories are derived through the real
    /// `TransactionType.detect` / `Categoriser` pipeline so the demo exercises
    /// the same logic as a genuine import.
    static func generateSampleTransactions() -> [Transaction] {
        let calendar = Calendar.current
        let now = Date.now

        // Oldest first so the running balance reads naturally.
        let blueprints = sampleBlueprints().sorted { $0.daysAgo > $1.daysAgo }

        var runningBalance = 6_500.0
        var transactions: [Transaction] = []

        for (index, blueprint) in blueprints.enumerated() {
            runningBalance += blueprint.amount
            if runningBalance < 0 { runningBalance = 0 }   // keep balances plausible

            let date = completionDate(
                daysAgo: blueprint.daysAgo,
                hour: blueprint.hour,
                minute: blueprint.minute,
                calendar: calendar,
                relativeTo: now
            )

            let details = blueprint.details
            let type = TransactionType.detect(from: details.lowercased())
            let category = Categoriser.categorise(details: details, type: type)
            let key = "\(keyPrefix)\(index)"

            transactions.append(
                Transaction(
                    uniqueKey: "\(key)|\(details)",
                    receiptNumber: key,
                    completionTime: date,
                    details: details,
                    status: .completed,
                    amount: blueprint.amount,
                    balance: runningBalance,
                    type: type,
                    category: category,
                    isCategoryOverridden: false,
                    importedAt: now
                )
            )
        }

        return transactions
    }

    // MARK: - Private helpers

    private static func completionDate(
        daysAgo: Int,
        hour: Int,
        minute: Int,
        calendar: Calendar,
        relativeTo now: Date
    ) -> Date {
        let day = calendar.date(byAdding: .day, value: -daysAgo, to: now) ?? now
        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: day
        ) ?? day
    }

    private static func fetchExistingUniqueKeys(context: ModelContext) throws -> Set<String> {
        let existing = try context.fetch(FetchDescriptor<Transaction>())
        return Set(existing.map(\.uniqueKey))
    }

    // MARK: - Blueprints

    private struct Blueprint {
        let daysAgo: Int
        let hour: Int
        let minute: Int
        let details: String
        let amount: Double
    }

    /// Hand-authored, recurring spending patterns across two months: monthly
    /// salary + rent, weekly groceries, frequent food/transport, utilities,
    /// transfers, savings, airtime, a loan and the occasional fee.
    private static func sampleBlueprints() -> [Blueprint] {
        [
            // ─── Income (monthly salary) ───
            Blueprint(daysAgo: 73, hour: 9,  minute: 12, details: "Funds received from 254712000111 ACME TECHNOLOGIES LTD", amount: 85_000),
            Blueprint(daysAgo: 28, hour: 9,  minute: 5,  details: "Funds received from 254712000111 ACME TECHNOLOGIES LTD", amount: 85_000),
            Blueprint(daysAgo: 41, hour: 18, minute: 47, details: "Funds received from 254701234567 BRIAN OTIENO", amount: 3_500),
            Blueprint(daysAgo: 12, hour: 13, minute: 22, details: "Funds received from 254722884455 MERCY WANJIRU", amount: 2_000),

            // ─── Rent (monthly) ───
            Blueprint(daysAgo: 70, hour: 8,  minute: 30, details: "Customer Transfer to 254700998877 - DAVID LANDLORD", amount: -28_000),
            Blueprint(daysAgo: 25, hour: 8,  minute: 15, details: "Customer Transfer to 254700998877 - DAVID LANDLORD", amount: -28_000),

            // ─── Utilities ───
            Blueprint(daysAgo: 68, hour: 19, minute: 4,  details: "Pay Bill to 888880 - KPLC PREPAID Acc. 543210987", amount: -1_500),
            Blueprint(daysAgo: 33, hour: 20, minute: 51, details: "Pay Bill to 888880 - KPLC PREPAID Acc. 543210987", amount: -2_000),
            Blueprint(daysAgo: 31, hour: 21, minute: 12, details: "Pay Bill to 444900 - DSTV KENYA Acc. 1029384756", amount: -1_550),
            Blueprint(daysAgo: 9,  hour: 18, minute: 33, details: "Pay Bill to 888880 - KPLC PREPAID Acc. 543210987", amount: -1_000),
            Blueprint(daysAgo: 18, hour: 7,  minute: 58, details: "Pay Bill to 100400 - NAIROBI WATER Acc. 88123", amount: -870),

            // ─── Groceries (weekly) ───
            Blueprint(daysAgo: 66, hour: 17, minute: 40, details: "Merchant Payment to 5076107 - NAIVAS LIMITED", amount: -4_320),
            Blueprint(daysAgo: 59, hour: 16, minute: 22, details: "Merchant Payment to 247247 - CARREFOUR KENYA", amount: -3_780),
            Blueprint(daysAgo: 45, hour: 18, minute: 11, details: "Merchant Payment to 5076107 - NAIVAS LIMITED", amount: -5_110),
            Blueprint(daysAgo: 38, hour: 15, minute: 36, details: "Merchant Payment to 220220 - QUICKMART LIMITED", amount: -2_940),
            Blueprint(daysAgo: 24, hour: 17, minute: 9,  details: "Merchant Payment to 5076107 - NAIVAS LIMITED", amount: -4_650),
            Blueprint(daysAgo: 11, hour: 19, minute: 2,  details: "Merchant Payment to 247247 - CARREFOUR KENYA", amount: -3_205),
            Blueprint(daysAgo: 4,  hour: 16, minute: 48, details: "Merchant Payment to 220220 - QUICKMART LIMITED", amount: -2_460),

            // ─── Food & dining ───
            Blueprint(daysAgo: 64, hour: 13, minute: 5,  details: "Merchant Payment to 174379 - JAVA HOUSE", amount: -1_240),
            Blueprint(daysAgo: 57, hour: 20, minute: 18, details: "Merchant Payment to 510800 - KFC KENYA", amount: -1_650),
            Blueprint(daysAgo: 50, hour: 13, minute: 44, details: "Merchant Payment to 174379 - JAVA HOUSE", amount: -980),
            Blueprint(daysAgo: 36, hour: 12, minute: 30, details: "Merchant Payment to 333222 - ARTCAFFE", amount: -2_100),
            Blueprint(daysAgo: 22, hour: 21, minute: 7,  details: "Merchant Payment to 510800 - KFC KENYA", amount: -1_430),
            Blueprint(daysAgo: 15, hour: 13, minute: 19, details: "Merchant Payment to 174379 - JAVA HOUSE", amount: -1_120),
            Blueprint(daysAgo: 6,  hour: 14, minute: 2,  details: "Merchant Payment to 333222 - ARTCAFFE", amount: -1_780),
            Blueprint(daysAgo: 1,  hour: 19, minute: 51, details: "Merchant Payment to 510800 - KFC KENYA", amount: -1_590),

            // ─── Transport ───
            Blueprint(daysAgo: 62, hour: 8,  minute: 12, details: "Pay Bill to 290400 - UBER BV Acc. RIDE", amount: -560),
            Blueprint(daysAgo: 55, hour: 22, minute: 36, details: "Pay Bill to 290033 - BOLT KENYA Acc. TRIP", amount: -430),
            Blueprint(daysAgo: 47, hour: 7,  minute: 50, details: "Pay Bill to 290400 - UBER BV Acc. RIDE", amount: -640),
            Blueprint(daysAgo: 34, hour: 18, minute: 25, details: "Merchant Payment to 880100 - SHELL RUBIS PETROL", amount: -3_000),
            Blueprint(daysAgo: 20, hour: 9,  minute: 3,  details: "Pay Bill to 290033 - BOLT KENYA Acc. TRIP", amount: -510),
            Blueprint(daysAgo: 8,  hour: 17, minute: 41, details: "Pay Bill to 290400 - UBER BV Acc. RIDE", amount: -720),
            Blueprint(daysAgo: 2,  hour: 8,  minute: 28, details: "Merchant Payment to 880100 - SHELL RUBIS PETROL", amount: -2_500),

            // ─── Airtime & data ───
            Blueprint(daysAgo: 60, hour: 10, minute: 15, details: "Airtime Purchase", amount: -200),
            Blueprint(daysAgo: 42, hour: 11, minute: 48, details: "Bundle Purchase for 254712345678", amount: -1_000),
            Blueprint(daysAgo: 26, hour: 9,  minute: 33, details: "Airtime Purchase", amount: -100),
            Blueprint(daysAgo: 10, hour: 20, minute: 5,  details: "Bundle Purchase for 254712345678", amount: -500),

            // ─── Send money (transfers) ───
            Blueprint(daysAgo: 63, hour: 14, minute: 22, details: "Customer Transfer to 254733112233 - PETER KAMAU", amount: -1_500),
            Blueprint(daysAgo: 48, hour: 19, minute: 14, details: "Customer Transfer to 254744556677 - GRACE ATIENO", amount: -3_000),
            Blueprint(daysAgo: 29, hour: 16, minute: 40, details: "Customer Transfer to 254733112233 - PETER KAMAU", amount: -2_000),
            Blueprint(daysAgo: 7,  hour: 12, minute: 11, details: "Customer Transfer to 254755443322 - SAMUEL MWANGI", amount: -2_500),

            // ─── Savings ───
            Blueprint(daysAgo: 67, hour: 9,  minute: 30, details: "M-Shwari Deposit", amount: -5_000),
            Blueprint(daysAgo: 30, hour: 9,  minute: 25, details: "M-Shwari Deposit", amount: -5_000),
            Blueprint(daysAgo: 27, hour: 10, minute: 2,  details: "Ziidi Trader Customer Buying Shares", amount: -3_000),
            Blueprint(daysAgo: 13, hour: 11, minute: 19, details: "M-Shwari Deposit", amount: -2_500),

            // ─── Cash withdrawal ───
            Blueprint(daysAgo: 51, hour: 13, minute: 8,  details: "Withdrawal at Agent 654321 - MAMA MBOGA SHOP", amount: -2_000),
            Blueprint(daysAgo: 16, hour: 15, minute: 52, details: "Withdrawal at Agent 654321 - MAMA MBOGA SHOP", amount: -1_500),

            // ─── Loans (Fuliza) ───
            Blueprint(daysAgo: 44, hour: 23, minute: 14, details: "Fuliza M-Pesa Repayment", amount: -350),
            Blueprint(daysAgo: 19, hour: 22, minute: 47, details: "Fuliza M-Pesa Repayment", amount: -1_200),

            // ─── Fees ───
            Blueprint(daysAgo: 63, hour: 14, minute: 23, details: "Transfer of Funds Charge", amount: -23),
            Blueprint(daysAgo: 51, hour: 13, minute: 9,  details: "Withdrawal Charge", amount: -28),
            Blueprint(daysAgo: 29, hour: 16, minute: 41, details: "Transfer of Funds Charge", amount: -23),
        ]
    }
}
