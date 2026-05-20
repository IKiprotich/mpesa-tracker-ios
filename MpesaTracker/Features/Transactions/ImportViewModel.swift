//
//  ImportViewModel.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import Foundation
import SwiftData
import Observation

// MARK: - ImportViewModel

@Observable
@MainActor
final class ImportViewModel {

    enum State: Equatable {
        case idle
        case importing(filename: String)
        case success(ImportResult)
        case failure(String)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle): return true
            case let (.importing(a), .importing(b)): return a == b
            case let (.success(a), .success(b)): return a.filename == b.filename && a.newlyInserted == b.newlyInserted
            case let (.failure(a), .failure(b)): return a == b
            default: return false
            }
        }
    }

    private(set) var state: State = .idle
    private let service: ImportService

    init(service: ImportService = ImportService()) {
        self.service = service
    }

    // MARK: Actions

    func importStatement(from url: URL, context: ModelContext) async {
        state = .importing(filename: url.lastPathComponent)
        do {
            let result = try await service.importStatement(from: url, into: context)
            state = .success(result)
        } catch let error as ImportError {
            state = .failure(error.errorDescription ?? "Unknown import error")
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    func dismiss() {
        state = .idle
    }
}
