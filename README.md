# Pesa Tracker

> Your M-Pesa spending, finally clear.

Pesa Tracker is a free iOS app for Kenyan M-Pesa users. Import your official M-Pesa statement PDF and get a complete picture of your spending — automatically categorised, no manual entry required.

<br>

## Screenshots

<div align="center">

<table>
  <tr>
    <td align="center">
      <img width="1179" height="2556" alt="Simulator Screenshot - iPhone 15 - 2026-06-04 at 16 44 11" src="https://github.com/user-attachments/assets/34fdcd7a-c4ba-4eb1-b58a-5ec333863728" />
      <br />
      <sub><b>Dashboard</b></sub>
    </td>
    <td align="center">
      <img width="1179" height="2556" alt="Simulator Screenshot - iPhone 15 - 2026-06-04 at 16 44 20" src="https://github.com/user-attachments/assets/ef22a89d-56a4-4974-8888-51149bacdf82" />
      <br />
      <sub><b>Activity</b></sub>
    </td>
    <td align="center">
      <img width="1179" height="2556" alt="Simulator Screenshot - iPhone 15 - 2026-06-04 at 16 44 30" src="https://github.com/user-attachments/assets/adba66ea-0408-4b46-9e67-d1fb08259981" />
      <br />
      <sub><b>Transaction detail</b></sub>
    </td>
    <td align="center">
      <img width="1179" height="2556" alt="Simulator Screenshot - iPhone 15 - 2026-06-04 at 16 44 40" src="https://github.com/user-attachments/assets/e346ac9a-48bc-4959-8760-70b3bf780488" />
      <br />
      <sub><b>Insights</b></sub>
    </td>
    <td align="center">
      <img width="1179" height="2556" alt="Simulator Screenshot - iPhone 15 - 2026-06-04 at 16 45 08" src="https://github.com/user-attachments/assets/42a78a0f-1d92-47eb-b275-69e56a9af41b" />
      <br />
      <sub><b>Settings</b></sub>
    </td>
  </tr>
</table>

</div>

---

## The problem

M-Pesa is how most Kenyans move money. By the end of the month your balance is lower than expected and there's no easy way to see why. Safaricom's statement PDF has every transaction but it's a raw data dump — no categories, no totals, no trends.

## The solution

Import your statement once. Pesa Tracker reads it and gives you:

- **Dashboard** — total spent this month, top spending categories, biggest transaction
- **Activity** — full transaction list, searchable and filterable by type
- **Insights** — spending by week, spending by category, month-over-month comparison

Everything runs on your phone. Your data never leaves your device.

---

## How to use it

**1. Get your statement**

Open the M-Pesa app → Statements → choose a date range → request the PDF. Safaricom emails it to you.

**2. Save to Files**

Open the email, tap the PDF, then Share → Save to Files.

**3. Import**

Open Pesa Tracker, tap Import, select the PDF. Done.

---

## Tech stack

| | |
|---|---|
| **SwiftUI** | All UI |
| **SwiftData** | On-device storage |
| **PDFKit** | PDF reading |
| **Swift Charts** | Spending charts |

iOS 17+ required.

---

## Project structure

```
MpesaTracker/
├── Features/
│   ├── Dashboard/       # Monthly summary and recent transactions
│   ├── Transactions/    # Full activity list with search and filters
│   ├── Insights/        # Charts and category breakdown
│   ├── Settings/        # Import history, CSV export, data management
│   └── Onboarding/      # First-launch import guide
├── Parsing/             # PDF text extraction and transaction parser
└── Core/
    ├── Models/          # Transaction and StatementImport data models
    ├── Services/        # Import, analytics, categorisation, CSV export
    └── Utilities/       # Design tokens, formatters, helpers
```

---

## Running locally

```bash
git clone https://github.com/IKiprotich/pesa-tracker-ios.git
open MpesaTracker.xcodeproj
```

Select an iOS 17+ simulator or device and build. No API keys or configuration needed.

---

## Author

**Ian Kiprotich** — iOS Developer, Nairobi

[LinkedIn](https://linkedin.com/in/iankiprotich) · [GitHub](https://github.com/iankiprotich)
