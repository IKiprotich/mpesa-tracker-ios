//
//  ImportService.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//


import Foundation
import SwiftData

struct ImportResult {
    let transactionCount: Int
    let duplicatesSkipped: Int
    let statementImport: StatementImport
}

final class ImportService {

    // MARK: - Dependencies

    private let pdfParser: PDFParser
    private let transactionParser: TransactionParser

    // MARK: - Init

    init(
        pdfParser: PDFParser = PDFParser(),
        transactionParser: TransactionParser = TransactionParser()
    ) {
        self.pdfParser = pdfParser
        self.transactionParser = transactionParser
    }

    // MARK: - Public

    func importStatement(from url: URL, into context: ModelContext) throws -> ImportResult {

        let accessGranted = url.startAccessingSecurityScopedResource()
        defer { if accessGranted { url.stopAccessingSecurityScopedResource() } }

        let rawText: String
        do {
            rawText = try pdfParser.extractText(from: url)
        } catch let parserError as PDFParserError {
            switch parserError {
            case .noTextExtracted:
                throw ImportError.unreadablePDF
            case .couldNotOpenPDF, .fileNotFound:
                throw ImportError.invalidFile
            case .pdfHasNoPages:
                throw ImportError.unreadablePDF
            }
        }

        let parsedRows = transactionParser.parse(rawText: rawText)

        guard !parsedRows.isEmpty else {
            throw ImportError.noTransactionsFound
        }

        let existingKeys = try fetchExistingUniqueKeys(context: context)

        var inserted = 0
        var skipped = 0
        var dates: [Date] = []
        let importedAt = Date.now

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
                category: category,
                isCategoryOverridden: false,
                importedAt: importedAt
            )

            context.insert(transaction)
            dates.append(row.completionTime)
            inserted += 1
        }

        if inserted == 0 && skipped > 0 {
            throw ImportError.duplicateStatement
        }

        let sortedDates = dates.sorted()
        let record = StatementImport(
            filename: url.lastPathComponent,
            importedAt: importedAt,
            transactionCount: inserted,
            dateRangeStart: sortedDates.first,
            dateRangeEnd: sortedDates.last
        )
        context.insert(record)

        try context.save()

        return ImportResult(
            transactionCount: inserted,
            duplicatesSkipped: skipped,
            statementImport: record
        )
    }

    // MARK: - Private helpers

    private func fetchExistingUniqueKeys(context: ModelContext) throws -> Set<String> {
        let descriptor = FetchDescriptor<Transaction>()
        let existing = try context.fetch(descriptor)
        return Set(existing.map(\.uniqueKey))
    }
}
