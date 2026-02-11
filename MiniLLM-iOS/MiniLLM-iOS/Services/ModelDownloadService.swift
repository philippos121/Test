//
//  ModelDownloadService.swift
//  MiniLLM
//

import Foundation

class ModelDownloadService {
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    func downloadModel(_ model: LLMModel, progressHandler: @escaping (Double) -> Void) async throws -> String {
        let modelDirectory = documentsPath.appendingPathComponent("models")
        try? FileManager.default.createDirectory(at: modelDirectory, withIntermediateDirectories: true)

        let fileName = "\(model.name).gguf"
        let localURL = modelDirectory.appendingPathComponent(fileName)

        // Check if already exists
        if FileManager.default.fileExists(atPath: localURL.path) {
            return localURL.path
        }

        guard let downloadURL = URL(string: model.downloadURL) else {
            throw ModelError.invalidURL
        }

        // Download with progress tracking
        let (tempURL, response) = try await URLSession.shared.download(from: downloadURL) { progress in
            let fractionCompleted = progress.fractionCompleted
            progressHandler(fractionCompleted)
        }

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ModelError.downloadFailed
        }

        try FileManager.default.moveItem(at: tempURL, to: localURL)

        return localURL.path
    }
}

extension URLSession {
    func download(from url: URL, progressHandler: @escaping (Progress) -> Void) async throws -> (URL, URLResponse) {
        let progress = Progress(totalUnitCount: 100)

        return try await withCheckedThrowingContinuation { continuation in
            let task = self.downloadTask(with: url) { url, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let url = url, let response = response else {
                    continuation.resume(throwing: ModelError.downloadFailed)
                    return
                }

                continuation.resume(returning: (url, response))
            }

            // Track progress
            let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                progressHandler(progress)
            }

            task.resume()
        }
    }
}

enum ModelError: Error {
    case invalidURL
    case downloadFailed
    case loadFailed
    case inferenceFailed
}
