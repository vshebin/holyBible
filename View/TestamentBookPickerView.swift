//
//  TestamentBookPickerView.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import SwiftUI

struct TestamentBookPickerView: View {
    let currentViewingChapter: BibleChapter
    @ObservedObject var store: BibleStore
    @Binding var activeSession: ReadingSession?

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTestament: Testament = .old
    @State private var expandedBooks: Set<String> = []
    @State private var searchText = ""

    var booksToShow: [String] {
        let base = selectedTestament == .old
            ? BibleDatabase.shared.oldTestamentBooks
            : BibleDatabase.shared.newTestamentBooks
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return base
        }
        return base.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Picker("Testament", selection: $selectedTestament) {
                    ForEach(Testament.allCases, id: \.self) { testament in
                        Text(testament.rawValue).tag(testament)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List(booksToShow, id: \.self) { bookName in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedBooks.contains(bookName) || !searchText.isEmpty },
                            set: { isExpanding in
                                if isExpanding {
                                    expandedBooks.insert(bookName)
                                } else {
                                    expandedBooks.remove(bookName)
                                }
                            }
                        )
                    ) {
                        let chapters = BibleDatabase.shared.chaptersByBook[bookName] ?? []
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 48))], spacing: 10) {
                            ForEach(chapters) { chap in
                                let isSelected = chap.id == currentViewingChapter.id
                                Button {
                                    store.currentChapterID = chap.id
                                    activeSession = ReadingSession(chapter: chap, isRandomMode: false)
                                    dismiss()
                                } label: {
                                    ZStack(alignment: .topTrailing) {
                                        Text("\(chap.chapter)")
                                            .font(.subheadline.bold())
                                            .frame(width: 44, height: 44)
                                            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.15))
                                            .foregroundColor(isSelected ? .white : .primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))

                                        if KidsIllustrationHelper.storyCaptions[chap.id] != nil {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 9))
                                                .foregroundColor(.orange)
                                                .padding(3)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                    } label: {
                        HStack {
                            Text(bookName)
                                .font(.headline)
                                .fontWeight(currentViewingChapter.book == bookName ? .bold : .regular)
                            Spacer()
                            let count = BibleDatabase.shared.chaptersByBook[bookName]?.count ?? 0
                            Text("\(count) ch")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search book name...")
            }
            .navigationTitle("Table of Contents")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selectedTestament = currentViewingChapter.testament
                expandedBooks.insert(currentViewingChapter.book)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
