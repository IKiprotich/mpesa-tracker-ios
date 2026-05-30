//
//  MpesaTrackerApp.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 18/05/2026.
//

import SwiftUI
import SwiftData

// MARK: - MpesaTrackerApp

@main
struct MpesaTrackerApp: App {

    @State private var router = AppRouter()
    @State private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(router)
                .environment(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                .onOpenURL(perform: handleIncomingURL)
                .task {
                    await processStaleInboxItems()
                }
        }
        .modelContainer(for: [Transaction.self, StatementImport.self])
    }

    // MARK: - Deep linking

    private func handleIncomingURL(_ url: URL) {
        guard let filename = AppGroup.parseImportURL(url) else { return }
        router.selectedTab = .dashboard
        router.pendingImportFilename = filename
    }

    private func processStaleInboxItems() async {
        let urls = PendingImportInbox.pendingURLs()
        guard let latest = urls.last else { return }
        router.selectedTab = .dashboard
        router.pendingImportFilename = latest.lastPathComponent
    }
}

// MARK: - AppRouter

@Observable
final class AppRouter {

    enum Tab: Hashable {
        case dashboard
        case activity
        case insights
        case settings
    }

    var selectedTab: Tab = .dashboard
    var pendingImportFilename: String? = nil
}
