//
//  DashboardRecentList.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 24/05/2026.
//

import SwiftUI

// MARK: - DashboardRecentList

struct DashboardRecentList: View {

    let transactions: [Transaction]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
                .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)

            if transactions.isEmpty {
                emptyRow
            } else {
                transactionCard
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Recent activity")
                .font(.system(size: 18, weight: .semibold))
                .tracking(-0.3)
                .foregroundStyle(.primary)

            Spacer()

            Text("See all")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DesignTokens.Color.deepGreen)
        }
    }

    // MARK: - Transaction card

    private var transactionCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(transactions.enumerated()), id: \.element.uniqueKey) { index, transaction in
                DashboardTransactionRow(transaction: transaction)
                    .padding(.horizontal, 16)

                if index < transactions.count - 1 {
                    Divider()
                        .padding(.leading, 68) // aligns with text, clears avatar
                }
            }
        }
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
    }

    // MARK: - Empty row

    private var emptyRow: some View {
        Text("No transactions this month.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            .padding(.vertical, 8)
    }
}

// MARK: - DashboardTransactionRow

private struct DashboardTransactionRow: View {

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
                    .font(.system(size: 14.5, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    CategoryChipView(
                        category: transaction.category,
                        overrideLabel: transaction.isCredit ? "Received" : nil
                    )

                    Text(transaction.completionTime, format: .dateTime.day().month().hour().minute())
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            amountLabel
        }
        .padding(.vertical, 10)
    }

    private var amountLabel: some View {
        let isCredit = transaction.isCredit
        let prefix   = isCredit ? "+" : "−"
        let color    = isCredit ? DesignTokens.Color.primaryGreen : DesignTokens.Color.expenseRed

        return Text("\(prefix)\(abs(transaction.amount), format: .number.precision(.fractionLength(0)))")
            .font(.system(size: 15.5, weight: .semibold))
            .tracking(-0.2)
            .monospacedDigit()
            .foregroundStyle(color)
    }
}

// MARK: - InitialsAvatar

struct InitialsAvatar: View {

    let name: String
    let category: Category?
    let size: CGFloat

    private var initials: String {
        let words = name.split(separator: " ").prefix(2)
        return words.compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    private var avatarColor: Color {
        guard let category else { return DesignTokens.Color.softGreenTint }
        return designColor(for: category)
    }

    private var foregroundColor: Color {
        guard let category else { return DesignTokens.Color.deepGreen }
        return designForeground(for: category)
    }

    var body: some View {
        Text(initials.isEmpty ? "?" : initials)
            .font(.system(size: size * 0.325, weight: .bold))
            .foregroundStyle(foregroundColor)
            .frame(width: size, height: size)
            .background(avatarColor, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.avatar, style: .continuous))
    }

    // MARK: - Colour mapping

    private func designColor(for category: Category) -> Color {
        switch category {
        case .food, .groceries: return DesignTokens.CategoryColor.food.opacity(0.22)
        case .transport:        return DesignTokens.CategoryColor.transport.opacity(0.22)
        case .utilities:        return DesignTokens.CategoryColor.utilities.opacity(0.22)
        case .airtime:          return DesignTokens.CategoryColor.airtime.opacity(0.22)
        case .shopping:         return DesignTokens.CategoryColor.shopping.opacity(0.22)
        case .rent, .fees:      return DesignTokens.CategoryColor.bills.opacity(0.22)
        default:                return DesignTokens.CategoryColor.other.opacity(0.22)
        }
    }

    private func designForeground(for category: Category) -> Color {
        switch category {
        case .food, .groceries: return Color(hex: "#8A5A1F")
        case .transport:        return Color(hex: "#2E5878")
        case .utilities:        return Color(hex: "#564487")
        case .airtime:          return Color(hex: "#8A4444")
        case .shopping:         return Color(hex: "#3D6655")
        case .rent, .fees:      return Color(hex: "#735B3A")
        default:                return DesignTokens.Color.secondary
        }
    }
}

// MARK: - CategoryChipView

struct CategoryChipView: View {

    let category: Category
    var overrideLabel: String? = nil

    private var label: String { overrideLabel ?? category.displayName }

    private var chipBackground: Color {
        chipColor.opacity(0.18)
    }

    private var chipForeground: Color {
        chipColor
    }

    private var chipColor: Color {
        switch category {
        case .food, .groceries: return DesignTokens.CategoryColor.food
        case .transport:        return DesignTokens.CategoryColor.transport
        case .utilities:        return DesignTokens.CategoryColor.utilities
        case .airtime:          return DesignTokens.CategoryColor.airtime
        case .shopping:         return DesignTokens.CategoryColor.shopping
        case .rent, .fees:      return DesignTokens.CategoryColor.bills
        case .income:           return DesignTokens.Color.primaryGreen
        default:                return DesignTokens.CategoryColor.other
        }
    }

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold))
            .tracking(-0.02)
            .foregroundStyle(chipForeground)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(chipBackground, in: Capsule())
    }
}
