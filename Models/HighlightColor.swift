//
//  HighlightColor.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import SwiftUI

enum HighlightColor: String, CaseIterable, Codable {
    case yellow, green, blue, pink

    var uiColor: Color {
        switch self {
        case .yellow: return Color.yellow.opacity(0.45)
        case .green:  return Color.green.opacity(0.4)
        case .blue:   return Color.blue.opacity(0.35)
        case .pink:   return Color.pink.opacity(0.4)
        }
    }
}
