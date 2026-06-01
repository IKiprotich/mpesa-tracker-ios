//
//  RootTabView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI

// MARK: - RootTabView

struct RootTabView: View {

    @Environment(AppRouter.self) private var router
    @AppStorage(OnboardingConstants.hasCompletedOnboardingKey) private var hasCompletedOnboarding = false

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
                .tag(AppRouter.Tab.dashboard)

            TransactionListView()
                .tabItem {
                    Label("Activity", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(AppRouter.Tab.activity)

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.pie.fill")
                }
                .tag(AppRouter.Tab.insights)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppRouter.Tab.settings)
        }
        .fullScreenCover(isPresented: onboardingBinding) {
            OnboardingView()
        }
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !hasCompletedOnboarding },
            set: { show in if !show { hasCompletedOnboarding = true } }
        )
    }
}
