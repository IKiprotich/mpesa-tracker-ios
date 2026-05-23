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
    @State private var exportURL: URL?
    @State private var exportError: ExportErrorAlert?
    @State private var isExporting = false

    private let exportService = CSVExportService()

    var body: some View {
        NavigationStack {
            List {
                importHistorySection
                personalisationSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Clear All Data",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All Transactions", role: .destructive, action: clearAllData)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all imported transactions and import history. This cannot be undone.")
            }
            .sheet(item: exportURLBinding) { wrapper in
                ShareSheet(items: [wrapper.url])
            }
            .alert(item: $exportError) { error in
                Alert(
                    title: Text("Export Failed"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // MARK: - Sections

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

    private var personalisationSection: some View {
        Section("Personalisation") {
            NavigationLink {
                CustomKeywordsView()
            } label: {
                Label("Custom Keywords", systemImage: "text.magnifyingglass")
            }
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button(action: exportCSV) {
                HStack {
                    Label("Export as CSV", systemImage: "square.and.arrow.up")
                    Spacer()
                    if isExporting {
                        ProgressView()
                    }
                }
            }
            .disabled(isExporting)

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

    // MARK: - Actions

    private func clearAllData() {
        do {
            let transactions = try modelContext.fetch(FetchDescriptor<Transaction>())
            for transaction in transactions {
                modelContext.delete(transaction)
            }

            let imports = try modelContext.fetch(FetchDescriptor<StatementImport>())
            for record in imports {
                modelContext.delete(record)
            }

            try modelContext.save()
        } catch {
            exportError = ExportErrorAlert(message: "Could not clear data. Please try again.")
        }
    }

    private func exportCSV() {
        isExporting = true
        Task.detached(priority: .userInitiated) {
            do {
                let url = try await MainActor.run {
                    try exportService.exportAllTransactions(context: modelContext)
                }
                await MainActor.run {
                    exportURL = url
                    isExporting = false
                }
            } catch {
                await MainActor.run {
                    exportError = ExportErrorAlert(
                        message: (error as? LocalizedError)?.errorDescription
                            ?? "Could not export transactions."
                    )
                    isExporting = false
                }
            }
        }
    }

    private var exportURLBinding: Binding<ShareableURL?> {
        Binding(
            get: { exportURL.map(ShareableURL.init) },
            set: { exportURL = $0?.url }
        )
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

// MARK: - Share Sheet Helpers

private struct ShareableURL: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

private struct ExportErrorAlert: Identifiable {
    let id = UUID()
    let message: String
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
