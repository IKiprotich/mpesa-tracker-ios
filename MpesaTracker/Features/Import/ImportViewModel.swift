//
//  ImportViewModel.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//


import SwiftUI
import SwiftData

@MainActor
@Observable
final class ImportViewModel {

    // MARK: - State

    var showingFilePicker = false
    var isParsing = false
    var stageLabel: String? = nil
    var importError: ImportError? = nil
    var lastImportSucceeded = false
    var lastImportCount = 0

    // MARK: - Dependencies

    private let importService: ImportService

    // MARK: - Init

    init(importService: ImportService = ImportService()) {
        self.importService = importService
    }

    // MARK: - Public API

    func handlePickedFile(_ result: Result<[URL], Error>, context: ModelContext) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            beginImport(url: url, context: context)
        case .failure:
            break
        }
    }

    func clearError() {
        importError = nil
    }

    // MARK: - Private pipeline

    private func beginImport(url: URL, context: ModelContext) {
        guard !isParsing else { return }
        isParsing = true
        lastImportSucceeded = false
        stageLabel = "Reading your statement…"

        let service = importService

        Task {
            do {
                stageLabel = "Extracting transactions…"

                let result = try await Task.detached(priority: .userInitiated) {
                    try service.importStatement(from: url, into: context)
                }.value

                stageLabel = "Saving to your library…"
                try await Task.sleep(for: .milliseconds(400))

                lastImportCount = result.transactionCount
                lastImportSucceeded = true
                isParsing = false
                stageLabel = nil

                HapticFeedback.success()

            } catch let error as ImportError {
                finishWithError(error)
            } catch {
                finishWithError(.parsingFailed(reason: error.localizedDescription))
            }
        }
    }

    private func finishWithError(_ error: ImportError) {
        isParsing = false
        stageLabel = nil
        importError = error
        HapticFeedback.error()
    }
}
