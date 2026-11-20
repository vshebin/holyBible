//
//  ChapterReaderView.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import SwiftUI

struct ChapterReaderView: View {
    let chapter: BibleChapter
    @ObservedObject var store: BibleStore
    @Binding var activeChapter: BibleChapter?
    @State private var selectedVerseForHighlight: BibleVerse?
    @State private var showBookmarksList = false
    @State private var showBookPicker = false

    var isBookmarked: Bool {
        store.bookmarkedChapters.contains(chapter.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text(chapter.testament.rawValue.uppercased())
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Tap any verse to highlight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let imageName = KidsIllustrationHelper.imageName(for: chapter) {
                    VStack(alignment: .leading, spacing: 0) {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 210)
                            .clipped()

                        if let caption = KidsIllustrationHelper.storyCaptions[chapter.id] {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(.orange)
                                Text(caption)
                                    .font(.subheadline.bold())
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.12))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                } else if let caption = KidsIllustrationHelper.storyCaptions[chapter.id] {
                    HStack(spacing: 12) {
                        Image(systemName: "photo.artframe")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(caption)
                                .font(.subheadline.bold())
                            Text("Add image \"\(chapter.id)\" in Assets to show picture")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                ForEach(chapter.verses) { verse in
                    let highlight = store.verseHighlights[verse.id]

                    HStack(alignment: .top, spacing: 8) {
                        Text("\(verse.number)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .padding(.top, 3)

                        Text(verse.text)
                            .font(.system(.body, design: .serif))
                            .lineSpacing(6)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(highlight?.uiColor ?? Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        selectedVerseForHighlight = verse
                    }
                }
            }
            .padding()
        }
        .navigationTitle("\(chapter.book) \(chapter.chapter)")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            store.currentChapterID = chapter.id
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showBookPicker = true
                } label: {
                    Image(systemName: "books.vertical")
                }

                Button {
                    store.toggleBookmark(for: chapter.id)
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(isBookmarked ? .orange : .primary)
                }

                Button {
                    showBookmarksList = true
                } label: {
                    Image(systemName: "list.bullet")
                }
            }
        }
        .sheet(item: $selectedVerseForHighlight) { verse in
            HighlightPickerSheet(
                verse: verse,
                currentColor: store.verseHighlights[verse.id],
                onSelectColor: { color in
                    store.setHighlight(color, for: verse.id)
                    selectedVerseForHighlight = nil
                }
            )
            .presentationDetents([.height(220)])
        }
        .sheet(isPresented: $showBookmarksList) {
            BookmarksListView(store: store, activeChapter: $activeChapter)
        }
        .sheet(isPresented: $showBookPicker) {
            TestamentBookPickerView(store: store, activeChapter: $activeChapter)
        }
    }
}
