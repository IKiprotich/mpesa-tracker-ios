//
//  RecentTransactionsList.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 22/05/2026.
//

import SwiftUI

struct RecentTransactionsList: View {

    // MARK: - Properties

    let transactions: [Transaction]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent")
                .font(.headline)

            if transactions.isEmpty {
                Text("No transactions this month.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                            .padding(.vertical, 4)

                        if transaction.id != transactions.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}
