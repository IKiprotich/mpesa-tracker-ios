//
//  StatementImport.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import Foundation
import SwiftData

// MARK: - StatementImport

@Model
final class StatementImport {
    var id: UUID
    var filename: String
    var importedAt: Date
    var transactionCount: Int
    var dateRangeStart: Date?
    var dateRangeEnd: Date?

    init(
        id: UUID = UUID(),
        filename: String,
        importedAt: Date = .now,
        transactionCount: Int,
        dateRangeStart: Date? = nil,
        dateRangeEnd: Date? = nil
    ) {
        self.id = id
        self.filename = filename
        self.importedAt = importedAt
        self.transactionCount = transactionCount
        self.dateRangeStart = dateRangeStart
        self.dateRangeEnd = dateRangeEnd
    }
}
