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

    // MARK: - Environment & Query

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Transaction.completionTime, order: .reverse)
    private var allTransactions: [Transaction]

    // MARK: - State

    @State private var viewModel = ImportViewModel()
    @State private var searchText = ""
    @State private var activeFilter: TransactionFilter = .all
    @State private var selectedTransaction: Transaction? = nil

    // MARK: - Computed

    private var filteredTransactions: [Transaction] {
        allTransactions.filter { transaction in
            let matchesFilter = activeFilter.matches(transaction)
            guard matchesFilter else { return false }
            guard !searchText.isEmpty else { return true }
            return transaction.counterparty.localizedCaseInsensitiveContains(searchText)
                || transaction.details.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var hasAnyTransactions: Bool { !allTransactions.isEmpty }
    private var hasResults: Bool { !filteredTransactions.isEmpty }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if !hasAnyTransactions {
                    noDataEmptyState
                } else {
                    transactionList
                }
            }
            .navigationTitle("Activity")
            .searchable(text: $searchText, prompt: "Search transactions")
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
        }
    }

    // MARK: - Sub-views

    private var transactionList: some View {
        VStack(spacing: 0) {
            filterChipsRow

            if !hasResults {
                noResultsEmptyState
            } else {
                List {
                    ForEach(filteredTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                            .onTapGesture {
                                selectedTransaction = transaction
                            }
                            .onLongPressGesture {
                                HapticFeedback.medium()
                                selectedTransaction = transaction
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .animation(.easeInOut(duration: 0.3), value: filteredTransactions.map(\.uniqueKey))
            }
        }
        .sheet(item: $selectedTransaction) { transaction in
            CategoryPickerSheet(transaction: transaction)
        }
    }

    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransactionFilter.allCases) { filter in
                    FilterChip(
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
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(.background)
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

    // MARK: - Empty states

    private var noDataEmptyState: some View {
        EmptyStateView(
            systemImage: "doc.text.magnifyingglass",
            title: "No Transactions Yet",
            subtitle: "Import your M-Pesa statement to see all your transactions here.",
            action: .init(label: "Import Statement") {
                viewModel.showingFilePicker = true
            }
        )
    }

    private var noResultsEmptyState: some View {
        EmptyStateView(
            systemImage: "magnifyingglass",
            title: "No Results",
            subtitle: "No transactions match your current search or filter.",
            action: activeFilter != .all ? .init(label: "Clear Filter") {
                HapticFeedback.light()
                withAnimation { activeFilter = .all }
            } : nil
        )
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - FilterChip

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    isSelected ? Color.accentColor : Color(.secondarySystemFill),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview("Empty — no data") {
    TransactionListView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
