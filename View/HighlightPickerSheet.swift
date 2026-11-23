//
//  HighlightPickerSheet.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import SwiftUI

struct HighlightPickerSheet: View {
    let verse: BibleVerse
    let currentColor: HighlightColor?
    let onSelectColor: (HighlightColor?) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Highlight \(verse.book) \(verse.chapter):\(verse.number)")
                .font(.headline)
                .padding(.top, 24)

            HStack(spacing: 20) {
                ForEach(HighlightColor.allCases, id: \.self) { color in
                    Button {
                        onSelectColor(color)
                    } label: {
                        Circle()
                            .fill(color.uiColor)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(currentColor == color ? Color.primary : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                    }
                }

                Button {
                    onSelectColor(nil)
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
    }
}
