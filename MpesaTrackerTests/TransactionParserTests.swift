//
//   TransactionParserTests.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 19/05/2026.
//

//
//  TransactionParserTests.swift
//  MpesaTrackerTests
//

import XCTest
@testable import MpesaTracker

// MARK: - AmountFormatter Tests

final class AmountFormatterTests: XCTestCase {

    func test_parse_standardDebit() {
        XCTAssertEqual(AmountFormatter.parse("-425.00"), -425.0)
    }

    func test_parse_standardCredit() {
        XCTAssertEqual(AmountFormatter.parse("1,000.00"), 1000.0)
    }

    func test_parse_largeDebitWithMultipleCommas() {
        XCTAssertEqual(AmountFormatter.parse("-79,000.00"), -79000.0)
    }

    func test_parse_smallAmount() {
        XCTAssertEqual(AmountFormatter.parse("-7.00"), -7.0)
    }

    func test_parse_fractionalForeignCurrency() {
        XCTAssertEqual(AmountFormatter.parse("-174.92"), -174.92)
    }

    func test_parse_appleSubscription() {
        XCTAssertEqual(AmountFormatter.parse("-132.29"), -132.29)
    }

    func test_parse_largeBalance() {
        XCTAssertEqual(AmountFormatter.parse("81,742.19"), 81742.19)
    }

    func test_parse_dashPlaceholder() {
        XCTAssertEqual(AmountFormatter.parse("-"), 0.0)
    }

    func test_parse_emDashPlaceholder() {
        XCTAssertEqual(AmountFormatter.parse("–"), 0.0)
    }

    func test_parse_emptyString() {
        XCTAssertEqual(AmountFormatter.parse(""), 0.0)
    }

    func test_parse_nil() {
        XCTAssertEqual(AmountFormatter.parse(nil), 0.0)
    }

    func test_parse_whitespaceOnlyString() {
        XCTAssertEqual(AmountFormatter.parse("   "), 0.0)
    }

    func test_parse_zero() {
        XCTAssertEqual(AmountFormatter.parse("0.00"), 0.0)
    }

    func test_parse_negativeWithCommaAndCents() {
        XCTAssertEqual(AmountFormatter.parse("-22,000.00"), -22000.0)
    }

    func test_paidIn_isZeroForDebit() {
        XCTAssertEqual(makeRow(amount: -500.0).paidIn, 0.0)
    }

    func test_withdrawn_isAbsoluteValueForDebit() {
        XCTAssertEqual(makeRow(amount: -500.0).withdrawn, 500.0)
    }

    func test_paidIn_isPositiveForCredit() {
        XCTAssertEqual(makeRow(amount: 1000.0).paidIn, 1000.0)
    }

    func test_withdrawn_isZeroForCredit() {
        XCTAssertEqual(makeRow(amount: 1000.0).withdrawn, 0.0)
    }

    func test_isDebit_trueForNegativeAmount() {
        XCTAssertTrue(makeRow(amount: -100.0).isDebit)
    }

    func test_isCredit_trueForPositiveAmount() {
        XCTAssertTrue(makeRow(amount: 100.0).isCredit)
    }

    func test_formatKES_standard() {
        XCTAssertEqual(AmountFormatter.formatKES(425.0), "KES 425.00")
    }

    func test_formatKES_withThousands() {
        XCTAssertEqual(AmountFormatter.formatKES(1000.0), "KES 1,000.00")
    }

    func test_formatKES_ignoresSign() {
        XCTAssertEqual(AmountFormatter.formatKES(-425.0), "KES 425.00")
    }

    func test_formatSigned_debit() {
        XCTAssertEqual(AmountFormatter.formatSigned(-425.0), "-KES 425.00")
    }

    func test_formatSigned_credit() {
        XCTAssertEqual(AmountFormatter.formatSigned(1000.0), "+KES 1,000.00")
    }

    private func makeRow(amount: Double) -> ParsedRow {
        ParsedRow(
            receiptNumber: "TEST123456",
            completionTime: Date(),
            details: "Test transaction",
            status: .completed,
            amount: amount,
            balance: 1000.0
        )
    }
}

// MARK: - TransactionParser Single-Block Tests

final class TransactionParserSingleBlockTests: XCTestCase {

    let parser = TransactionParser()

