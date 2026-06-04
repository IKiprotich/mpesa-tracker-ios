//
//  TransactionEditView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 04/06/2026.
//

import SwiftUI
import SwiftData

/// A form for adding a transaction by hand or editing an existing one.
///
/// Edits are made against local draft state and only written back to the
/// `Transaction` (or inserted) once validation passes, so a cancelled edit
/// never mutates the model.
struct TransactionEditView: View {

    enum Mode {
        case add
        case edit(Transaction)
    }

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Draft state

    private let mode: Mode

    @State private var direction: Direction
    @State private var amountText: String
    @State private var details: String
    @State private var date: Date
    @State private var type: TransactionType
    @State private var category: Category
    @State private var status: ParsedRow.RowStatus
    @State private var balanceText: String

    /// Tracks whether the user picked the category themselves. While `false`,
    /// the category keeps following the auto-suggestion as details/type change.
    @State private var categoryManuallySet: Bool

    @State private var showDeleteConfirmation = false

    // MARK: - Init

    init(mode: Mode) {
        self.mode = mode

        switch mode {
        case .add:
            _direction = State(initialValue: .moneyOut)
            _amountText = State(initialValue: "")
            _details = State(initialValue: "")
            _date = State(initialValue: .now)
            _type = State(initialValue: .other)
            _category = State(initialValue: .other)
            _status = State(initialValue: .completed)
            _balanceText = State(initialValue: "")
            _categoryManuallySet = State(initialValue: false)

        case let .edit(transaction):
            _direction = State(initialValue: transaction.amount < 0 ? .moneyOut : .moneyIn)
            _amountText = State(initialValue: Self.editableString(abs(transaction.amount)))
            _details = State(initialValue: transaction.details)
            _date = State(initialValue: transaction.completionTime)
            _type = State(initialValue: transaction.type)
            _category = State(initialValue: transaction.category)
            _status = State(initialValue: transaction.status == .failed ? .failed : .completed)
            _balanceText = State(initialValue: Self.editableString(transaction.balance))
            _categoryManuallySet = State(initialValue: transaction.isCategoryOverridden)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                amountSection
                detailsSection
                classificationSection
                advancedSection

                if isEditing {
                    deleteSection
                }
            }
            .navigationTitle(isEditing ? "Edit Transaction" : "Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
            .onChange(of: details) { refreshSuggestedCategory() }
            .onChange(of: type) { refreshSuggestedCategory() }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Sections

    private var amountSection: some View {
        Section("Amount") {
            Picker("Direction", selection: $direction) {
                ForEach(Direction.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 8) {
                Text("KES")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 15, weight: .medium))

                TextField("0.00", text: $amountText)
                    .keyboardType(.decimalPad)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(direction == .moneyOut
                                     ? DesignTokens.Color.expenseRed
                                     : DesignTokens.Color.primaryGreen)
            }
        }
    }

    private var detailsSection: some View {
        Section("Details") {
            TextField("Description (e.g. Naivas, John Doe)", text: $details, axis: .vertical)
                .lineLimit(1...3)

            DatePicker("Date & time", selection: $date, in: ...Date.now)
        }
    }

    private var classificationSection: some View {
        Section("Classification") {
            Picker("Type", selection: $type) {
                ForEach(TransactionType.allCases, id: \.self) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.navigationLink)

            Picker("Category", selection: $category) {
                ForEach(Category.allCases) { option in
                    Label(option.displayName, systemImage: option.icon).tag(option)
                }
            }
            .pickerStyle(.navigationLink)
            .onChange(of: category) { categoryManuallySet = true }
        }
    }

    private var advancedSection: some View {
        Section {
            Picker("Status", selection: $status) {
                Text("Completed").tag(ParsedRow.RowStatus.completed)
                Text("Failed").tag(ParsedRow.RowStatus.failed)
            }
            .pickerStyle(.segmented)

            HStack(spacing: 8) {
                Text("Balance after")
                Spacer()
                TextField("Optional", text: $balanceText)
                    .keyboardType(.decimalPad)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("More")
        } footer: {
            Text("Balance after the transaction is optional and used only for display.")
        }
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Label("Delete transaction", systemImage: "trash")
                    Spacer()
                }
            }
            .confirmationDialog(
                "Delete this transaction?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) { delete() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Validation

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var parsedAmount: Double? {
        let cleaned = amountText
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)
        guard let value = Double(cleaned), value > 0 else { return nil }
        return value
    }

    private var isValid: Bool {
        parsedAmount != nil && !details.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Category suggestion

    private func refreshSuggestedCategory() {
        guard !categoryManuallySet else { return }
        let suggestion = Categoriser.categorise(details: details, type: type)
        if suggestion != category {
            category = suggestion
            // `onChange(of: category)` would flip the manual flag, so reset it.
            categoryManuallySet = false
        }
    }

    // MARK: - Persistence

    private func save() {
        guard let amount = parsedAmount else { return }

        let trimmedDetails = details.trimmingCharacters(in: .whitespaces)
        let signedAmount = direction == .moneyOut ? -amount : amount
        let balance = Double(balanceText.replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)) ?? 0

        switch mode {
        case .add:
            let id = UUID().uuidString
            let transaction = Transaction(
                uniqueKey: "MANUAL-\(id)|\(trimmedDetails)",
                receiptNumber: "MANUAL-\(id.prefix(8))",
                completionTime: date,
                details: trimmedDetails,
                status: status,
                amount: signedAmount,
                balance: balance,
                type: type,
                category: category,
                isCategoryOverridden: categoryManuallySet
            )
            modelContext.insert(transaction)

        case let .edit(transaction):
            transaction.details = trimmedDetails
            transaction.completionTime = date
            transaction.amount = signedAmount
            transaction.balance = balance
            transaction.rawType = type.rawValue
            transaction.rawStatus = status.rawValue
            // Setting `category` flags the override; only do so when it changed.
            if transaction.category != category {
                transaction.category = category
            }
        }

        do {
            try modelContext.save()
            HapticFeedback.success()
            dismiss()
        } catch {
            // Leave the sheet open so the user can retry.
            HapticFeedback.error()
        }
    }

    private func delete() {
        guard case let .edit(transaction) = mode else { return }
        modelContext.delete(transaction)
        try? modelContext.save()
        HapticFeedback.medium()
        dismiss()
    }

    // MARK: - Helpers

    /// Formats a `Double` for an editable text field: no thousands separators,
    /// and whole numbers without a trailing ".0".
    private static func editableString(_ value: Double) -> String {
        if value == value.rounded() {
            return String(Int(value))
        }
        return String(format: "%.2f", value)
    }
}

// MARK: - Direction

private enum Direction: CaseIterable, Identifiable {
    case moneyOut
    case moneyIn

    var id: Self { self }

    var label: String {
        switch self {
        case .moneyOut: return "Money out"
        case .moneyIn:  return "Money in"
        }
    }
}

#Preview("Add") {
    TransactionEditView(mode: .add)
        .modelContainer(for: Transaction.self, inMemory: true)
}
