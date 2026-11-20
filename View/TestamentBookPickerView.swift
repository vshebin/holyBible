//
//  TestamentBookPickerView.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import SwiftUI

struct TestamentBookPickerView: View {
    @ObservedObject var store: BibleStore
    @Binding var activeChapter: BibleChapter?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTestament: Testament = .old

    var booksToShow: [String] {
        selectedTestament == .old
            ? BibleDatabase.shared.oldTestamentBooks
            : BibleDatabase.shared.newTestamentBooks
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Testament", selection: $selectedTestament) {
                    ForEach(Testament.allCases, id: \.self) { testament in
                        Text(testament.rawValue).tag(testament)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List(booksToShow, id: \.self) { bookName in
                    DisclosureGroup(bookName) {
                        let chapters = BibleDatabase.shared.chaptersByBook[bookName] ?? []
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                            ForEach(chapters) { chap in
                                Button {
                                    store.currentChapterID = chap.id
                                    activeChapter = chap
                                    dismiss()
                                } label: {
                                    ZStack(alignment: .topTrailing) {
                                        Text("\(chap.chapter)")
                                            .font(.subheadline.bold())
                                            .frame(width: 44, height: 44)
                                            .background(Color.secondary.opacity(0.15))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))

                                        if KidsIllustrationHelper.storyCaptions[chap.id] != nil {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 9))
                                                .foregroundStyle(.orange)
                                                .padding(3)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Select Book")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
}
