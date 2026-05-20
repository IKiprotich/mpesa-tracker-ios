//
//  TransactionListView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - TransactionListView

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.completionTime, order: .reverse) private var transactions: [Transaction]

    @State private var viewModel = ImportViewModel()
    @State private var searchText = ""
    @State private var filter: TransactionFilter = .all
    @State private var isImporterPresented = false
    @State private var transactionForCategoryEdit: Transaction?

    private var filteredTransactions: [Transaction] {
        transactions
            .filter { filter.matches($0) }
            .filter { searchText.isEmpty || matchesSearch($0, query: searchText) }
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Transactions")
                .toolbar { toolbarContent }
                .searchable(text: $searchText, prompt: "Search transactions")
                .fileImporter(
                    isPresented: $isImporterPresented,
                    allowedContentTypes: [.pdf],
                    allowsMultipleSelection: false
                ) { result in
                    handleFileImport(result)
                }
                .overlay { importOverlay }
                .alert(alertTitle, isPresented: alertIsPresented, presenting: viewModel.state) { _ in
                    Button("OK") { viewModel.dismiss() }
                } message: { state in
                    Text(alertMessage(for: state))
                }
                .sheet(item: $transactionForCategoryEdit) { transaction in
                    CategoryPickerSheet(transaction: transaction)
                }
        }
    }

    // MARK: Content

    @ViewBuilder
    private var content: some View {
        if transactions.isEmpty {
            emptyState
        } else {
            VStack(spacing: 0) {
                filterChips
                list
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Transactions Yet", systemImage: "doc.text.magnifyingglass")
        } description: {
            Text("Import an M-Pesa statement PDF to see your transactions.")
        } actions: {
            Button("Import Statement") { isImporterPresented = true }
                .buttonStyle(.borderedProminent)
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransactionFilter.allCases) { option in
                    FilterChip(
                        title: option.displayName,
                        isSelected: filter == option
                    ) {
                        filter = option
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.bar)
    }

    private var list: some View {
        List(filteredTransactions) { transaction in
            TransactionRowView(transaction: transaction)
                .contentShape(Rectangle())
                .contextMenu {
                    Button {
                        transactionForCategoryEdit = transaction
                    } label: {
                        Label("Change Category", systemImage: "tag")
                    }
                }
        }
        .listStyle(.plain)
        .overlay {
            if filteredTransactions.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isImporterPresented = true
            } label: {
                Image(systemName: "square.and.arrow.down")
            }
        }
    }

    // MARK: Import overlay

    @ViewBuilder
    private var importOverlay: some View {
        if case .importing(let filename) = viewModel.state {
            ZStack {
                Color.black.opacity(0.3).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView().controlSize(.large)
                    Text("Parsing \(filename)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: Alerts

    private var alertIsPresented: Binding<Bool> {
        Binding(
            get: {
                if case .success = viewModel.state { return true }
                if case .failure = viewModel.state { return true }
                return false
            },
            set: { newValue in
                if !newValue { viewModel.dismiss() }
            }
        )
    }

    private var alertTitle: String {
        if case .failure = viewModel.state { return "Import Failed" }
        return "Import Complete"
    }

    private func alertMessage(for state: ImportViewModel.State) -> String {
        switch state {
        case .success(let result):
            var lines = ["Added \(result.newlyInserted) transactions."]
            if result.duplicatesSkipped > 0 {
                lines.append("\(result.duplicatesSkipped) duplicates skipped.")
            }
            return lines.joined(separator: "\n")
        case .failure(let message):
            return message
        default:
            return ""
        }
    }

    // MARK: Actions

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            Task {
                await viewModel.importStatement(from: url, context: modelContext)
            }
        case .failure(let error):
            print("FileImporter error: \(error.localizedDescription)")
        }
    }

    private func matchesSearch(_ transaction: Transaction, query: String) -> Bool {
        let q = query.lowercased()
        return transaction.details.lowercased().contains(q)
            || transaction.counterparty.lowercased().contains(q)
            || transaction.receiptNumber.lowercased().contains(q)
            || transaction.category.displayName.lowercased().contains(q)
    }
}

// MARK: - FilterChip

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.15))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
