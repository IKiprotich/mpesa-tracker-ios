//
//  RootTabView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI

// MARK: - RootTabView

struct RootTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }

            TransactionListView()
                .tabItem {
                    Label("Activity", systemImage: "list.bullet.rectangle.fill")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.pie.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
