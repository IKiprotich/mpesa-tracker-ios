//
//  ImportService.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import Foundation
import SwiftData

// MARK: - ImportError

enum ImportError: LocalizedError {
    case fileAccessDenied(URL)
    case pdfFailed(PDFParserError)
    case parsingProducedNoRows
    case persistenceFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fileAccessDenied(let url):
            return "Couldn't access \(url.lastPathComponent). Try selecting the file again."
        case .pdfFailed(let underlying):
            return underlying.errorDescription
        case .parsingProducedNoRows:
            return "No transactions could be read from this statement."
        case .persistenceFailed(let error):
            return "Failed to save transactions: \(error.localizedDescription)"
        }
    }
}

// MARK: - ImportResult

struct ImportResult {
    let filename: String
    let totalParsed: Int
    let newlyInserted: Int
    let duplicatesSkipped: Int
    let dateRange: ClosedRange<Date>?
}

// MARK: - ImportService

actor ImportService {
    private let pdfParser: PDFParser
    private let transactionParser: TransactionParser

    init(
        pdfParser: PDFParser = PDFParser(),
        transactionParser: TransactionParser = TransactionParser()
    ) {
        self.pdfParser = pdfParser
        self.transactionParser = transactionParser
    }

    // MARK: Public

    func importStatement(from url: URL, into context: ModelContext) async throws -> ImportResult {
        let securityScoped = url.startAccessingSecurityScopedResource()
        defer { if securityScoped { url.stopAccessingSecurityScopedResource() } }

        let rawText: String
        do {
            rawText = try pdfParser.extractText(from: url)
        } catch let error as PDFParserError {
            throw ImportError.pdfFailed(error)
        }

        let parsedRows = transactionParser.parse(rawText: rawText)
        guard !parsedRows.isEmpty else { throw ImportError.parsingProducedNoRows }

        return try await persist(
            parsedRows: parsedRows,
            filename: url.lastPathComponent,
            into: context
        )
    }

    // MARK: Persistence

    @MainActor
    private func persist(
        parsedRows: [ParsedRow],
        filename: String,
        into context: ModelContext
    ) throws -> ImportResult {
        let existingKeys = try fetchExistingKeys(context: context)

        var inserted = 0
        var skipped = 0

        for row in parsedRows {
            if existingKeys.contains(row.uniqueKey) {
                skipped += 1
                continue
            }
            let type = TransactionType.detect(from: row.details.lowercased())
            let category = Categoriser.categorise(details: row.details, type: type)
            let transaction = Transaction(
                uniqueKey: row.uniqueKey,
                receiptNumber: row.receiptNumber,
                completionTime: row.completionTime,
                details: row.details,
                status: row.status,
                amount: row.amount,
                balance: row.balance,
                type: type,
                category: category
            )
            context.insert(transaction)
            inserted += 1
        }

        let dates = parsedRows.map(\.completionTime)
        let range: ClosedRange<Date>? = {
            guard let min = dates.min(), let max = dates.max() else { return nil }
            return min...max
        }()

        let record = StatementImport(
            filename: filename,
            transactionCount: inserted,
            dateRangeStart: range?.lowerBound,
            dateRangeEnd: range?.upperBound
        )
        context.insert(record)

        do {
            try context.save()
        } catch {
            throw ImportError.persistenceFailed(error)
        }

        return ImportResult(
            filename: filename,
            totalParsed: parsedRows.count,
            newlyInserted: inserted,
            duplicatesSkipped: skipped,
            dateRange: range
        )
    }

    @MainActor
    private func fetchExistingKeys(context: ModelContext) throws -> Set<String> {
        var descriptor = FetchDescriptor<Transaction>()
        descriptor.propertiesToFetch = [\.uniqueKey]
        let existing = try context.fetch(descriptor)
        return Set(existing.map(\.uniqueKey))
    }
}
