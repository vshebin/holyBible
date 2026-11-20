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

enum KidsIllustrationHelper {
    static let storyCaptions: [String: String] = [
        "Genesis_1": "God Creates the World & Light",
        "Genesis_6": "Noah Builds the Big Ark",
        "Genesis_7": "Two by Two Into the Ark",
        "Exodus_14": "Moses Parts the Red Sea",
        "1Samuel_17": "David & Goliath",
        "Daniel_6": "Daniel in the Lions' Den",
        "Jonah_1": "Jonah and the Big Fish",
        "Matthew_2": "The Wise Men Follow the Star",
        "Luke_2": "Baby Jesus is Born in Bethlehem",
        "John_6": "Jesus Feeds 5,000 People"
    ]

    static func imageExists(named name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: name) != nil
        #elseif canImport(AppKit)
        return NSImage(named: name) != nil
        #else
        return false
        #endif
    }

    static func imageName(for chapter: BibleChapter) -> String? {
        if imageExists(named: chapter.id) {
            return chapter.id
        }
        let fallback = chapter.testament == .old ? "OldTestament_Default" : "NewTestament_Default"
        if imageExists(named: fallback) {
            return fallback
        }
        return nil
    }
}

