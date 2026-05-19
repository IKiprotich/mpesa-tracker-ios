//
//  Pdfparser.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 19/05/2026.
//

import PDFKit
import Foundation

// MARK: - PDFParserError

enum PDFParserError: LocalizedError {
    case fileNotFound(URL)
    case couldNotOpenPDF(URL)
    case pdfHasNoPages(URL)
    case noTextExtracted(URL)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let url):
            return "File not found at path: \(url.path)"
        case .couldNotOpenPDF(let url):
            return "PDFKit could not open the file at: \(url.path). " +
                   "Confirm it is a valid, unencrypted PDF."
        case .pdfHasNoPages(let url):
            return "The PDF at \(url.path) contains no pages."
        case .noTextExtracted(let url):
            return "No text could be extracted from \(url.path). " +
                   "The PDF may be image-based (scanned) rather than text-based."
        }
    }
}

// MARK: - PageText
struct PageText {
    let pageNumber: Int
    let text: String
}

// MARK: - PDFParser

struct PDFParser {

    // MARK: - Production entry point
    func extractText(from url: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw PDFParserError.fileNotFound(url)
        }

        guard let pdf = PDFDocument(url: url) else {
            throw PDFParserError.couldNotOpenPDF(url)
        }

        guard pdf.pageCount > 0 else {
            throw PDFParserError.pdfHasNoPages(url)
        }

        let pages = extractPages(from: pdf)

        let fullText = pages
            .map { "---PAGE BREAK \($0.pageNumber)---\n\($0.text)" }
            .joined(separator: "\n")

        guard !fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PDFParserError.noTextExtracted(url)
        }

        return fullText
    }

    // MARK: - Debug entry point
    func extractTextByPage(from url: URL) throws -> [PageText] {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw PDFParserError.fileNotFound(url)
        }

        guard let pdf = PDFDocument(url: url) else {
            throw PDFParserError.couldNotOpenPDF(url)
        }

        guard pdf.pageCount > 0 else {
            throw PDFParserError.pdfHasNoPages(url)
        }

        return extractPages(from: pdf)
    }

    // MARK: - Private

    private func extractPages(from pdf: PDFDocument) -> [PageText] {
        (0..<pdf.pageCount).compactMap { index in
            guard let page = pdf.page(at: index) else { return nil }
            // page.string returns nil if the page has no text layer.
            let text = page.string ?? ""
            return PageText(pageNumber: index + 1, text: text)
        }
    }
}
