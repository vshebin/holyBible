//
//  BibleModels.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import Foundation

struct BibleBookJSON: Codable, Sendable {
    let abbrev: String
    let name: String
    let chapters: [[String]]
}

struct BibleVerse: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: String
    let book: String
    let chapter: Int
    let number: Int
    let text: String
}

struct BibleChapter: Identifiable, Codable, Equatable, Hashable, Sendable {
    nonisolated var id: String { "\(book.replacingOccurrences(of: " ", with: ""))_\(chapter)" }
    let book: String
    let testament: Testament
    let chapter: Int
    let verses: [BibleVerse]
}

enum Testament: String, Codable, CaseIterable, Sendable {
    case old = "Old Testament"
    case new = "New Testament"
}

