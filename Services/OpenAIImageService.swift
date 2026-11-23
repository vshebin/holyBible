//
//  OpenAIImageService.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/19/26.
//

import SwiftUI
import Network

actor OpenAIImageService {
    static let shared = OpenAIImageService()

    // Replace with your OpenAI API key
    private let apiKey = "YOUR_OPENAI_API_KEY"
    private let monitor = NWPathMonitor()
    private var isConnected = true
    private var activeChapterGenerationID: String?

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = (path.status == .satisfied)
            Task {
                await self?.updateNetworkStatus(connected)
            }
        }
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor", qos: .utility))
    }

    private func updateNetworkStatus(_ connected: Bool) {
        self.isConnected = connected
    }

    /// Accepts plain Sendable values so Swift 6 actor isolation is completely satisfied
    func fetchOrGenerateIllustration(
        chapterID: String,
        book: String,
        chapterNumber: Int,
        storyHint: String
    ) async -> UIImage? {
        // 1. Always load permanent local file first (never regenerates once saved)
        if let savedImage = loadFromPermanentStorage(chapterID: chapterID) {
            return savedImage
        }

        // 2. Skip if offline, missing API key, or another chapter is currently generating
        guard isConnected,
              !apiKey.isEmpty,
              apiKey != "YOUR_OPENAI_API_KEY",
              activeChapterGenerationID == nil else {
            return nil
        }

        activeChapterGenerationID = chapterID
        defer { activeChapterGenerationID = nil }

        let prompt = """
        Warm, peaceful, family-friendly storybook illustration depicting the Bible scene from \(book) chapter \(chapterNumber): \(storyHint). Soft painterly lighting, rich colors, suitable for both children and adults, strictly no text, no words, no letters.
        """

        let key = self.apiKey

        let generatedImage: UIImage? = await Task.detached(priority: .utility) { () -> UIImage? in
            guard let url = URL(string: "https://openai.com") else { return nil }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 45
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "model": "gpt-image-1",
                "prompt": prompt,
                "size": "1024x1024",
                "n": 1
            ]

            guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return nil }
            request.httpBody = httpBody

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    return nil
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]],
                   let firstItem = dataArray.first {

                    if let b64 = firstItem["b64_json"] as? String,
                       let imgData = Data(base64Encoded: b64),
                       let image = UIImage(data: imgData) {
                        return image
                    } else if let urlString = firstItem["url"] as? String,
                              let imgURL = URL(string: urlString),
                              let (imgData, _) = try? await URLSession.shared.data(from: imgURL),
                              let image = UIImage(data: imgData) {
                        return image
                    }
                }
            } catch {
                return nil
            }
            return nil
        }.value

        if let image = generatedImage {
            saveToPermanentStorage(image: image, chapterID: chapterID)
        }

        return generatedImage
    }

    // MARK: - Permanent Local Storage (Android-Compatible Lowercase Filenames)
    nonisolated func illustrationsDirectoryURL() -> URL? {
        guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let folderURL = docsURL.appendingPathComponent("BibleIllustrations", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        return folderURL
    }

    private func permanentFileURL(for chapterID: String) -> URL? {
        let androidSafeName = chapterID.lowercased() + ".jpg"
        return illustrationsDirectoryURL()?.appendingPathComponent(androidSafeName)
    }

    private func loadFromPermanentStorage(chapterID: String) -> UIImage? {
        guard let url = permanentFileURL(for: chapterID),
              FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }

    private func saveToPermanentStorage(image: UIImage, chapterID: String) {
        guard let url = permanentFileURL(for: chapterID),
              !FileManager.default.fileExists(atPath: url.path),
              let data = image.jpegData(compressionQuality: 0.85) else {
            return
        }
        try? data.write(to: url, options: .atomic)
    }

    nonisolated func allSavedIllustrationURLs() -> [URL] {
        guard let folderURL = illustrationsDirectoryURL(),
              let files = try? FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: nil
              ) else {
            return []
        }
        return files
            .filter { ["jpg", "jpeg", "png"].contains($0.pathExtension.lowercased()) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
