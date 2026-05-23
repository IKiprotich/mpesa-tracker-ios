//
//  CustomKeywordStore.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 23/05/2026.
//


import Foundation
import Combine

// MARK: - CustomKeywordStore

@Observable
final class CustomKeywordStore {

    // MARK: - Singleton

    static let shared = CustomKeywordStore()

    // MARK: - Storage

    private let defaults: UserDefaults
    private let storageKey = "com.ian.MpesaTracker.customKeywords"

    private(set) var keywordsByCategory: [Category: [String]] = [:]

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.keywordsByCategory = Self.load(from: defaults, key: storageKey)
    }

    // MARK: - Public API

    func keywords(for category: Category) -> [String] {
        keywordsByCategory[category] ?? []
    }

    func addKeyword(_ raw: String, to category: Category) {
        let cleaned = normalise(raw)
        guard !cleaned.isEmpty else { return }

        var current = keywordsByCategory[category] ?? []
        guard !current.contains(cleaned) else { return }

        current.append(cleaned)
        keywordsByCategory[category] = current
        persist()
    }

    func removeKeyword(_ keyword: String, from category: Category) {
        guard var current = keywordsByCategory[category] else { return }
        current.removeAll { $0 == keyword }

        if current.isEmpty {
            keywordsByCategory.removeValue(forKey: category)
        } else {
            keywordsByCategory[category] = current
        }
        persist()
    }

    func totalKeywordCount() -> Int {
        keywordsByCategory.values.reduce(0) { $0 + $1.count }
    }

    // Flat list of all custom rules in a stable order — used by Categoriser.
    func allRules() -> [(category: Category, keywords: [String])] {
        Category.allCases.compactMap { category in
            guard let keywords = keywordsByCategory[category], !keywords.isEmpty else { return nil }
            return (category, keywords)
        }
    }

    // MARK: - Private

    private func normalise(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func persist() {
        let payload = keywordsByCategory.reduce(into: [String: [String]]()) { result, pair in
            result[pair.key.rawValue] = pair.value
        }
        defaults.set(payload, forKey: storageKey)
    }

    private static func load(from defaults: UserDefaults, key: String) -> [Category: [String]] {
        guard let raw = defaults.dictionary(forKey: key) as? [String: [String]] else {
            return [:]
        }
        return raw.reduce(into: [Category: [String]]()) { result, pair in
            if let category = Category(rawValue: pair.key) {
                result[category] = pair.value
            }
        }
    }
}
