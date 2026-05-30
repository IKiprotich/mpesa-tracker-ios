//
//  SettingsView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 21/05/2026.
//

import SwiftUI
import SwiftData

struct SettingsView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StatementImport.importedAt, order: .reverse) private var imports: [StatementImport]

    @State private var showClearConfirmation = false
    @State private var exportURL: URL?
    @State private var exportError: SettingsError?
    @State private var isExporting = false

    private let exportService = CSVExportService()

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Settings")
                        .font(.system(size: 34, weight: .bold))
                        .tracking(-1)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 24)

                    StatementsSection(imports: imports)
                        .padding(.bottom, DesignTokens.Spacing.sectionGap)

                    appearanceSection
                        .padding(.bottom, DesignTokens.Spacing.sectionGap)

                    DataSection(
                        isExporting: isExporting,
                        onExport: exportCSV
                    )
                    .padding(.bottom, DesignTokens.Spacing.sectionGap)

                    AboutSection(version: appVersion)
                        .padding(.bottom, DesignTokens.Spacing.sectionGap)

                    DangerSection(onClearData: { showClearConfirmation = true })
                        .padding(.bottom, 24)

                    Text("Pesa Tracker")
                        .font(.system(size: 10.5, design: .monospaced))
                        .tracking(0.08)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 40)
                }
            }
        }
        .confirmationDialog(
            "Clear All Data",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete All Transactions", role: .destructive, action: clearAllData)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Removes every statement and parsed transaction from this device. Can't be undone.")
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

    // MARK: - Appearance

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(label: "Appearance")

            SettingsCard {
                Picker("Appearance", selection: themePreferenceBinding) {
                    ForEach(ThemePreference.allCases) { preference in
                        Text(preference.label).tag(preference)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
        }
    }

    private var themePreferenceBinding: Binding<ThemePreference> {
        Binding(
            get: { ThemeManager.shared.preference },
            set: { ThemeManager.shared.preference = $0 }
        )
    }

    // MARK: - Actions

    private func clearAllData() {
        do {
            let transactions = try modelContext.fetch(FetchDescriptor<Transaction>())
            transactions.forEach { modelContext.delete($0) }

            let statements = try modelContext.fetch(FetchDescriptor<StatementImport>())
            statements.forEach { modelContext.delete($0) }

            try modelContext.save()
        } catch {
            exportError = SettingsError(message: "Could not clear data. Please try again.")
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
                    exportError = SettingsError(
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
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) · build \(build)"
    }
}
