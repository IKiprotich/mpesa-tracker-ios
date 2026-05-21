//
//  MonthPickerView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 20/05/2026.
//

import SwiftUI

// MARK: - MonthPickerView

struct MonthPickerView: View {
    @Binding var selection: MonthSelection

    private var canGoForward: Bool {
        let now = MonthSelection.current()
        return selection.year < now.year || (selection.year == now.year && selection.month < now.month)
    }

    var body: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    selection = selection.previous()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(selection.displayName)
                .font(.headline)
                .contentTransition(.numericText())

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    selection = selection.next()
                }
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .disabled(!canGoForward)
            .opacity(canGoForward ? 1 : 0.3)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.bar)
    }
}
