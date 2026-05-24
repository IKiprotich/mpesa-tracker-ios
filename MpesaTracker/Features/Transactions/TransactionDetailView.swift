//
//  TransactionDetailView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 24/05/2026.
//

import SwiftUI

struct TransactionDetailView: View {

    let transaction: Transaction

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showingCategoryPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    hero
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 28)

                    detailsCard
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)

                    actions
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(DesignTokens.Color.deepGreen)
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle(transaction.isCredit ? "Received" : "Sent")
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerSheet(transaction: transaction)
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(alignment: .leading, spacing: 0) {
            InitialsAvatar(
                name: transaction.counterparty,
                category: transaction.isCredit ? nil : transaction.category,
                size: 48
            )
            .padding(.bottom, 14)

            Text(transaction.counterparty)
                .font(.system(size: 18, weight: .semibold))
                .tracking(-0.2)
                .foregroundStyle(.primary)
                .padding(.bottom, 6)

            HStack(spacing: 8) {
                CategoryChipView(
                    category: transaction.category,
                    overrideLabel: transaction.isCredit ? "Received" : nil
                )

                Text("·")
                    .foregroundStyle(.secondary)

                Text(transaction.type.displayName)
                    .font(.system(size: 12.5))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 22)

            heroAmount
                .padding(.bottom, 8)

            Text("Balance after · ")
                .foregroundStyle(.secondary)
                + Text("KES \(transaction.balance, format: .number.precision(.fractionLength(2)))")
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .font(.system(size: 13))
    }

    private var heroAmount: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(transaction.isCredit ? "+" : "−")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(amountColor)

            Text("KES")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            Text(abs(transaction.amount), format: .number.precision(.fractionLength(2)))
                .font(.system(size: 52, weight: .semibold))
                .tracking(-1.6)
                .monospacedDigit()
                .foregroundStyle(amountColor)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
    }

    private var amountColor: Color {
        transaction.isCredit ? DesignTokens.Color.primaryGreen : DesignTokens.Color.expenseRed
    }

    // MARK: - Details card

    private var detailsCard: some View {
        VStack(spacing: 0) {
            DetailRow(label: "Receipt",      value: transaction.receiptNumber, mono: true)
            DetailRow(label: "When",         value: transaction.completionTime.formatted(.dateTime.day().month(.wide).year().hour().minute()))
            DetailRow(label: "Counterparty", value: transaction.counterparty)
            DetailRow(label: "Type",         value: transaction.type.displayName)
            DetailRow(label: "Category",     value: transaction.category.displayName)
            DetailRow(label: "Details",      value: transaction.details, isLast: true)
        }
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    // MARK: - Actions

    private var actions: some View {
        VStack(spacing: 10) {
            Button {
                HapticFeedback.medium()
                showingCategoryPicker = true
            } label: {
                Label("Change category", systemImage: "tag")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundStyle(DesignTokens.Color.deepGreen)
                    .background(DesignTokens.Color.softGreenTint, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.button, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - DetailRow

private struct DetailRow: View {
    let label: String
    let value: String
    var mono: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(label)
                .font(.system(size: 12.5, weight: .semibold))
                .tracking(0.04)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
                .padding(.top, 2)

            Text(value)
                .font(mono ? .system(size: 13, design: .monospaced) : .system(size: 14.5))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)

        if !isLast {
            Divider()
                .padding(.leading, 116)
        }
    }
}
