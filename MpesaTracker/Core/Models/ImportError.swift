//
//  ImportError.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 22/05/2026.
//


import Foundation

enum ImportError: LocalizedError, Equatable {

    case invalidFile

    case unreadablePDF

    case noTransactionsFound

    case duplicateStatement

    case parsingFailed(reason: String)

    // MARK: - LocalizedError conformance

    var errorDescription: String? { title }

    var title: String {
        switch self {
        case .invalidFile:
            return "Not an M-Pesa Statement"
        case .unreadablePDF:
            return "Couldn't Read This PDF"
        case .noTransactionsFound:
            return "No Transactions Found"
        case .duplicateStatement:
            return "Already Imported"
        case .parsingFailed:
            return "Import Failed"
        }
    }

    var message: String {
        switch self {
        case .invalidFile:
            return "This doesn't look like an M-Pesa statement. Make sure you're importing the PDF exported from the M-Pesa app or MySafaricom portal."
        case .unreadablePDF:
            return "This PDF appears to be a scanned image and can't be read as text. Try exporting a fresh statement directly from the M-Pesa app."
        case .noTransactionsFound:
            return "We couldn't find any transactions in this PDF. It may be an older statement format. Try exporting a new statement from the M-Pesa app."
        case .duplicateStatement:
            return "This statement overlaps with one you've already imported. Any new transactions have been added; duplicates were skipped."
        case .parsingFailed(let reason):
            return "Something went wrong while reading your statement. \(reason)"
        }
    }

    // MARK: - Equatable

    static func == (lhs: ImportError, rhs: ImportError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidFile, .invalidFile),
             (.unreadablePDF, .unreadablePDF),
             (.noTransactionsFound, .noTransactionsFound),
             (.duplicateStatement, .duplicateStatement):
            return true
        case (.parsingFailed(let l), .parsingFailed(let r)):
            return l == r
        default:
            return false
        }
    }
}
