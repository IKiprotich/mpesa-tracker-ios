//
//  SettingsView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 21/05/2026.
//

import SwiftUI
import SwiftData

// MARK: - SettingsView

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StatementImport.importedAt, order: .reverse) private var imports: [StatementImport]
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                importHistorySection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Clear All Data",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All Transactions", role: .destructive) {
                    clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all imported transactions and cannot be undone.")
            }
        }
    }

    // MARK: Sections

    private var importHistorySection: some View {
        Section("Import History") {
            if imports.isEmpty {
                Text("No statements imported yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(imports) { record in
                    ImportHistoryRow(record: record)
                }
            }
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button(role: .destructive) {
                showClearConfirmation = true
            } label: {
                Label("Clear All Data", systemImage: "trash")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: appVersion)
            LabeledContent("iOS Target", value: "iOS 17+")
        }
    }

    // MARK: Actions

    private func clearAllData() {
        try? modelContext.delete(model: Transaction.self)
        try? modelContext.delete(model: StatementImport.self)
        try? modelContext.save()
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - ImportHistoryRow

private struct ImportHistoryRow: View {
    let record: StatementImport

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(record.filename)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            HStack {
                Text("\(record.transactionCount) transactions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(record.importedAt, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let start = record.dateRangeStart, let end = record.dateRangeEnd {
                Text("\(start.formatted(.dateTime.day().month())) – \(end.formatted(.dateTime.day().month().year()))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}
