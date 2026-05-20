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
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [Transaction.self, StatementImport.self])
    }
}
