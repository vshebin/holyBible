import SwiftUI

struct ContentView: View {
    @StateObject private var store = BibleStore()
    @State private var activeChapter: BibleChapter?

    var body: some View {
        NavigationStack {
            ZStack {
                if KidsIllustrationHelper.imageExists(named: "BibleCover") {
                    Image("BibleCover")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                } else {
                    LinearGradient(
                        colors: [Color(red: 0.18, green: 0.12, blue: 0.08), Color(red: 0.08, green: 0.05, blue: 0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(.yellow.opacity(0.8))
                            Text("HOLY BIBLE")
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .tracking(4)
                                .foregroundStyle(.white)
                            Text("OLD & NEW TESTAMENT")
                                .font(.caption)
                                .tracking(2)
                                .foregroundStyle(.white.opacity(0.75))
                        }
                        .padding(.bottom, 100)
                    )
                }

                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 240)
                }
                .ignoresSafeArea()

                VStack(spacing: 14) {
                    Spacer()

                    Button {
                        activeChapter = store.currentChapter
                    } label: {
                        HStack {
                            Image(systemName: "book.fill")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Continue Reading")
                                    .font(.headline)
                                Text("\(store.currentChapter.book) \(store.currentChapter.chapter) • \(store.currentChapter.testament.rawValue)")
                                    .font(.caption)
                                    .opacity(0.8)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        activeChapter = store.pickRandomChapter()
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Random Chapter for Today")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "shuffle")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .foregroundStyle(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationDestination(item: $activeChapter) { chapter in
                ChapterReaderView(chapter: chapter, store: store, activeChapter: $activeChapter)
            }
        }
    }
}


#Preview {
    ContentView()
}
