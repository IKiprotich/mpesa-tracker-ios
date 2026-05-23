//
//  CustomKeyWordsView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//

import SwiftUI

// MARK: - CustomKeywordsView

struct CustomKeywordsView: View {

    @State private var store = CustomKeywordStore.shared

    var body: some View {
        List {
            Section {
                Text("Add words that should automatically map to a category. Your rules take priority over the built-in ones.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0))
            }

            Section("Categories") {
                ForEach(Category.allCases) { category in
                    NavigationLink {
                        CategoryKeywordsEditor(category: category, store: store)
                    } label: {
                        CategoryKeywordRow(
                            category: category,
                            count: store.keywords(for: category).count
                        )
                    }
                }
            }
        }
        .navigationTitle("Custom Keywords")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - CategoryKeywordRow

private struct CategoryKeywordRow: View {
    let category: Category
    let count: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.callout)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(category.color, in: RoundedRectangle(cornerRadius: 6))

            Text(category.displayName)
                .font(.body)

            Spacer()

            Text(count == 0 ? "None" : "\(count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }
}
