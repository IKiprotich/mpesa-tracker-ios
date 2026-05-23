//
//  DashboardView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 21/05/2026.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DashboardView: View {

    // MARK: - Environment & Query

    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router

    @Query(sort: \Transaction.completionTime, order: .reverse)
    private var allTransactions: [Transaction]

    // MARK: - State

    @State private var viewModel = ImportViewModel()
    @State private var selectedMonth: MonthSelection = .current()

    // MARK: - Computed

    private var currentTransactions: [Transaction] {
        AnalyticsService.transactions(allTransactions, in: selectedMonth)
    }

    private var previousTransactions: [Transaction] {
        AnalyticsService.transactions(allTransactions, in: selectedMonth.previous())
    }

    private var comparison: MonthComparison {
        AnalyticsService.monthComparison(current: currentTransactions, previous: previousTransactions)
    }

    private var topCategory: CategorySummary? {
        AnalyticsService.topCategory(in: currentTransactions)
    }

    private var biggestTransaction: Transaction? {
        AnalyticsService.biggestTransaction(in: currentTransactions)
    }

    // MARK: - Body

    var body: some View {
        @Bindable var router = router

        NavigationStack {
            Group {
                if allTransactions.isEmpty {
                    emptyState
                } else {
                    dashboardContent
                }
            }
            .navigationTitle("Dashboard")
            .toolbar { toolbarContent }
            .fileImporter(
                isPresented: $viewModel.showingFilePicker,
                allowedContentTypes: [UTType.pdf],
                allowsMultipleSelection: false
            ) { result in
                viewModel.handlePickedFile(result, context: modelContext)
            }
            .sheet(isPresented: $viewModel.isParsing) {
                ImportProgressView(stageLabel: viewModel.stageLabel)
                    .presentationDetents([.height(200)])
                    .presentationDragIndicator(.hidden)
            }
            .alert(
                viewModel.importError?.title ?? "Import Error",
                isPresented: Binding(
                    get: { viewModel.importError != nil },
                    set: { if !$0 { viewModel.clearError() } }
                )
            ) {
                Button("OK", role: .cancel) { viewModel.clearError() }
            } message: {
                Text(viewModel.importError?.message ?? "")
            }
            .onChange(of: router.pendingImportFilename) { _, newValue in
                guard let filename = newValue else { return }
                viewModel.importFromSharedInbox(filename: filename, context: modelContext)
                router.pendingImportFilename = nil
            }
        }
    }

    // MARK: - Sub-views

    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                MonthSummaryCard(comparison: comparison, month: selectedMonth)
                RecentTransactionsList(transactions: Array(currentTransactions.prefix(5)))
            }
            .padding()
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            systemImage: "chart.pie",
            title: "Track Your M-Pesa Spending",
            subtitle: "Import your M-Pesa statement to see where your money goes — automatically categorised with zero manual entry.",
            action: .init(label: "Import Statement") {
                viewModel.showingFilePicker = true
            }
        )
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.showingFilePicker = true
            } label: {
                Label("Import Statement", systemImage: "plus.circle.fill")
            }
        }
    }
}

#Preview("Empty") {
    DashboardView()
        .environment(AppRouter())
        .modelContainer(for: Transaction.self, inMemory: true)
}
