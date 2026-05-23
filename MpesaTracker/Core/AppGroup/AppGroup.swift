//
//  AppGroup.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//

import Foundation

// MARK: - AppGroup

enum AppGroup {

    static let identifier = "group.com.ian.MpesaTracker"

    static let urlScheme = "mpesatracker"

    static let importHost = "import"

    // MARK: - Shared container

    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }

    static var inboxURL: URL? {
        guard let container = sharedContainerURL else { return nil }
        let inbox = container.appendingPathComponent("Inbox", isDirectory: true)
        try? FileManager.default.createDirectory(at: inbox, withIntermediateDirectories: true)
        return inbox
    }

    // MARK: - Deep link

    static func makeImportURL(for filename: String) -> URL? {
        var components = URLComponents()
        components.scheme = urlScheme
        components.host = importHost
        components.queryItems = [URLQueryItem(name: "file", value: filename)]
        return components.url
    }

    static func parseImportURL(_ url: URL) -> String? {
        guard url.scheme == urlScheme, url.host == importHost else { return nil }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == "file" })?.value
    }
}
