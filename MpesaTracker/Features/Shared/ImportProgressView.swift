//
//  ImportProgressView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 22/05/2026.
//


import SwiftUI

struct ImportProgressView: View {

    // MARK: - Properties

    var stageLabel: String?

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.4)
                .tint(.accentColor)

            Text(stageLabel ?? "Reading your statement…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .animation(.easeInOut, value: stageLabel)
        }
        .padding(40)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .interactiveDismissDisabled()
    }
}

// MARK: - Previews

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        ImportProgressView(stageLabel: "Categorising transactions…")
    }
}
