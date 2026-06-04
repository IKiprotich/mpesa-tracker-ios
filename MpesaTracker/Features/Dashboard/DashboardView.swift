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

    private var currentTransactions: [Transaction] {
        AnalyticsService.transactions(allTransactions, in: router.selectedMonth)
    }

    private var comparison: MonthComparison {
        AnalyticsService.monthComparison(
            current: currentTransactions,
            previous: AnalyticsService.transactions(allTransactions, in: router.selectedMonth.previous())
        )
    }

    private var categorySummaries: [CategorySummary] {
        CategorySummaryBuilder.build(from: currentTransactions)
    }

    private var topCategories: [CategorySummary] {
        Array(categorySummaries.prefix(4))
    }

    private var spendingAlert: SpendingAlert? {
        SpendingAlert.evaluate(from: categorySummaries)
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
                        .padding(.trailing, 20)
                        .padding(.bottom, 28)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !allTransactions.isEmpty {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Spacer()
                            monthPicker
                            Spacer()
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            viewModel.showingFilePicker = true
                        } label: {
                            Label("Import", systemImage: "square.and.arrow.down")
                        }
                        .foregroundStyle(DesignTokens.Color.deepGreen)
                    }
                }
            }
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
                    transactionCount: currentTransactions.count
                )

                if let alert = spendingAlert {
                    SpendingAlertBanner(alert: alert)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

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
            .animation(.easeInOut(duration: 0.3), value: spendingAlert != nil)
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
            },
            secondaryAction: .init(label: "Load sample data") {
                HapticFeedback.light()
                try? SampleDataService.loadSampleData(into: modelContext)
            }
        )
    }

    // MARK: - Month picker

    private var monthPicker: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    router.selectedMonth = router.selectedMonth.previous()
                }
                HapticFeedback.light()
            } label: {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .tint(.primary)

            Menu {
                ForEach(availableMonths, id: \.id) { month in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            router.selectedMonth = month
                        }
                        HapticFeedback.light()
                    } label: {
                        HStack {
                            Text(month.displayName)
                            if month == router.selectedMonth {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(router.selectedMonth.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .monospacedDigit()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                let next = router.selectedMonth.next()
                let now  = MonthSelection.current()
                guard next.year < now.year ||
                      (next.year == now.year && next.month <= now.month) else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    router.selectedMonth = next
                }
                HapticFeedback.light()
            } label: {
                Image(systemName: "chevron.forward.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .tint(.primary)
            .opacity(canStepForward ? 1 : 0.25)
            .disabled(!canStepForward)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.chip, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.chip, style: .continuous)
                        .strokeBorder(Color(.separator).opacity(0.7), lineWidth: 0.5)
                )
        )
    }

    private var canStepForward: Bool {
        let next = router.selectedMonth.next()
        let now  = MonthSelection.current()
        return next.year < now.year ||
               (next.year == now.year && next.month <= now.month)
    }

    private var availableMonths: [MonthSelection] {
        var months: [MonthSelection] = []
        var cursor = MonthSelection.current()
        for _ in 0..<12 {
            months.append(cursor)
            cursor = cursor.previous()
        }
        return months
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
