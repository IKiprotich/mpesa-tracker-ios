# Pesa Tracker

An iOS app that parses your official M-Pesa transaction statement PDF and gives you a complete picture of your spending — automatically categorised, zero manual entry.

Built as a portfolio project to demonstrate real-world iOS engineering with Apple-platform frameworks.

## Screenshots

COMING SOON

## The problem

I built Pesa Tracker because I genuinely didn't know where my money was going. Every week I'd send money, pay bills, buy airtime, and by the end of the month my M-Pesa balance would be lower than expected with no clear explanation. Safaricom sends an SMS for every transaction but there's no way to see the full picture. I wanted to know exactly how much I was spending on food, transport, and utilities each month, so I built the tool I wished existed.

## The solution

Import your official M-Pesa statement PDF (exported from the M-Pesa app or MySafaricom portal). The app parses every transaction automatically, categorises spending using keyword matching, and presents a clear financial dashboard, with no manual entry and no API access required.

> Parsing a PDF the user already has is no different from reading a bank statement, no regulatory concerns, no payment processing rules.

---

## Tech stack

| Framework | Usage |
|-----------|-------|
| **SwiftUI** | All UI, including custom design system components |
| **SwiftData** | Persistence layer with `@Model` classes and `@Query` |
| **PDFKit** | Text extraction from M-Pesa statement PDFs |
| **Swift Charts** | Weekly bar chart (`BarMark`) and category donut (`SectorMark`) |

**iOS 17+ required** — `SectorMark` and SwiftData both require iOS 17.

---

## Architecture

```
MpesaTracker/
├── Core/
│   ├── Models/          # SwiftData @Model classes (Transaction, StatementImport)
│   ├── Services/        # ImportService, CSVExportService, Categoriser, CustomKeywordStore
│   └── Utilities/       # DesignTokens, AmountFormatter, DateHelpers
├── Features/
│   ├── Dashboard/       # Hero section, donut card, recent list
│   ├── Transactions/    # Activity list, row view, detail sheet
│   ├── Insights/        # Weekly bars, category donut, category breakdown
│   ├── Settings/        # Statements list, export, danger zone
│   └── Onboarding/      # Import guide
└── Parsing/
    ├── PDFParser.swift          # PDFKit text extraction
    ├── TransactionParser.swift  # Regex-based row parsing
    └── Categoriser.swift        # Keyword matching engine
```

---

## How it works

### 1. Export
The user exports their M-Pesa statement from the M-Pesa app or MySafaricom portal as a PDF. The app's onboarding walks through this step with screenshots.

### 2. Import
Via `FileImporter` picker or Share Sheet extension. Both are standard iOS patterns — no special permissions required.

### 3. Parse
```
PDFKit extracts raw text → regex identifies each transaction row →
date, amount, type, and counterparty are parsed → auto-categorisation runs
```
Each transaction gets a `uniqueKey` (based on receipt number) for deduplication across overlapping imports.

### 4. Categorise
A rule engine matches transaction details against keyword arrays per category — food, transport, utilities, groceries, health, education, entertainment, rent, savings, and more. User overrides persist via an `isCategoryOverridden` flag and a `CustomKeywordStore` backed by `UserDefaults`.

### 5. Explore
- **Dashboard** — hero spend number, top 4 categories donut, biggest transaction, recent activity
- **Activity** — transactions grouped by date, searchable, filterable by type
- **Insights** — weekly bar chart, full category donut, category breakdown with progress bars
- **Settings** — import history, CSV export, clear data

---

## Key technical decisions

**Why PDF parsing instead of SMS or API?**
Reading SMS requires special permissions and app review scrutiny. The M-Pesa API requires Safaricom partnership. Parsing a PDF the user explicitly exports sidesteps all of this — it's the same pattern as any bank statement importer.

**Why SwiftData over CoreData?**
SwiftData integrates naturally with SwiftUI's `@Query` and `@Model` macros, reducing boilerplate significantly. The `@Attribute(.unique)` constraint on `receiptNumber` handles deduplication cleanly.

**Why a custom design system?**
All colours, radii, and spacing live in `DesignTokens` — a single source of truth. Changing the primary green or card radius updates every screen. The category palette uses 8 muted tones that harmonise with the primary green without competing with it.

**Background parsing**
Large statements (500+ transactions) run on a detached `Task` with `.userInitiated` priority to avoid blocking the main thread, then update the UI on `MainActor`.

---

## Running locally

1. Clone the repo
2. Open `MpesaTracker.xcodeproj` in Xcode 15+
3. Select an iOS 17+ simulator or device
4. Build and run — no API keys or configuration needed
5. Import a real M-Pesa statement PDF to see live data

To get a statement: M-Pesa app → Statement → select date range → Export as PDF.

---

## What I'd add in v2

- iCloud sync via CloudKit
- Budget goals per category with progress tracking
- Android version with direct SMS reading 
- Share Extension improvements for smoother PDF handoff
- Widget showing current month spend on the home screen

---

## Author

**Ian Kiprotich** — iOS Developer, Nairobi  
[LinkedIn](https://linkedin.com/in/iankiprotich) · [GitHub](https://github.com/iankiprotich)
