//
//  BibleDatabase.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import Foundation

final class BibleDatabase {
    static let shared = BibleDatabase()

    let allChapters: [BibleChapter]
    let oldTestamentBooks: [String]
    let newTestamentBooks: [String]
    let chaptersByBook: [String: [BibleChapter]]

    init(creator: ChapterCreator = ChapterFactoryProvider.makeCreator()) {
        let createdChapters = creator.createChapters()
        let chapters = createdChapters.isEmpty ? SampleChapterCreator().createChapters() : createdChapters

        var otBooks: [String] = []
        var ntBooks: [String] = []
        var grouped: [String: [BibleChapter]] = [:]

        for chapter in chapters {
            if chapter.testament == .old {
                if !otBooks.contains(chapter.book) { otBooks.append(chapter.book) }
            } else {
                if !ntBooks.contains(chapter.book) { ntBooks.append(chapter.book) }
            }
            grouped[chapter.book, default: []].append(chapter)
        }

        self.allChapters = chapters
        self.oldTestamentBooks = otBooks
        self.newTestamentBooks = ntBooks
        self.chaptersByBook = grouped
    }
}
