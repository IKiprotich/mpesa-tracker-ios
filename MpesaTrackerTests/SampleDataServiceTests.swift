//
//  SampleDataServiceTests.swift
//  MpesaTrackerTests
//
//  Created by Ian Kiprotich on 04/06/2026.
//

import XCTest
import SwiftData
@testable import MpesaTracker

final class SampleDataServiceTests: XCTestCase {

    // MARK: - Helpers

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Transaction.self, StatementImport.self,
            configurations: config
        )
        return ModelContext(container)
    }

    // MARK: - Generation

    func test_generate_producesTaggedTransactions() {
        let transactions = SampleDataService.generateSampleTransactions()

        XCTAssertGreaterThanOrEqual(transactions.count, 40)
        for transaction in transactions {
            XCTAssertTrue(transaction.uniqueKey.hasPrefix(SampleDataService.keyPrefix))
            XCTAssertTrue(transaction.receiptNumber.hasPrefix(SampleDataService.keyPrefix))
            XCTAssertNotEqual(transaction.amount, 0)
        }
    }

    func test_generate_uniqueKeysAreUnique() {
        let transactions = SampleDataService.generateSampleTransactions()
        let keys = Set(transactions.map(\.uniqueKey))
        XCTAssertEqual(keys.count, transactions.count)
    }

    func test_generate_signsMatchDirection() {
        let transactions = SampleDataService.generateSampleTransactions()

        // Income should be credited (positive), expenses debited (negative).
        let income = transactions.filter { $0.type == .receiveMoney }
        XCTAssertFalse(income.isEmpty)
        XCTAssertTrue(income.allSatisfy { $0.amount > 0 })

        let expenses = transactions.filter { $0.type == .merchantPayment }
        XCTAssertFalse(expenses.isEmpty)
        XCTAssertTrue(expenses.allSatisfy { $0.amount < 0 })
    }

    func test_generate_exercisesCategoriserAcrossCategories() {
        let categories = Set(SampleDataService.generateSampleTransactions().map(\.category))

        // The blueprints are designed to cover a broad spread of categories.
        for expected in [Category.income, .utilities, .groceries, .food, .transport, .savings] {
            XCTAssertTrue(categories.contains(expected), "Missing category: \(expected)")
        }
    }

    // MARK: - Load / idempotency

    func test_load_insertsTransactionsAndImportRecord() throws {
        let context = try makeContext()

        let inserted = try SampleDataService.loadSampleData(into: context)
        XCTAssertGreaterThan(inserted, 0)

        let transactions = try context.fetch(FetchDescriptor<Transaction>())
        XCTAssertEqual(transactions.count, inserted)

        let imports = try context.fetch(FetchDescriptor<StatementImport>())
        XCTAssertEqual(imports.count, 1)
        XCTAssertEqual(imports.first?.filename, SampleDataService.filename)
        XCTAssertEqual(imports.first?.transactionCount, inserted)
    }

    func test_load_isIdempotent() throws {
        let context = try makeContext()

        let first = try SampleDataService.loadSampleData(into: context)
        let second = try SampleDataService.loadSampleData(into: context)

        XCTAssertGreaterThan(first, 0)
        XCTAssertEqual(second, 0, "Loading twice should not duplicate the demo data")

        let transactions = try context.fetch(FetchDescriptor<Transaction>())
        XCTAssertEqual(transactions.count, first)
    }

    // MARK: - Remove

    func test_remove_clearsSampleButKeepsOtherTransactions() throws {
        let context = try makeContext()
        try SampleDataService.loadSampleData(into: context)

        // A user-added transaction that must survive removal of the demo data.
        let manual = Transaction(
            uniqueKey: "MANUAL-keep|Groceries",
            receiptNumber: "MANUAL-keep",
            completionTime: .now,
            details: "Groceries",
            status: .completed,
            amount: -500,
            balance: 0,
            type: .merchantPayment,
            category: .groceries
        )
        context.insert(manual)
        try context.save()

        try SampleDataService.removeSampleData(from: context)

        let transactions = try context.fetch(FetchDescriptor<Transaction>())
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions.first?.uniqueKey, "MANUAL-keep|Groceries")
        XCTAssertFalse(SampleDataService.hasSampleData(in: context))

        let imports = try context.fetch(FetchDescriptor<StatementImport>())
        XCTAssertTrue(imports.isEmpty)
    }
}
