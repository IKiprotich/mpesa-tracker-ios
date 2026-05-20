//
//  TransactionRowView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI

// MARK: - TransactionRowView

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            icon
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.counterparty)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    categoryChip
                    Text(transaction.completionTime, format: .dateTime.day().month().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(AmountFormatter.formatSigned(transaction.amount))
                    .font(.body.monospacedDigit())
                    .fontWeight(.semibold)
                    .foregroundStyle(transaction.isCredit ? .green : .primary)
                Text("Bal \(AmountFormatter.formatKES(transaction.balance))")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: Subviews

    private var icon: some View {
        ZStack {
            Circle()
                .fill(transaction.category.color.opacity(0.15))
                .frame(width: 38, height: 38)
            Image(systemName: transaction.category.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(transaction.category.color)
        }
    }

    private var categoryChip: some View {
        HStack(spacing: 4) {
            Text(transaction.category.displayName)
            if transaction.isCategoryOverridden {
                Image(systemName: "pencil")
                    .font(.system(size: 8, weight: .bold))
            }
        }
        .font(.caption)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(transaction.category.color.opacity(0.15))
        .foregroundStyle(transaction.category.color)
        .clipShape(Capsule())
    }
}
