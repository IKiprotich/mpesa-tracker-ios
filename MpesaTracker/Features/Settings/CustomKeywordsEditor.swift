//
//  CustomKeywordsEditor.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//

import SwiftUI

// MARK: - CategoryKeywordsEditor

struct CategoryKeywordsEditor: View {

    let category: Category
    @Bindable var store: CustomKeywordStore

    @State private var draftKeyword: String = ""
    @FocusState private var inputFocused: Bool

    private var keywords: [String] { store.keywords(for: category) }

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Add a keyword", text: $draftKeyword)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($inputFocused)
                        .onSubmit(addDraft)

                    Button("Add", action: addDraft)
                        .disabled(trimmedDraft.isEmpty)
                }
            } footer: {
                Text("Keywords are matched anywhere inside the transaction details, case-insensitive.")
            }

            Section("Your Keywords") {
                if keywords.isEmpty {
                    Text("No custom keywords yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(keywords, id: \.self) { keyword in
                        Text(keyword)
                    }
                    .onDelete(perform: deleteKeywords)
                }
            }
        }
        .navigationTitle(category.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !keywords.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    // MARK: - Actions

    private var trimmedDraft: String {
        draftKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addDraft() {
        guard !trimmedDraft.isEmpty else { return }
        store.addKeyword(trimmedDraft, to: category)
        draftKeyword = ""
        inputFocused = true
    }

    private func deleteKeywords(at offsets: IndexSet) {
        let toRemove = offsets.map { keywords[$0] }
        for keyword in toRemove {
            store.removeKeyword(keyword, from: category)
        }
    }
}
