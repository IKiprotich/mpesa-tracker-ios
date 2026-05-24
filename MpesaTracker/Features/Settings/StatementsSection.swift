//
//  StatementsSection.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//

import SwiftUI
import SwiftData

struct StatementsSection: View {

    let imports: [StatementImport]

    @Environment(\.modelContext) private var modelContext
    @State private var pendingDelete: StatementImport?
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(
                label: "Imported statements",
                hint: "\(imports.count) file\(imports.count == 1 ? "" : "s")"
            )

            if imports.isEmpty {
                Text("No statements imported yet")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
                    .padding(.vertical, 14)
            } else {
                SettingsCard {
                    ForEach(Array(imports.enumerated()), id: \.element.id) { index, record in
                        StatementRow(
                            record: record,
                            isCurrent: index == 0,
                            isLast: index == imports.count - 1
                        )
                        .onLongPressGesture {
                            HapticFeedback.medium()
                            pendingDelete = record
                            showDeleteConfirmation = true
                        }
                    }
                }
            }

            Text("Long press a statement to delete it. Data is stored only on this device.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineSpacing(2)
                .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
                .padding(.top, 10)
        }
        .confirmationDialog(
            "Delete Statement",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let record = pendingDelete {
                    withAnimation { delete(record) }
                }
            }
            Button("Cancel", role: .cancel) { pendingDelete = nil }
        } message: {
            if let record = pendingDelete {
                Text("Remove \"\(record.filename)\"? This only removes the import record, your M-Pesa statement file is unaffected.")
            }
        }
    }

    private func delete(_ record: StatementImport) {
        modelContext.delete(record)
        try? modelContext.save()
        pendingDelete = nil
    }
}

// MARK: - StatementRow

private struct StatementRow: View {

    let record: StatementImport
    let isCurrent: Bool
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                pdfIcon

                VStack(alignment: .leading, spacing: 3) {
                    Text(displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                if isCurrent {
                    currentBadge
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)

            if !isLast {
                Divider()
                    .padding(.leading, 70)
            }
        }
    }

    private var pdfIcon: some View {
        VStack(spacing: 2) {
            Image(systemName: "doc.fill")
                .font(.system(size: 14, weight: .medium))
            Text("PDF")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
        }
        .foregroundStyle(DesignTokens.Color.expenseRed)
        .frame(width: 38, height: 46)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(DesignTokens.Color.expenseRed.opacity(0.1))
        )
    }

    private var currentBadge: some View {
        Text("Current")
            .font(.system(size: 10, weight: .bold))
            .tracking(0.04)
            .textCase(.uppercase)
            .foregroundStyle(DesignTokens.Color.deepGreen)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(DesignTokens.Color.softGreenTint))
    }

    private var displayName: String {
        record.filename
            .replacingOccurrences(of: ".pdf", with: "", options: .caseInsensitive)
    }

    private var subtitle: String {
        "\(record.transactionCount) transactions · imported \(record.importedAt.formatted(.dateTime.day().month()))"
    }
}
