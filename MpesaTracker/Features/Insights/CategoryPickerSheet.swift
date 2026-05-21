//
//  CategoryPickerSheet.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI
import SwiftData

// MARK: - CategoryPickerSheet

struct CategoryPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let transaction: Transaction
    @State private var selectedCategory: Category

    init(transaction: Transaction) {
        self.transaction = transaction
        _selectedCategory = State(initialValue: transaction.category)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(transaction.counterparty)
                            .font(.headline)
                        Text(AmountFormatter.formatSigned(transaction.amount))
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(transaction.isCredit ? .green : .primary)
                    }
                }

                Section("Choose Category") {
                    ForEach(Category.allCases) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(category.color.opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: category.icon)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(category.color)
                                }
                                Text(category.displayName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                }

                if transaction.isCategoryOverridden {
                    Section {
                        Button("Reset to Automatic", role: .destructive) {
                            resetToAutomatic()
                        }
                    } footer: {
                        Text("Re-runs the automatic categoriser based on the transaction details.")
                    }
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(selectedCategory == transaction.category)
                }
            }
        }
    }

    // MARK: Actions

    private func save() {
        transaction.category = selectedCategory
        try? modelContext.save()
    }

    private func resetToAutomatic() {
        let auto = Categoriser.categorise(details: transaction.details, type: transaction.type)
        transaction.rawCategory = auto.rawValue
        transaction.isCategoryOverridden = false
        try? modelContext.save()
        dismiss()
    }
}
