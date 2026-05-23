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
    case unitTrustInvest
    case unitTrustWithdraw
    case mShwariDeposit
    case mShwariWithdraw
    case ziidiBuy
    case ziidiSell
    case ziidiDividend
    case cardPayment
    case transferFee
    case withdrawalCharge
    case paybillCharge
    case agentDeposit
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
    case internationalReceive
    case offnetTransfer
    case reversal
    case other

    // MARK: - Classification

    static func detect(from lowercasedDetails: String) -> TransactionType {
        let d = lowercasedDetails

        if d.contains("reversal") { return .reversal }

        if d.contains("fuliza") { return .fuliza }

        if d.contains("od loan") ||
           d.contains("overdraft") ||
           d.contains("m-pesa overdraw") { return .overdraft }

        if d.contains("unit trust invest") { return .unitTrustInvest }
        if d.contains("unit trust withdraw") { return .unitTrustWithdraw }

        if d.contains("m-shwari deposit") { return .mShwariDeposit }
        if d.contains("m-shwari withdraw") { return .mShwariWithdraw }

        if d.contains("ziidi trader dividends") { return .ziidiDividend }
        if d.contains("sell shares payment") { return .ziidiSell }
        if d.contains("ziidi trader customer buying shares") { return .ziidiBuy }

        if d.contains("globalpay") ||
           d.contains("card pay bill") { return .cardPayment }

        if d.contains("transfer of funds charge") { return .transferFee }
        if d.contains("withdrawal charge") { return .withdrawalCharge }
        if d.contains("pay bill charge") ||
           d.contains("pay merchant charge") { return .paybillCharge }

        if d.contains("deposit of funds at agent") { return .agentDeposit }
        if d.contains("withdrawal at agent") { return .agentWithdrawal }

        if d.contains("offnet c2b transfer") { return .offnetTransfer }

        if d.contains("pay bill") { return .payBill }

        if d.contains("merchant payment") { return .merchantPayment }

        if d.contains("recharge for customer to 150501") ||
           d.contains("safaricomhome") { return .payBill }

        if d.contains("bundle purchase") ||
           d.contains("recharge for customer") { return .bundlePurchase }

        if d.contains("airtime") { return .airtime }

        if d.contains("payment to small business") { return .smallBusinessPayment }
        if d.contains("customer transfer to") ||
           d.contains("customer send money") { return .sendMoney }

        if d.contains("receive international transfer") { return .internationalReceive }
        if d.contains("m-pesa global") { return .international }

        if d.contains("funds received from") { return .receiveMoney }
        if d.contains("business payment from") { return .businessPayment }

        return .other
    }

    // MARK: - Display helpers

    var displayName: String {
        switch self {
        case .fuliza:                return "Fuliza Payment"
        case .overdraft:             return "Overdraft"
        case .unitTrustInvest:       return "Ziidi Invest"
        case .unitTrustWithdraw:     return "Ziidi Withdraw"
        case .mShwariDeposit:        return "M-Shwari Deposit"
        case .mShwariWithdraw:       return "M-Shwari Withdraw"
        case .ziidiBuy:              return "Ziidi Buy"
        case .ziidiSell:             return "Ziidi Sell"
        case .ziidiDividend:         return "Ziidi Dividend"
        case .cardPayment:           return "Card Payment"
        case .transferFee:           return "Transfer Fee"
        case .withdrawalCharge:      return "Withdrawal Fee"
        case .paybillCharge:         return "Paybill Fee"
        case .agentDeposit:          return "Cash Deposit"
        case .agentWithdrawal:       return "Cash Withdrawal"
        case .payBill:               return "Pay Bill"
        case .merchantPayment:       return "Merchant Payment"
        case .bundlePurchase:        return "Bundle / Data"
        case .sendMoney:             return "Send Money"
        case .smallBusinessPayment:  return "Small Business"
        case .receiveMoney:          return "Received"
        case .businessPayment:       return "Business Payment"
        case .airtime:               return "Airtime"
        case .international:         return "International Send"
        case .internationalReceive:  return "International Receive"
        case .offnetTransfer:        return "Offnet Transfer"
        case .reversal:              return "Reversal"
        case .other:                 return "Other"
        }
    }

    var isExpense: Bool {
        switch self {
        case .receiveMoney,
             .businessPayment,
             .internationalReceive,
             .agentDeposit,
             .unitTrustWithdraw,
             .mShwariWithdraw,
             .ziidiSell,
             .ziidiDividend:
            return false
        default:
            return true
        }
    }
}
