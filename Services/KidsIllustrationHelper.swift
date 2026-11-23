//
//  KidsIllustrationHelper.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct ChapterBannerTheme {
    let title: String
    let subtitle: String
    let iconName: String
    let gradientColors: [Color]
}

enum KidsIllustrationHelper {
    static let storyCaptions: [String: String] = [
        "Genesis_1": "The Creation of the World",
        "Genesis_2": "The Garden of Eden",
        "Genesis_6": "Noah Builds the Big Ark",
        "Genesis_7": "Two by Two Into the Ark",
        "Genesis_9": "God's Rainbow Promise",
        "Exodus_3": "Moses & the Burning Bush",
        "Exodus_14": "Moses Parts the Red Sea",
        "1Samuel_17": "David & Goliath",
        "Psalm_23": "The Lord Is My Shepherd",
        "Daniel_6": "Daniel in the Lions' Den",
        "Jonah_1": "Jonah & the Big Fish",
        "Matthew_2": "The Wise Men Follow the Star",
        "Matthew_5": "The Sermon on the Mount",
        "Luke_2": "Baby Jesus is Born in Bethlehem",
        "Luke_15": "The Parable of the Lost Sheep",
        "John_6": "Jesus Feeds 5,000 People",
        "Revelation_21": "A New Heaven and a New Earth"
    ]

    /// Returns an empty array so single-chapter images use the clean single-image card
    static func storySequenceImages(for chapter: BibleChapter) -> [UIImage] {
        return []
    }

    /// Checks if a single image exists in Assets.xcassets
    static func imageExists(named name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: name) != nil
        #elseif canImport(AppKit)
        return NSImage(named: name) != nil
        #else
        return false
        #endif
    }

    /// Automatically matches "Genesis_Chapter_1", "Genesis/Genesis_Chapter_1", etc. in Assets.xcassets
    static func localUIImage(for chapter: BibleChapter) -> UIImage? {
        let cleanBook = chapter.book.replacingOccurrences(of: " ", with: "")
        
        // 1. Check exact pattern: "Genesis_Chapter_1" or namespaced "Genesis/Genesis_Chapter_1"
        let chapterAssetName = "\(cleanBook)_Chapter_\(chapter.chapter)"
        let namespacedAssetName = "\(cleanBook)/\(chapterAssetName)"
        
        if let exactChapterImage = UIImage(named: chapterAssetName) ?? UIImage(named: namespacedAssetName) {
            return exactChapterImage
        }

        // 2. Fallback to "Genesis_1" if named without "_Chapter_"
        if let shortNameImage = UIImage(named: chapter.id) {
            return shortNameImage
        }

        // 3. Optional Testament default fallback if added later
        let fallback = chapter.testament == .old ? "OldTestament_Default" : "NewTestament_Default"
        return UIImage(named: fallback)
    }

    static func bannerTheme(for chapter: BibleChapter) -> ChapterBannerTheme {
        let caption = storyCaptions[chapter.id] ?? "\(chapter.book) • Chapter \(chapter.chapter)"

        if chapter.testament == .old {
            return ChapterBannerTheme(
                title: caption,
                subtitle: chapter.testament.rawValue,
                iconName: "sun.max.fill",
                gradientColors: [
                    Color(red: 0.16, green: 0.55, blue: 0.85),
                    Color(red: 0.22, green: 0.75, blue: 0.55)
                ]
            )
        } else {
            return ChapterBannerTheme(
                title: caption,
                subtitle: chapter.testament.rawValue,
                iconName: "sparkles",
                gradientColors: [
                    Color(red: 0.92, green: 0.58, blue: 0.14),
                    Color(red: 0.85, green: 0.32, blue: 0.35)
                ]
            )
        }
    }
}

