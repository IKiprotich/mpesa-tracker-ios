
//
//  Categoriser.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import Foundation

// MARK: - Categoriser

enum Categoriser {

    static func categorise(details: String, type: TransactionType) -> Category {
        if let byType = categoryFromType(type) { return byType }

        let lower = details.lowercased()
        for rule in rules where rule.matches(lower) {
            return rule.category
        }
        return fallback(for: type)
    }

    // MARK: Type-driven shortcuts

    private static func categoryFromType(_ type: TransactionType) -> Category? {
        switch type {
        case .receiveMoney,
             .businessPayment,
             .internationalReceive,
             .agentDeposit,
             .unitTrustWithdraw,
             .mShwariWithdraw,
             .ziidiSell,
             .ziidiDividend:
            return .income

        case .transferFee,
             .paybillCharge,
             .withdrawalCharge:
            return .fees

        case .agentWithdrawal:
            return .withdrawals

        case .airtime,
             .bundlePurchase:
            return .airtime

        case .overdraft:
            return .loans

        case .unitTrustInvest,
             .mShwariDeposit,
             .ziidiBuy:
            return .savings

        case .international,
             .offnetTransfer:
            return .transfers

        case .reversal:
            return .other

        default:
            return nil
        }
    }

    private static func fallback(for type: TransactionType) -> Category {
        switch type {
        case .sendMoney, .smallBusinessPayment: return .transfers
        case .merchantPayment, .fuliza:         return .other
        case .payBill, .cardPayment:            return .utilities
        default:                                return .other
        }
    }

    // MARK: Rules (ordered most-specific to least)

    private struct Rule {
        let category: Category
        let keywords: [String]

        func matches(_ lowercasedText: String) -> Bool {
            keywords.contains { lowercasedText.contains($0) }
        }
    }

    private static let rules: [Rule] = [
        Rule(category: .utilities, keywords: [
            "kplc", "kenya power", "nairobi water", "sewerage",
            "dstv", "gotv", "zuku", "faiba", "safaricomhome",
            "startimes", "telkom"
        ]),

        Rule(category: .education, keywords: [
            "strathmore", "university", "college", "school",
            "kasneb", "knec", "text book centre", "textbook"
        ]),

        Rule(category: .groceries, keywords: [
            "naivas", "quickmart", "quick mart", "carrefour",
            "chandarana", "tuskys", "magunas", "eastmatt",
            "neighbour shop", "fresh exist", "ascendin agencies",
            "china square"
        ]),

        Rule(category: .health, keywords: [
            "pharmacy", "pharmaceutical", "chemist", "hospital",
            "clinic", "pharmaplus", "goodlife", "mediplus",
            "vital pharmaceutical"
        ]),

        Rule(category: .transport, keywords: [
            "uber", "bolt", "little cab", "swvl",
            "fare", "matatu", "sgr", "rocket",
            "fuel", "petrol station", "shell", "rubis", "total energies",
            "totalenergies"
        ]),

        Rule(category: .entertainment, keywords: [
            "netflix", "showmax", "spotify", "apple.com/bill",
            "itunes", "cinema", "imax", "prime video",
            "youtube premium", "youtube member", "cinemax",
            "claude.ai"
        ]),

        Rule(category: .food, keywords: [
            "kfc", "java", "artcaffe", "subway", "pizza",
            "chicken inn", "galito", "burger", "cafe",
            "restaurant", "kitchen", "bakery", "naivas eatery",
            "onaires", "branch restaurant", "kenchic"
        ]),

        Rule(category: .rent, keywords: [
            "rent", "landlord", "apartment", "house rent",
            "nakubreeze"
        ]),

        Rule(category: .savings, keywords: [
            "ziidi", "mmf", "money market", "m-shwari",
            "kcb m-pesa", "unit trust"
        ]),

        Rule(category: .loans, keywords: [
            "loan repayment", "fuliza", "overdraw",
            "etica capital", "im bank", "standard investment bank"
        ]),

        Rule(category: .shopping, keywords: [
            "fitzroy", "thomas wambua", "asai mursik",
            "harrison juma", "pambaza", "the place",
            "lc waikiki", "budget wear", "aliexpress",
            "namecheap"
        ])
    ]
}
