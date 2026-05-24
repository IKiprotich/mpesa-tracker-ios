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

    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router

    @Query(sort: \Transaction.completionTime, order: .reverse)
    private var allTransactions: [Transaction]

    @State private var viewModel = ImportViewModel()
    @State private var selectedMonth: MonthSelection = .current()

    private var currentTransactions: [Transaction] {
        AnalyticsService.transactions(allTransactions, in: selectedMonth)
    }

    private var comparison: MonthComparison {
        AnalyticsService.monthComparison(
            current: currentTransactions,
            previous: AnalyticsService.transactions(allTransactions, in: selectedMonth.previous())
        )
    }

    private var topCategories: [CategorySummary] {
        Array(CategorySummaryBuilder.build(from: currentTransactions).prefix(4))
    }

    private var biggestTransaction: Transaction? {
        AnalyticsService.biggestTransaction(in: currentTransactions)
    }

    private var recentTransactions: [Transaction] {
        Array(currentTransactions.prefix(5))
    }

    var body: some View {
        @Bindable var router = router

        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if allTransactions.isEmpty {
                        emptyState
                    } else {
                        scrollContent
                    }
                }

                if !allTransactions.isEmpty {
                    ImportFAB { viewModel.showingFilePicker = true }
                        .padding(.trailing, DesignTokens.Spacing.screenHorizontal)
                        .padding(.bottom, 96)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Pesa Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(
                isPresented: $viewModel.showingFilePicker,
                allowedContentTypes: [UTType.pdf],
                allowsMultipleSelection: false,
                onCompletion: { viewModel.handlePickedFile($0, context: modelContext) }
            )
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
            .onChange(of: router.pendingImportFilename) { _, filename in
                guard let filename else { return }
                viewModel.importFromSharedInbox(filename: filename, context: modelContext)
                router.pendingImportFilename = nil
            }
        }
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sectionGap) {
                DashboardHeroSection(
                    comparison: comparison,
                    transactionCount: currentTransactions.count,
                    selectedMonth: $selectedMonth
                )

                DashboardDonutCard(
                    categories: topCategories,
                    totalSpend: comparison.currentSpend
                )

                if let biggest = biggestTransaction {
                    DashboardBiggestCard(transaction: biggest)
                }

                DashboardRecentList(transactions: recentTransactions)

                Color.clear.frame(height: 100)
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Empty state

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
}

// MARK: - ImportFAB

private struct ImportFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                Text("Import")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(DesignTokens.Color.deepGreen, in: Capsule())
            .shadow(color: DesignTokens.Color.deepGreen.opacity(0.45), radius: 16, x: 0, y: 8)
        }
    }
}

#Preview("Empty") {
    DashboardView()
        .environment(AppRouter())
        .modelContainer(for: Transaction.self, inMemory: true)
}
