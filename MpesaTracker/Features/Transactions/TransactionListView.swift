//
//  TransactionListView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TransactionListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router

    @Query(sort: \Transaction.completionTime, order: .reverse)
    private var allTransactions: [Transaction]

    @State private var viewModel = ImportViewModel()
    @State private var searchText = ""
    @State private var activeFilter: TransactionFilter = .all
    @State private var selectedTransaction: Transaction?
    @State private var showingAddTransaction = false

    private var availableMonths: [MonthSelection] {
        let calendar = Calendar.current
        var seen = Set<MonthSelection>()
        for tx in allTransactions {
            let comps = calendar.dateComponents([.year, .month], from: tx.completionTime)
            if let y = comps.year, let m = comps.month {
                seen.insert(MonthSelection(year: y, month: m))
            }
        }
        return seen.sorted { ($0.year, $0.month) > ($1.year, $1.month) }
    }

    private var monthTransactions: [Transaction] {
        AnalyticsService.transactions(allTransactions, in: router.selectedMonth)
    }

    private var filteredTransactions: [Transaction] {
        monthTransactions.filter { transaction in
            guard activeFilter.matches(transaction) else { return false }
            guard !searchText.isEmpty else { return true }
            return transaction.counterparty.localizedCaseInsensitiveContains(searchText)
                || transaction.details.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedTransactions: [(key: Date, transactions: [Transaction])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredTransactions) {
            calendar.startOfDay(for: $0.completionTime)
        }
        return grouped
            .map { (key: $0.key, transactions: $0.value) }
            .sorted { $0.key > $1.key }
    }

    private var monthlySummary: (spent: Double, received: Double) {
        let spent    = filteredTransactions.filter(\.isDebit).reduce(0)  { $0 + abs($1.amount) }
        let received = filteredTransactions.filter(\.isCredit).reduce(0) { $0 + $1.amount }
        return (spent, received)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if allTransactions.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticFeedback.light()
                        showingAddTransaction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add transaction")
                }
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            .sheet(isPresented: $showingAddTransaction) {
                TransactionEditView(mode: .add)
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
            .onAppear {
                if !availableMonths.contains(router.selectedMonth), let first = availableMonths.first {
                    router.selectedMonth = first
                }
            }
            .onChange(of: allTransactions) { _, _ in
                if !availableMonths.contains(router.selectedMonth), let first = availableMonths.first {
                    router.selectedMonth = first
                }
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
        }
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                header

                Section {
                    searchBar
                        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 4)

                    filterChips
                        .padding(.bottom, 12)
                }

                if filteredTransactions.isEmpty {
                    noResultsView
                } else {
                    transactionGroups
                }

                Color.clear.frame(height: 100)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        @Bindable var router = router
        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Spacer()

                MonthPill(selectedMonth: $router.selectedMonth, availableMonths: availableMonths)
            }

            HStack(spacing: 4) {
                Text("\(filteredTransactions.count) transactions")
                    .foregroundStyle(.secondary)

                Text("·")
                    .foregroundStyle(.secondary)

                Text("−\(monthlySummary.spent, format: .number.precision(.fractionLength(0)))")
                    .foregroundStyle(DesignTokens.Color.expenseRed)
                    .fontWeight(.semibold)
                    .monospacedDigit()

                Text("·")
                    .foregroundStyle(.secondary)

                Text("+\(monthlySummary.received, format: .number.precision(.fractionLength(0)))")
                    .foregroundStyle(DesignTokens.Color.primaryGreen)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }
            .font(.system(size: 13.5))
        }
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.system(size: 16))

            TextField("Search transactions", text: $searchText)
                .font(.system(size: 15))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            } else {
                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 14))
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Filter chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransactionFilter.allCases) { filter in
                    ActivityFilterChip(
                        label: filter.displayName,
                        isSelected: activeFilter == filter
                    ) {
                        HapticFeedback.light()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
    }

    // MARK: - Transaction groups

    private var transactionGroups: some View {
        ForEach(groupedTransactions, id: \.key) { group in
            transactionGroup(date: group.key, transactions: group.transactions)
        }
    }

    private func transactionGroup(date: Date, transactions: [Transaction]) -> some View {
        let dailySpent    = transactions.filter(\.isDebit).reduce(0)  { $0 + abs($1.amount) }
        let dailyReceived = transactions.filter(\.isCredit).reduce(0) { $0 + $1.amount }

        return VStack(spacing: 0) {
            ActivityDateHeader(
                date: date,
                spent: dailySpent,
                received: dailyReceived
            )
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)

            VStack(spacing: 0) {
                ForEach(Array(transactions.enumerated()), id: \.element.uniqueKey) { index, transaction in
                    TransactionRowView(transaction: transaction)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                        .onTapGesture { selectedTransaction = transaction }

                    if index < transactions.count - 1 {
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            .padding(.bottom, DesignTokens.Spacing.sectionGap)
        }
    }

    // MARK: - Empty states

    private var emptyState: some View {
        EmptyStateView(
            systemImage: "doc.text.magnifyingglass",
            title: "No Transactions Yet",
            subtitle: "Import your M-Pesa statement to see all your transactions here.",
            action: .init(label: "Import Statement") {
                viewModel.showingFilePicker = true
            },
            secondaryAction: .init(label: "Load sample data") {
                HapticFeedback.light()
                try? SampleDataService.loadSampleData(into: modelContext)
            }
        )
    }

    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(.secondary)

            Text("No results")
                .font(.system(size: 17, weight: .semibold))

            Text("Try a different search or filter.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

// MARK: - MonthPill

private struct MonthPill: View {
    @Binding var selectedMonth: MonthSelection
    let availableMonths: [MonthSelection]

    var body: some View {
        Menu {
            ForEach(availableMonths) { month in
                Button {
                    selectedMonth = month
                } label: {
                    if month == selectedMonth {
                        Label(month.displayName, systemImage: "checkmark")
                    } else {
                        Text(month.displayName)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedMonth.displayName)
                    .font(.system(size: 13.5, weight: .semibold))

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
        }
    }
}

// MARK: - ActivityDateHeader

private struct ActivityDateHeader: View {
    let date: Date
    let spent: Double
    let received: Double

    private var summaryText: String {
        var parts: [String] = []
        if spent > 0    { parts.append("−\(Int(spent).formatted())") }
        if received > 0 { parts.append("+\(Int(received).formatted())") }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(date, format: .dateTime.weekday(.abbreviated).day().month())
                .font(.system(size: 12.5, weight: .semibold))
                .tracking(0.06)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            Spacer()

            Text(summaryText)
                .font(.system(size: 12.5, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - ActivityFilterChip

private struct ActivityFilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13.5, weight: .semibold))
                .tracking(-0.05)
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(
                    isSelected
                        ? Color(.label)
                        : Color(.secondarySystemGroupedBackground),
                    in: Capsule()
                )
                .foregroundStyle(
                    isSelected
                        ? Color(.systemBackground)
                        : Color(.label)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(Color(.separator).opacity(isSelected ? 0 : 0.6), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    TransactionListView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
