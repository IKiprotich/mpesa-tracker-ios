//
//  EmptyStateView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 22/05/2026.
//


import SwiftUI

struct EmptyStateView: View {

    // MARK: - Supporting types

    struct Action {
        let label: String
        let handler: () -> Void

        init(label: String, handler: @escaping () -> Void) {
            self.label = label
            self.handler = handler
        }
    }

    // MARK: - Properties

    let systemImage: String
    let title: String
    let subtitle: String
    var action: Action? = nil

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: 52, weight: .thin))
                .foregroundStyle(.tertiary)
                .padding(.bottom, 4)

            VStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            if let action {
                Button(action: action.handler) {
                    Label(action.label, systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        // Prevent the empty state from compressing inside a List/ScrollView
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

// MARK: - Previews

#Preview("With action") {
    EmptyStateView(
        systemImage: "doc.text.magnifyingglass",
        title: "No Transactions Yet",
        subtitle: "Import your first M-Pesa statement to see your spending.",
        action: .init(label: "Import Statement") {}
    )
}

#Preview("Without action") {
    EmptyStateView(
        systemImage: "magnifyingglass",
        title: "No Results",
        subtitle: "No transactions match your current search or filter."
    )
}
