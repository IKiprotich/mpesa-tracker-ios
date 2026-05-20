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
                    Text(transaction.type.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(typeColor.opacity(0.15))
                        .foregroundStyle(typeColor)
                        .clipShape(Capsule())
                    Text(transaction.completionTime, format: .dateTime.day().month().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(amountText)
                    .font(.body.monospacedDigit())
                    .fontWeight(.semibold)
                    .foregroundStyle(amountColor)
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
                .fill(typeColor.opacity(0.15))
                .frame(width: 38, height: 38)
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(typeColor)
        }
    }

    // MARK: Styling

    private var amountText: String {
        AmountFormatter.formatSigned(transaction.amount)
    }

    private var amountColor: Color {
        transaction.isCredit ? .green : .primary
    }

    private var iconName: String {
        switch transaction.type {
        case .sendMoney, .smallBusinessPayment: 
            return "arrow.up.right"
        case .receiveMoney, .businessPayment:   
            return "arrow.down.left"
        case .merchantPayment, .fuliza:         
            return "bag"
        case .payBill, .paybillCharge:          
            return "doc.text"
        case .cardPayment:                      
            return "creditcard"
        case .airtime, .bundlePurchase:         
            return "antenna.radiowaves.left.and.right"
        case .agentWithdrawal, .withdrawalCharge: 
            return "banknote"
        case .transferFee:                      
            return "minus.circle"
        case .overdraft:
            return "arrow.clockwise"
        case .unitTrust:                        
            return "chart.line.uptrend.xyaxis"
        case .international:                    
            return "globe"
        case .other:                            
            return "circle.dashed"
        }
    }

    private var typeColor: Color {
        switch transaction.type {
        case .receiveMoney, .businessPayment, .unitTrust:
            return .green
        case .sendMoney, .smallBusinessPayment:
            return .orange
        case .merchantPayment, .fuliza:
            return .blue
        case .payBill, .paybillCharge, .cardPayment:
            return .purple
        case .airtime, .bundlePurchase:
            return .pink
        case .agentWithdrawal, .withdrawalCharge:
            return .brown
        case .transferFee:
            return .gray
        case .overdraft:
            return .red
        case .international:
            return .indigo
        case .other:
            return .secondary
        }
    }
}
