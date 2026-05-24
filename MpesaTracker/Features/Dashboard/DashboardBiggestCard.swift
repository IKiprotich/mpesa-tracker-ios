//
//  DashboardBiggestCard.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 24/05/2026.
//

import SwiftUI

// MARK: - DashboardBiggestCard
struct DashboardBiggestCard: View {

    let transaction: Transaction

    // MARK: - Body

    var body: some View {
        HStack(spacing: 14) {
            InitialsAvatar(
                name: transaction.counterparty,
                category: transaction.category,
                size: 40
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("Biggest this month")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Text(transaction.counterparty)
                    .font(.system(size: 15.5, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    CategoryChipView(category: transaction.category)

                    Text(transaction.completionTime, format: .dateTime.day().month().hour().minute())
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            Text("−\(abs(transaction.amount), format: .number.precision(.fractionLength(0)))")
                .font(.system(size: 22, weight: .semibold))
                .tracking(-0.7)
                .monospacedDigit()
                .foregroundStyle(DesignTokens.Color.expenseRed)
        }
        .padding(DesignTokens.Spacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
    }
}
