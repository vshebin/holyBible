//
//  ChapterReaderView.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import SwiftUI

struct ChapterReaderView: View {
    let chapter: BibleChapter
    let isRandomMode: Bool
    @ObservedObject var store: BibleStore
    @Binding var activeSession: ReadingSession?
    @Binding var isReadingActive: Bool
    
    @State private var selectedVerseForHighlight: BibleVerse?
    @State private var showBookmarksList = false
    @State private var showTableOfContents = false
    @State private var showArtwork = true
    @State private var generatedArtwork: UIImage?
    @State private var currentSlideIndex = 0
    
    var isBookmarked: Bool {
        store.bookmarkedChapters.contains(chapter.id)
    }
    
    var prevChapter: BibleChapter? {
        BibleDatabase.shared.previousChapter(before: chapter)
    }
    
    var nextChapter: BibleChapter? {
        BibleDatabase.shared.nextChapter(after: chapter)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Color.clear
                        .frame(height: 1)
                        .id("TOP_OF_CHAPTER")
                    
                    headerSection
                    artworkSection
                    versesSection
                    
                    Divider()
                        .padding(.top, 12)
                    
                    bottomNavigationSection(proxy: proxy)
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !isRandomMode {
                store.currentChapterID = chapter.id
            }
        }
        .task(id: chapter.id) {
            await loadChapterIllustration()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                toolbarButtons
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
        }
        .sheet(isPresented: $showBookmarksList) {
            BookmarksListView(store: store, activeSession: $activeSession)
        }
        .sheet(isPresented: $showTableOfContents) {
            TestamentBookPickerView(
                currentViewingChapter: chapter,
                store: store,
                activeSession: $activeSession
            )
        }
    }
    
    // MARK: - Subview 1: Chapter Heading + Quick Top Previous Button
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Quick 1-tap recovery button if the user accidentally tapped "Next Chapter"
            if !isRandomMode, let prev = prevChapter {
                Button {
                    store.currentChapterID = prev.id
                    activeSession = ReadingSession(chapter: prev, isRandomMode: false)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.caption.bold())
                        Text("Previous: " + prev.book + " " + String(prev.chapter))
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.12))
                    .foregroundColor(.primary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            HStack {
                Text(isRandomMode ? "DAILY RANDOM • " + chapter.testament.rawValue.uppercased() : chapter.testament.rawValue.uppercased())
                    .font(.caption.bold())
                    .foregroundColor(isRandomMode ? .orange : .secondary)
                Spacer()
                Text("Tap any verse to highlight")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(chapter.book + " " + String(chapter.chapter))
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(.primary)
        }
        .padding(.bottom, 4)
    }
    
    // MARK: - Subview 2: Storybook Carousel (Folder) or Single Illustration
    @ViewBuilder
    private var artworkSection: some View {
        let storySlides = KidsIllustrationHelper.storySequenceImages(for: chapter)
        
        if showArtwork && !storySlides.isEmpty {
            let theme = KidsIllustrationHelper.bannerTheme(for: chapter)
            
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    TabView(selection: $currentSlideIndex) {
                        ForEach(0..<storySlides.count, id: \.self) { index in
                            Image(uiImage: storySlides[index])
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                                .background(Color.black.opacity(0.04))
                                .tag(index)
                        }
                    }
                    .frame(height: 240)
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    
                    Text("\(currentSlideIndex + 1) / \(storySlides.count)")
                        .font(.caption2.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(10)
                }
                
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.orange)
                    Text(theme.title)
                        .font(.subheadline.bold())
                    Spacer()
                    Text("Swipe pictures →")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.10))
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        } else if showArtwork, let uiImage = generatedArtwork ?? KidsIllustrationHelper.localUIImage(for: chapter) {
            let theme = KidsIllustrationHelper.bannerTheme(for: chapter)
            
            VStack(alignment: .leading, spacing: 0) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.orange)
                    Text(theme.title)
                        .font(.subheadline.bold())
                    Spacer()
                    Text(theme.subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.10))
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Subview 3: Verses List
    @ViewBuilder
    private var versesSection: some View {
        ForEach(chapter.verses) { verse in
            let highlight = store.verseHighlights[verse.id]
            
            HStack(alignment: .top, spacing: 8) {
                Text("\(verse.number)")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
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
    
    // MARK: - Subview 4: Bottom Navigation Controls
    @ViewBuilder
    private func bottomNavigationSection(proxy: ScrollViewProxy) -> some View {
        if isRandomMode {
            VStack(spacing: 12) {
                Button {
                    let nextRandom = store.refreshRandomChapter()
                    activeSession = ReadingSession(chapter: nextRandom, isRandomMode: true)
                    withAnimation { proxy.scrollTo("TOP_OF_CHAPTER", anchor: .top) }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Finished Reading • Load Next Random Chapter")
                            .font(.subheadline.bold())
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    store.refreshRandomChapter()
                    isReadingActive = false
                    activeSession = nil
                } label: {
                    Text("Finished & Return Home")
                        .font(.subheadline.bold())
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.secondary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 24)
        } else {
            HStack(spacing: 12) {
                if let prev = prevChapter {
                    Button {
                        store.currentChapterID = prev.id
                        activeSession = ReadingSession(chapter: prev, isRandomMode: false)
                        withAnimation { proxy.scrollTo("TOP_OF_CHAPTER", anchor: .top) }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            VStack(alignment: .leading) {
                                Text("Previous")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(prev.book + " " + String(prev.chapter))
                                    .font(.subheadline.bold())
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.secondary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }

                if let next = nextChapter {
                    Button {
                        store.currentChapterID = next.id
                        activeSession = ReadingSession(chapter: next, isRandomMode: false)
                        withAnimation { proxy.scrollTo("TOP_OF_CHAPTER", anchor: .top) }
                    } label: {
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Next Chapter")
                                    .font(.caption2)
                                    .opacity(0.85)
                                Text(next.book + " " + String(next.chapter))
                                    .font(.subheadline.bold())
                                    .lineLimit(1)
                            }
                            Image(systemName: "chevron.right")
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Subview 5: Toolbar Buttons
    @ViewBuilder
    private var toolbarButtons: some View {
        Button {
            withAnimation { showArtwork.toggle() }
        } label: {
            Image(systemName: showArtwork ? "photo.fill" : "photo")
        }
        Button {
            showTableOfContents = true
        } label: {
            Image(systemName: "list.bullet.indent")
        }
        Button {
            store.toggleBookmark(for: chapter.id)
        } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .foregroundColor(isBookmarked ? .orange : .primary)
        }
        Button {
            showBookmarksList = true
        } label: {
            Image(systemName: "bookmark.circle")
        }
    }
    
    // MARK: - Background Illustration Loader
    private func loadChapterIllustration() async {
        generatedArtwork = nil
        currentSlideIndex = 0
        if KidsIllustrationHelper.storySequenceImages(for: chapter).isEmpty,
           KidsIllustrationHelper.localUIImage(for: chapter) == nil {
            let firstTwoVerses: [BibleVerse] = Array(chapter.verses.prefix(2))
            let fallbackHint: String = firstTwoVerses.map { verse in verse.text }.joined(separator: " ")
            let hint: String = KidsIllustrationHelper.storyCaptions[chapter.id] ?? fallbackHint
            let fetched = await OpenAIImageService.shared.fetchOrGenerateIllustration(
                chapterID: chapter.id,
                book: chapter.book,
                chapterNumber: chapter.chapter,
                storyHint: hint
            )
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.3)) {
                generatedArtwork = fetched
            }
        }
    }
}
