//
//  BookmarksListView.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import SwiftUI

struct BookmarksListView: View {
    @ObservedObject var store: BibleStore
    @Binding var activeChapter: BibleChapter?
    @Environment(\.dismiss) private var dismiss

    var bookmarkedList: [BibleChapter] {
        BibleDatabase.shared.allChapters.filter { store.bookmarkedChapters.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            List {
                if bookmarkedList.isEmpty {
                    Text("No bookmarked chapters yet. Tap the bookmark icon while reading to save a chapter.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(bookmarkedList) { chapter in
                        Button {
                            store.currentChapterID = chapter.id
                            activeChapter = chapter
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "bookmark.fill")
                                    .foregroundStyle(.orange)
                                VStack(alignment: .leading) {
                                    Text("\(chapter.book) \(chapter.chapter)")
                                        .foregroundStyle(.primary)
                                    Text(chapter.testament.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bookmarked Chapters")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
}
