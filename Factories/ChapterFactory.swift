//
//  ChapterFactory.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import Foundation

// MARK: - Creator Protocol (Factory Method Interface)
protocol ChapterCreator {
    /// Factory Method responsible for creating BibleChapter products
    func createChapters() -> [BibleChapter]
}

// MARK: - Concrete Creator 1: Bundled Full Bible JSON
final class JSONChapterCreator: ChapterCreator {
    private let resourceName: String

    init(resourceName: String = "bible") {
        self.resourceName = resourceName
    }

    func createChapters() -> [BibleChapter] {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decodedBooks = try? JSONDecoder().decode([BibleBookJSON].self, from: data) else {
            return []
        }

        var chapters: [BibleChapter] = []

        for (bookIndex, bookData) in decodedBooks.enumerated() {
            let testament: Testament = bookIndex < 39 ? .old : .new

            for (chapIndex, verseStrings) in bookData.chapters.enumerated() {
                let chapNum = chapIndex + 1
                let verses = verseStrings.enumerated().map { (vIndex, text) in
                    BibleVerse(
                        id: "\(bookData.name)_\(chapNum)_\(vIndex + 1)",
                        book: bookData.name,
                        chapter: chapNum,
                        number: vIndex + 1,
                        text: text
                    )
                }
                let chapter = BibleChapter(
                    book: bookData.name,
                    testament: testament,
                    chapter: chapNum,
                    verses: verses
                )
                chapters.append(chapter)
            }
        }
        return chapters
    }
}

// MARK: - Concrete Creator 2: Fallback Sample Chapters
final class SampleChapterCreator: ChapterCreator {
    func createChapters() -> [BibleChapter] {
        let gen1 = BibleChapter(
            book: "Genesis",
            testament: .old,
            chapter: 1,
            verses: [
                BibleVerse(id: "Genesis_1_1", book: "Genesis", chapter: 1, number: 1, text: "In the beginning God created the heaven and the earth."),
                BibleVerse(id: "Genesis_1_2", book: "Genesis", chapter: 1, number: 2, text: "And the earth was without form, and void; and darkness was upon the face of the deep."),
                BibleVerse(id: "Genesis_1_3", book: "Genesis", chapter: 1, number: 3, text: "And God said, Let there be light: and there was light.")
            ]
        )

        let luke2 = BibleChapter(
            book: "Luke",
            testament: .new,
            chapter: 2,
            verses: [
                BibleVerse(id: "Luke_2_7", book: "Luke", chapter: 2, number: 7, text: "And she brought forth her firstborn son, and wrapped him in swaddling clothes, and laid him in a manger.")
            ]
        )

        return [gen1, luke2]
    }
}

// MARK: - Factory Provider
enum ChapterFactoryProvider {
    static func makeCreator() -> ChapterCreator {
        if Bundle.main.url(forResource: "bible", withExtension: "json") != nil {
            return JSONChapterCreator()
        }
        return SampleChapterCreator()
    }
}
