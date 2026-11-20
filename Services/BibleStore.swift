//
//  BibleStore.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import Foundation
import Combine

final class BibleStore: ObservableObject {
    @Published var currentChapterID: String {
        didSet { UserDefaults.standard.set(currentChapterID, forKey: "currentChapterID") }
    }
    @Published var bookmarkedChapters: Set<String> = [] {
        didSet { saveBookmarks() }
    }
    @Published var verseHighlights: [String: HighlightColor] = [:] {
        didSet { saveHighlights() }
    }

    init() {
        self.currentChapterID = UserDefaults.standard.string(forKey: "currentChapterID") ?? "Genesis_1"
        loadBookmarks()
        loadHighlights()
    }

    var currentChapter: BibleChapter {
        BibleDatabase.shared.allChapters.first(where: { $0.id == currentChapterID })
        ?? BibleDatabase.shared.allChapters.first!
    }

    func pickRandomChapter() -> BibleChapter {
        let otherChapters = BibleDatabase.shared.allChapters.filter { $0.id != currentChapterID }
        let chosen = otherChapters.randomElement() ?? BibleDatabase.shared.allChapters.first!
        currentChapterID = chosen.id
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
