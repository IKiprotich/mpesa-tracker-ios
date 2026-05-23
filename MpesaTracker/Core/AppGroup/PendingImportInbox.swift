//
//  PendingImportInbox.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//

import Foundation

// MARK: - PendingImportInbox

enum PendingImportInbox {

    // MARK: - Public

    static func pendingURLs() -> [URL] {
        guard let inbox = AppGroup.inboxURL else { return [] }

        let contents = (try? FileManager.default.contentsOfDirectory(
            at: inbox,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        return contents
            .filter { $0.pathExtension.lowercased() == "pdf" }
            .sorted { lhs, rhs in
                modificationDate(of: lhs) < modificationDate(of: rhs)
            }
    }

    static func url(forFilename filename: String) -> URL? {
        guard let inbox = AppGroup.inboxURL else { return nil }
        let candidate = inbox.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: candidate.path) ? candidate : nil
    }

    static func remove(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Private

    private static func modificationDate(of url: URL) -> Date {
        let values = try? url.resourceValues(forKeys: [.contentModificationDateKey])
        return values?.contentModificationDate ?? .distantPast
    }
}
