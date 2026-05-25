//
//  SpendingAlertBanner.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 25/05/2026.
//

import SwiftUI

// MARK: - SpendingAlert

struct SpendingAlert: Equatable {
    let category: Category
    let percentage: Double
    let amount: Double

    static func evaluate(from summaries: [CategorySummary], threshold: Double = 50) -> SpendingAlert? {
        guard let top = summaries.first, top.percentageOfTotal >= threshold else { return nil }
        return SpendingAlert(
            category: top.category,
            percentage: top.percentageOfTotal,
            amount: top.totalSpent
        )
    }
}

// MARK: - SpendingAlertBanner

struct SpendingAlertBanner: View {

    let alert: SpendingAlert

    @State private var isDismissed = false

    private var categoryColor: Color {
        switch alert.category {
        case .food, .groceries: return DesignTokens.CategoryColor.food
        case .transport:        return DesignTokens.CategoryColor.transport
        case .utilities:        return DesignTokens.CategoryColor.utilities
        case .airtime:          return DesignTokens.CategoryColor.airtime
        case .shopping:         return DesignTokens.CategoryColor.shopping
        case .rent, .fees:      return DesignTokens.CategoryColor.bills
        default:                return DesignTokens.CategoryColor.other
        }
    }

    var body: some View {
        if !isDismissed {
            HStack(spacing: 14) {
                iconBadge

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(alert.category.displayName) is \(Int(alert.percentage))% of your spend")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text("KES \(alert.amount, format: .number.precision(.fractionLength(0))) this month — is this expected?")
                        .font(.system(size: 12.5))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isDismissed = true
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card, style: .continuous)
                    .fill(categoryColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.card, style: .continuous)
                            .strokeBorder(categoryColor.opacity(0.25), lineWidth: 1)
                    )
            )
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onChange(of: alert) {
                isDismissed = false
            }
        }
    }

    private var iconBadge: some View {
        Image(systemName: alert.category.icon)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(categoryColor)
            .frame(width: 36, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(categoryColor.opacity(0.15))
            )
    }
}
