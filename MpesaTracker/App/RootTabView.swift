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
            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle")
                }

            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "chart.pie.fill")
                }
        }
    }
}
