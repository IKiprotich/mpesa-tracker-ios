//
//  Category.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI

// MARK: - Category

enum Category: String, CaseIterable, Codable, Identifiable {
    case food
    case transport
    case utilities
    case airtime
    case shopping
    case groceries
    case health
    case education
    case entertainment
    case savings
    case rent
    case transfers
    case fees
    case income
    case loans
    case withdrawals
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .food:          return "Food & Dining"
        case .transport:     return "Transport"
        case .utilities:     return "Utilities"
        case .airtime:       return "Airtime & Data"
        case .shopping:      return "Shopping"
        case .groceries:     return "Groceries"
        case .health:        return "Health"
        case .education:     return "Education"
        case .entertainment: return "Entertainment"
        case .savings:       return "Savings"
        case .rent:          return "Rent"
        case .transfers:     return "Transfers"
        case .fees:          return "Fees"
        case .income:        return "Income"
        case .loans:         return "Loans"
        case .withdrawals:   return "Cash Withdrawals"
        case .other:         return "Other"
        }
    }

    var icon: String {
        switch self {
        case .food:          return "fork.knife"
        case .transport:     return "car.fill"
        case .utilities:     return "bolt.fill"
        case .airtime:       return "antenna.radiowaves.left.and.right"
        case .shopping:      return "bag.fill"
        case .groceries:     return "cart.fill"
        case .health:        return "cross.case.fill"
        case .education:     return "book.fill"
        case .entertainment: return "tv.fill"
        case .savings:       return "chart.line.uptrend.xyaxis"
        case .rent:          return "house.fill"
        case .transfers:     return "arrow.left.arrow.right"
        case .fees:          return "minus.circle.fill"
        case .income:        return "arrow.down.left.circle.fill"
        case .loans:         return "creditcard.fill"
        case .withdrawals:   return "banknote.fill"
        case .other:         return "circle.dashed"
        }
    }

    var color: Color {
        switch self {
        case .food:          return .orange
        case .transport:     return .blue
        case .utilities:     return .yellow
        case .airtime:       return .pink
        case .shopping:      return .purple
        case .groceries:     return .green
        case .health:        return .red
        case .education:     return .indigo
        case .entertainment: return .cyan
        case .savings:       return .mint
        case .rent:          return .brown
        case .transfers:     return .teal
        case .fees:          return .gray
        case .income:        return .green
        case .loans:         return .red
        case .withdrawals:   return .brown
        case .other:         return .secondary
        }
    }

    var isExpense: Bool {
        switch self {
        case .income, .savings: return false
        default: return true
        }
    }
}
