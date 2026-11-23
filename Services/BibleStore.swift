//
//  BibleStore.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import Foundation
import Combine

final class BibleStore: ObservableObject {
    // 1. Main Reading Spot (Strictly for "Continue Reading")
    @Published var currentChapterID: String {
        didSet { UserDefaults.standard.set(currentChapterID, forKey: "currentChapterID") }
    }

    // 2. Separate Random Chapter Spot (Stays the same until finished or refreshed)
    @Published var dailyRandomChapterID: String {
        didSet { UserDefaults.standard.set(dailyRandomChapterID, forKey: "dailyRandomChapterID") }
    }

    @Published var bookmarkedChapters: Set<String> = [] {
        didSet { saveBookmarks() }
    }

    @Published var verseHighlights: [String: HighlightColor] = [:] {
        didSet { saveHighlights() }
    }

    init() {
        self.currentChapterID = UserDefaults.standard.string(forKey: "currentChapterID") ?? "Genesis_1"

        if let savedRandom = UserDefaults.standard.string(forKey: "dailyRandomChapterID") {
            self.dailyRandomChapterID = savedRandom
        } else {
            let initialRandom = BibleDatabase.shared.allChapters.randomElement()?.id ?? "Psalm_23"
            self.dailyRandomChapterID = initialRandom
            UserDefaults.standard.set(initialRandom, forKey: "dailyRandomChapterID")
        }

        loadBookmarks()
        loadHighlights()
    }

    var currentChapter: BibleChapter {
        BibleDatabase.shared.allChapters.first(where: { $0.id == currentChapterID })
        ?? BibleDatabase.shared.allChapters.first!
    }

    var dailyRandomChapter: BibleChapter {
        BibleDatabase.shared.allChapters.first(where: { $0.id == dailyRandomChapterID })
        ?? BibleDatabase.shared.allChapters.first!
    }

    /// Generates a brand-new random chapter (called when user finishes the current random chapter or hits shuffle)
    @discardableResult
    func refreshRandomChapter() -> BibleChapter {
        let candidates = BibleDatabase.shared.allChapters.filter {
            !$0.verses.isEmpty && $0.id != dailyRandomChapterID
        }
        let chosen = candidates.randomElement() ?? BibleDatabase.shared.allChapters.first!
        dailyRandomChapterID = chosen.id
        return chosen
    }

    func toggleBookmark(for chapterID: String) {
        if bookmarkedChapters.contains(chapterID) {
            bookmarkedChapters.remove(chapterID)
        } else {
            bookmarkedChapters.insert(chapterID)
        }
    }

    func setHighlight(_ color: HighlightColor?, for verseID: String) {
        if let color = color {
            verseHighlights[verseID] = color
        } else {
            verseHighlights.removeValue(forKey: verseID)
        }
    }

    private func saveBookmarks() {
        UserDefaults.standard.set(Array(bookmarkedChapters), forKey: "bookmarkedChapters")
    }

    private func loadBookmarks() {
        if let saved = UserDefaults.standard.array(forKey: "bookmarkedChapters") as? [String] {
            bookmarkedChapters = Set(saved)
        }
    }

    private func saveHighlights() {
        if let encoded = try? JSONEncoder().encode(verseHighlights) {
            UserDefaults.standard.set(encoded, forKey: "verseHighlights")
        }
    }

    private func loadHighlights() {
        if let data = UserDefaults.standard.data(forKey: "verseHighlights"),
           let decoded = try? JSONDecoder().decode([String: HighlightColor].self, from: data) {
            verseHighlights = decoded
        }
    }
}
