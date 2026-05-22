//
//  CategoryPickerSheet.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI
import SwiftData

struct CategoryPickerSheet: View {

    // MARK: - Properties

    @Bindable var transaction: Transaction
    @Environment(\.dismiss) private var dismiss

    @State private var selection: Category

    // MARK: - Init

    init(transaction: Transaction) {
        self.transaction = transaction
        _selection = State(initialValue: transaction.category)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List(Category.allCases) { category in
                Button {
                    selection = category
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: category.icon)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(category.color)
                            .frame(width: 32, height: 32)
                            .background(category.color.opacity(0.12), in: Circle())

                        Text(category.displayName)
                            .foregroundStyle(.primary)

                        Spacer()

                        if selection == category {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Change Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        applySelection()
                    }
                    .fontWeight(.semibold)
                    .disabled(selection == transaction.category)
                }
            }
        }
    }

    // MARK: - Private

    private func applySelection() {
        transaction.category = selection
        HapticFeedback.light()
        dismiss()
    }
}