    func test_merchantPayment_twoLineDetails() {
        let raw = [
            "UAUGS5A5YF 2026-01-30 17:47:19 Merchant Payment Online to",
            "7053097 - QUICK MART TMALL",
            "Completed -425.00 5,077.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].receiptNumber, "UAUGS5A5YF")
        XCTAssertEqual(rows[0].amount, -425.0)
        XCTAssertEqual(rows[0].balance, 5077.19)
        XCTAssertEqual(rows[0].status, .completed)
        XCTAssertTrue(rows[0].details.contains("QUICK MART TMALL"))
        XCTAssertTrue(rows[0].details.contains("Merchant Payment Online to"))
    }

    func test_fundsReceived_threeLineDetails() {
        let raw = [
            "UASOO4Y208 2026-01-28 18:32:08 Funds received from -",
            "2547******584 VALLERY",
            "ODHIAMBO",
            "Completed 1,000.00 3,045.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].receiptNumber, "UASOO4Y208")
        XCTAssertEqual(rows[0].amount, 1000.0)
        XCTAssertEqual(rows[0].balance, 3045.19)
        XCTAssertTrue(rows[0].isCredit)
        XCTAssertTrue(rows[0].details.contains("VALLERY"))
        XCTAssertTrue(rows[0].details.contains("ODHIAMBO"))
    }

    func test_payBill_KPLC() {
        let raw = [
            "UAUGS587DV 2026-01-30 07:29:23 Pay Bill Online to 888880 - KPLC",
            "PREPAID Acc. 01450031362",
            "Completed -700.00 6,396.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, -700.0)
        XCTAssertTrue(rows[0].details.contains("KPLC"))
        XCTAssertTrue(rows[0].details.contains("888880"))
        XCTAssertTrue(rows[0].details.contains("01450031362"))
    }

    func test_transferFee_sevenShillings() {
        let raw = [
            "UAUGS5BAVQ 2026-01-30 22:56:15 Customer Transfer of Funds",
            "Charge",
            "Completed -7.00 4,750.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].receiptNumber, "UAUGS5BAVQ")
        XCTAssertEqual(rows[0].amount, -7.0)
        XCTAssertTrue(rows[0].details.contains("Transfer of Funds"))
    }

    func test_pairedRows_sameReceiptNumber_returnsTwoRows() {
        let raw = [
            "UAUGS5BAVQ 2026-01-30 22:56:15 Customer Transfer of Funds",
            "Charge",
            "Completed -7.00 4,750.19",
            "UAUGS5BAVQ 2026-01-30 22:56:15 Customer Transfer to -",
            "2547******984 ONESMUS",
            "MUSYOKI",
            "Completed -200.00 4,757.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[0].amount, -7.0)
        XCTAssertEqual(rows[1].amount, -200.0)
        XCTAssertEqual(rows[0].receiptNumber, rows[1].receiptNumber)
        XCTAssertNotEqual(rows[0].uniqueKey, rows[1].uniqueKey)
    }

    func test_bundlePurchase() {
        let raw = [
            "UAUGS58HYA 2026-01-30 09:12:07 Customer Bundle Purchase to",
            "826915Safaricom Offers by -",
            "2547******915 Ian kiprotich",
            "Completed -55.00 6,331.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, -55.0)
        XCTAssertTrue(rows[0].details.contains("Bundle Purchase"))
    }

    func test_airtime_purchase() {
        let raw = [
            "UASGS51MSP 2026-01-28 06:31:23 Airtime Purchase",
            "Completed -50.00 385.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, -50.0)
        XCTAssertEqual(rows[0].details, "Airtime Purchase")
    }

    func test_agentWithdrawal() {
        let raw = [
            "UA2GS2Q50P 2026-01-02 18:43:26 Customer Withdrawal At Agent",
            "Till 629858 - NESTPARK CAPITAL",
            "North Rift Eldoret Cbd Zion",
            "Completed -2,000.00 514.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, -2000.0)
        XCTAssertTrue(rows[0].details.contains("Withdrawal At Agent"))
        XCTAssertTrue(rows[0].details.contains("NESTPARK CAPITAL"))
    }

    func test_withdrawalCharge() {
        let raw = [
            "UA2GS2Q50P 2026-01-02 18:43:26 Withdrawal Charge",
            "Completed -29.00 485.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, -29.0)
        XCTAssertTrue(rows[0].details.contains("Withdrawal Charge"))
    }

    func test_overdraftLoanRepayment() {
        let raw = [
            "UARGS4Z29P 2026-01-27 10:41:51 OD Loan Repayment to 232323 -",
            "M-PESA Overdraw",
            "Completed -108.81 1,891.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, -108.81)
        XCTAssertTrue(rows[0].details.contains("OD Loan"))
    }

    func test_fulizaMerchantPayment() {
        let raw = [
            "UAQGS4XO1H 2026-01-26 21:07:32 Merchant Payment Fuliza M-Pesa",
            "Online to 7622036 - LINDA",
            "NYANGATE MAGETO 1",
            "Completed -150.00 0.00"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, -150.0)
        XCTAssertEqual(rows[0].balance, 0.0)
        XCTAssertTrue(rows[0].details.contains("Fuliza"))
    }

    func test_cardPayBill_spotify() {
        let raw = [
            "UA8GS37Z5K 2026-01-08 09:41:21 Card Pay Bill Online to 903470 -",
            "M-PESA GlobalPay Acc. Spotify",
            "P3E3367B5B Stockholm SE",
            "Completed -174.92 276.27"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, -174.92)
        XCTAssertTrue(rows[0].details.contains("GlobalPay"))
        XCTAssertTrue(rows[0].details.contains("Spotify"))
    }

    func test_unitTrustWithdrawal_largeAmount() {
        let raw = [
            "UA2GS2PKH2 2026-01-02 15:35:51 Unit Trust Withdraw From",
            "4145555 - ZIIDI MMF by M-",
            "PESA UnitTrust",
            "Completed 79,000.00 81,742.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, 79000.0, accuracy: 0.01)
        XCTAssertEqual(rows[0].balance, 81742.19, accuracy: 0.01)
        XCTAssertTrue(rows[0].isCredit)
    }

    func test_payBillCharge() {
        let raw = [
            "UAUGS587DV 2026-01-30 07:29:23 Pay Bill Charge",
            "Completed -10.00 6,386.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, -10.0)
        XCTAssertTrue(rows[0].details.contains("Pay Bill Charge"))
    }

    func test_smallBusinessPayment() {
        let raw = [
            "UASGS53QZ5 2026-01-28 19:05:22 Customer Payment to Small",
            "Business to - 2547******472",
            "JACKLINE NYAMOSI",
            "Completed -140.00 2,905.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, -140.0)
        XCTAssertTrue(rows[0].details.contains("Small"))
        XCTAssertTrue(rows[0].details.contains("JACKLINE NYAMOSI"))
    }

    func test_payBill_NairobiWater_largeAmount() {
        let raw = [
            "UARGS4Z3SM 2026-01-27 10:43:13 Pay Bill Online to 444400 -",
            "Nairobi Water & Sewerage Co.",
            "Ltd. Acc. 5260686",
            "Completed -1,324.00 567.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].amount, -1324.0)
        XCTAssertTrue(rows[0].details.contains("Nairobi Water"))
    }
}

// MARK: - TransactionParser Multi-Block Tests

final class TransactionParserMultiBlockTests: XCTestCase {

    let parser = TransactionParser()

    func test_midPageHeaderRow_isDiscarded() {
        let raw = [
            "Receipt Completion Time Details Status Paid In Withdrawn Balance",
            "UARGS510PK 2026-01-27 21:26:55 Customer Transfer to -",
            "2541******720 EVANS MZUNGU",
            "Completed -50.00 585.19",
            "Receipt Completion Time Details Status Paid In Withdrawn Balance",
            "UARGS50Y0M 2026-01-27 20:28:24 Customer Transfer of Funds",
            "Charge",
            "Completed -13.00 635.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 2)
    }

    func test_uniqueKey_isDistinctForPairedTransactions() {
        let raw = [
            "UARGS50Y0M 2026-01-27 20:28:24 Customer Transfer of Funds",
            "Charge",
            "Completed -13.00 635.19",
            "UARGS50Y0M 2026-01-27 20:28:24 Customer Transfer to -",
            "2547******584 VALLERY",
            "ODHIAMBO",
            "Completed -1,000.00 648.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 2)
        let keys = Set(rows.map { $0.uniqueKey })
        XCTAssertEqual(keys.count, 2)
    }

    func test_date_parsedInNairobiTimezone() {
        let raw = [
            "UAUGS5A5YF 2026-01-30 17:47:19 Merchant Payment Online to",
            "7053097 - QUICK MART TMALL",
            "Completed -425.00 5,077.19"
        ].joined(separator: "\n")

        let rows = parser.parse(rawText: raw)
        XCTAssertEqual(rows.count, 1)

        let tz = TimeZone(identifier: "Africa/Nairobi")!
        let components = Calendar.current.dateComponents(in: tz, from: rows[0].completionTime)
        XCTAssertEqual(components.hour, 17)
        XCTAssertEqual(components.minute, 47)
        XCTAssertEqual(components.day, 30)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.year, 2026)
    }

    func test_emptyInput_returnsEmptyArray() {
        XCTAssertEqual(parser.parse(rawText: "").count, 0)
    }

    func test_onlyHeadersAndFooters_returnsEmptyArray() {
        let raw = [
            "Receipt Completion Time Details Status Paid In Withdrawn Balance",
            "Disclaimer: Any personal information shared with you",
            "For self-help dial *234#"
        ].joined(separator: "\n")

        XCTAssertEqual(parser.parse(rawText: raw).count, 0)
    }
}

// MARK: - TransactionType Detection Tests

final class TransactionTypeDetectionTests: XCTestCase {

    private func detect(_ details: String) -> TransactionType {
        TransactionType.detect(from: details.lowercased())
    }

    func test_detect_merchantPayment() {
        XCTAssertEqual(detect("Merchant Payment Online to 7053097 - QUICK MART TMALL"), .merchantPayment)
    }

    func test_detect_fuliza_beforMerchantPayment() {
        XCTAssertEqual(detect("Merchant Payment Fuliza M-Pesa Online to 7622036 - LINDA NYANGATE MAGETO 1"), .fuliza)
    }

    func test_detect_payBill() {
        XCTAssertEqual(detect("Pay Bill Online to 888880 - KPLC PREPAID Acc. 01450031362"), .payBill)
    }

    func test_detect_paybillCharge() {
        XCTAssertEqual(detect("Pay Bill Charge"), .paybillCharge)
    }

    func test_detect_transferFee() {
        XCTAssertEqual(detect("Customer Transfer of Funds Charge"), .transferFee)
    }

    func test_detect_sendMoney() {
        XCTAssertEqual(detect("Customer Transfer to - 2547******984 ONESMUS MUSYOKI"), .sendMoney)
    }

    func test_detect_smallBusinessPayment() {
        XCTAssertEqual(detect("Customer Payment to Small Business to - 2547******472 JACKLINE NYAMOSI"), .smallBusinessPayment)
    }

    func test_detect_receiveMoney() {
        XCTAssertEqual(detect("Funds received from - 2547******584 VALLERY ODHIAMBO"), .receiveMoney)
    }

    func test_detect_businessPayment() {
        XCTAssertEqual(detect("Business Payment from 329299 - STANDARD CHARTERED BANK via API."), .businessPayment)
    }

    func test_detect_bundlePurchase() {
        XCTAssertEqual(detect("Customer Bundle Purchase to 826915Safaricom Offers by - 2547******915 Ian kiprotich"), .bundlePurchase)
    }

    func test_detect_recharge() {
        XCTAssertEqual(detect("Recharge for Customer to 4093441SAFARICOM DATA BUNDLES by - 2547******915 Ian kiprotich"), .bundlePurchase)
    }

    func test_detect_airtime() {
        XCTAssertEqual(detect("Airtime Purchase"), .airtime)
    }

    func test_detect_agentWithdrawal() {
        XCTAssertEqual(detect("Customer Withdrawal At Agent Till 629858 - NESTPARK CAPITAL North Rift Eldoret Cbd Zion"), .agentWithdrawal)
    }

    func test_detect_withdrawalCharge() {
        XCTAssertEqual(detect("Withdrawal Charge"), .withdrawalCharge)
    }

    func test_detect_overdraft_odLoan() {
        XCTAssertEqual(detect("OD Loan Repayment to 232323 - M-PESA Overdraw"), .overdraft)
    }

    func test_detect_overdraft_creditParty() {
        XCTAssertEqual(detect("OverDraft of Credit Party"), .overdraft)
    }

    func test_detect_unitTrust() {
        XCTAssertEqual(detect("Unit Trust Withdraw From 4145555 - ZIIDI MMF by M-PESA UnitTrust"), .unitTrustWithdraw)
    }

    func test_detect_cardPayment_globalpay() {
        XCTAssertEqual(detect("Card Pay Bill Online to 903470 - M-PESA GlobalPay Acc. Spotify P3E3367B5B Stockholm SE"), .cardPayment)
    }

    func test_detect_international() {
        XCTAssertEqual(detect("M-Pesa Global Send Money to ..."), .international)
    }

    func test_detect_other_unknownDetails() {
        XCTAssertEqual(detect("Some completely unknown transaction type"), .other)
    }
}

