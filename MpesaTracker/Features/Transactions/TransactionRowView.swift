//
//  TransactionRowView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI

struct TransactionRowView: View {

    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            InitialsAvatar(
                name: transaction.counterparty,
                category: transaction.isCredit ? nil : transaction.category,
                size: 40
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.counterparty)
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(-0.15)
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    CategoryChipView(
                        category: transaction.category,
                        overrideLabel: transaction.isCredit ? "Received" : nil
                    )

                    Text(transaction.completionTime, format: .dateTime.hour().minute())
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)

                    Text("·")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 11.5))

                    Text(transaction.type.displayName)
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            amountColumn
        }
        .padding(.vertical, 12)
    }

    private var amountColumn: some View {
        let isCredit = transaction.isCredit
        let prefix   = isCredit ? "+" : "−"
        let color: Color = isCredit ? DesignTokens.Color.primaryGreen : DesignTokens.Color.expenseRed

        return Text("\(prefix)\(abs(transaction.amount), format: .number.precision(.fractionLength(0)))")
            .font(.system(size: 15.5, weight: .semibold))
            .tracking(-0.2)
            .monospacedDigit()
            .foregroundStyle(color)
    }
}
