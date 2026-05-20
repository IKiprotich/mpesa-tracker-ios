//
//  TransactionFilter.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import Foundation

// MARK: - TransactionFilter

enum TransactionFilter: String, CaseIterable, Identifiable {
    case all
    case sent
    case received
    case paybill
    case airtime

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all:      
            return "All"
        case .sent:     
            return "Sent"
        case .received: 
            return "Received"
        case .paybill:  
            return "Paybill"
        case .airtime:  
            return "Airtime"
        }
    }

    func matches(_ transaction: Transaction) -> Bool {
        switch self {
        case .all:
            return true
        case .sent:
            return [.sendMoney, .smallBusinessPayment, .merchantPayment, .fuliza].contains(transaction.type)
        case .received:
            return [.receiveMoney, .businessPayment].contains(transaction.type)
        case .paybill:
            return [.payBill, .paybillCharge, .cardPayment].contains(transaction.type)
        case .airtime:
            return [.airtime, .bundlePurchase].contains(transaction.type)
        }
    }
}
