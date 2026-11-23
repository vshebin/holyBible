//
//  BookmarksListView.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import SwiftUI

struct BookmarksListView: View {
    @ObservedObject var store: BibleStore
    @Binding var activeSession: ReadingSession?
    @Environment(\.dismiss) private var dismiss

    var bookmarkedList: [BibleChapter] {
        BibleDatabase.shared.allChapters.filter { store.bookmarkedChapters.contains($0.id) }
    }

    var body: some View {
        NavigationView {
            List {
                if bookmarkedList.isEmpty {
                    Text("No bookmarked chapters yet. Tap the bookmark icon while reading to save a chapter.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(bookmarkedList) { chapter in
                        Button {
                            store.currentChapterID = chapter.id
                            activeSession = ReadingSession(chapter: chapter, isRandomMode: false)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "bookmark.fill")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading) {
                                    Text("\(chapter.book) \(chapter.chapter)")
                                        .foregroundColor(.primary)
                                    Text(chapter.testament.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bookmarked Chapters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

