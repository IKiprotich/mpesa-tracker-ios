//
//  Transactiontype.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 19/05/2026.
//

import Foundation

// MARK: - TransactionType
enum TransactionType: String, CaseIterable, Codable {

    // MARK: Cases
    case fuliza
    case overdraft
    case unitTrust
    case cardPayment
    case transferFee
    case withdrawalCharge
    case paybillCharge
    case agentWithdrawal
    case payBill
    case merchantPayment
    case bundlePurchase
    case sendMoney
    case smallBusinessPayment
    case receiveMoney
    case businessPayment
    case airtime
    case international
    case other

    // MARK: - Classification
    static func detect(from lowercasedDetails: String) -> TransactionType {
        let d = lowercasedDetails

        if d.contains("fuliza"){ return
            .fuliza }

        // Overdraft rows
        if d.contains("od loan") ||
           d.contains("overdraft") ||
           d.contains("m-pesa overdraw"){ return
            .overdraft }

        // Unit trust
        if d.contains("unit trust"){ return
            .unitTrust }

        // GlobalPay card payment
        if d.contains("globalpay") ||
           d.contains("card pay bill"){ return
            .cardPayment }

        // Fee rows
        if d.contains("transfer of funds charge"){ return
            .transferFee }
        if d.contains("withdrawal charge"){ return
            .withdrawalCharge }
        if d.contains("pay bill charge"){ return
            .paybillCharge }

        //  Withdrawal
        if d.contains("withdrawal at agent"){ return
            .agentWithdrawal
        }

        // Paybill
        if d.contains("pay bill"){ return
            .payBill
        }

        //  Merchant (till number)
        if d.contains("merchant payment"){ return
            .merchantPayment
        }

        // Bundles / Recharge
        if d.contains("bundle purchase") ||
            d.contains("recharge for customer"){ return
                .bundlePurchase
        }

        // Airtime
        if d.contains("airtime"){ return
            .airtime
        }

        //  P2P sends
        if d.contains("payment to small business"){ return
            .smallBusinessPayment
        }
        if d.contains("customer transfer to"){ return
            .sendMoney
        }

        // Receives
        if d.contains("funds received from"){ return
            .receiveMoney
        }

        // Business / bank credits
        if d.contains("business payment from"){ return
            .businessPayment
        }

        // International
        if d.contains("m-pesa global"){ return
            .international
        }

        return .other
    }

    // MARK: - Display helpers
    var displayName: String {
        switch self {
        case .fuliza:              
            return "Fuliza Payment"
        case .overdraft:           
            return "Overdraft"
        case .unitTrust:           
            return "Unit Trust"
        case .cardPayment:         
            return "Card Payment"
        case .transferFee:         
            return "Transfer Fee"
        case .withdrawalCharge:    
            return "Withdrawal Fee"
        case .paybillCharge:       
            return "Paybill Fee"
        case .agentWithdrawal:     
            return "Cash Withdrawal"
        case .payBill:             
            return "Pay Bill"
        case .merchantPayment:     
            return "Merchant Payment"
        case .bundlePurchase:      
            return "Bundle / Data"
        case .sendMoney:           
            return "Send Money"
        case .smallBusinessPayment:
            return "Small Business"
        case .receiveMoney:        
            return "Received"
        case .businessPayment:     
            return "Business Payment"
        case .airtime:             
            return "Airtime"
        case .international:       
            return "International"
        case .other:               
            return "Other"
        }
    }
    var isExpense: Bool {
        switch self {
        case .receiveMoney, .businessPayment, .unitTrust: return false
        default: return true
        }
    }
}
