import SwiftUI

struct ReadingSession: Identifiable, Hashable {
    let id = UUID()
    let chapter: BibleChapter
    let isRandomMode: Bool
}

struct ContentView: View {
    @StateObject private var store = BibleStore()
    @State private var activeSession: ReadingSession?
    @State private var isReadingActive = false

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                homeContent
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationDestination(isPresented: $isReadingActive) {
                        readerDestination
                    }
            }
        } else {
            NavigationView {
                ZStack {
                    NavigationLink(
                        isActive: $isReadingActive,
                        destination: { readerDestination },
                        label: { EmptyView() }
                    )
                    .hidden()

                    homeContent
                }
                .navigationBarHidden(true)
            }
            .navigationViewStyle(.stack)
        }
    }

    @ViewBuilder
    private var readerDestination: some View {
        if let session = activeSession {
            ChapterReaderView(
                chapter: session.chapter,
                isRandomMode: session.isRandomMode,
                store: store,
                activeSession: $activeSession,
                isReadingActive: $isReadingActive
            )
        }
    }

    private var homeContent: some View {
        ZStack {
            // Home Screen Background Image
            GeometryReader { geo in
                Image("BibleBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            // Bottom Gradient Overlay
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 220)
            }
            .ignoresSafeArea()

            // Two Bottom Action Buttons with OS-Adaptive Liquid Glass
            VStack(spacing: 14) {
                Spacer()
                bottomButtonsStack
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    @ViewBuilder
    private var bottomButtonsStack: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 14) {
                actionButtons
            }
        } else {
            actionButtons
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        // Button 1: Continue Reading (Warm Gold Liquid Glass + Crisp White Text)
        Button {
            activeSession = ReadingSession(chapter: store.currentChapter, isRandomMode: false)
            isReadingActive = true
        } label: {
            HStack {
                Image(systemName: "book.fill")
                VStack(alignment: .leading, spacing: 2) {
                    Text("Continue Reading")
                        .font(.headline)
                    Text("\(store.currentChapter.book) \(store.currentChapter.chapter) • \(store.currentChapter.testament.rawValue)")
                        .font(.caption)
                        .opacity(0.9)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .adaptiveLiquidGlass(
                cornerRadius: 16,
                tint: Color(red: 0.95, green: 0.72, blue: 0.25).opacity(0.45),
                isProminent: true
            )
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)

        // Button 2: Random Chapter for Today (Clear Liquid Glass + Crisp White Text)
        Button {
            activeSession = ReadingSession(chapter: store.dailyRandomChapter, isRandomMode: true)
            isReadingActive = true
        } label: {
            HStack {
                Image(systemName: "sparkles")
                VStack(alignment: .leading, spacing: 2) {
                    Text("Random Chapter for Today")
                        .font(.headline)
                    Text("\(store.dailyRandomChapter.book) \(store.dailyRandomChapter.chapter) • \(store.dailyRandomChapter.testament.rawValue)")
                        .font(.caption)
                        .opacity(0.9)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .adaptiveLiquidGlass(cornerRadius: 16)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
