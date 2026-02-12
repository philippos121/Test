//
//  InferenceService.swift
//  MiniLLM
//
//  Uses llama.cpp bridge for on-device inference
//

import Foundation

actor InferenceService {
    private var modelContext: UnsafeMutableRawPointer?
    private var isLoaded = false
    private var modelPath: String?

    // Configuration
    private let contextSize: Int32 = 2048
    private let threadCount: Int32 = 4

    /// Load a GGUF model from file
    func loadModel(path: String) async throws {
        print("📥 [InferenceService] Loading model from: \(path)")

        // Check if file exists
        guard FileManager.default.fileExists(atPath: path) else {
            print("❌ [InferenceService] Model file not found at path")
            throw ModelError.fileNotFound
        }

        // Get file size for logging
        if let attrs = try? FileManager.default.attributesOfItem(atPath: path),
           let fileSize = attrs[.size] as? UInt64 {
            let sizeMB = Double(fileSize) / 1024.0 / 1024.0
            print("📦 [InferenceService] Model file size: \(String(format: "%.2f", sizeMB)) MB")
        }

        // Unload previous model if loaded
        if isLoaded {
            print("🔄 [InferenceService] Unloading previous model")
            unloadModel()
        }

        // Load model using llama.cpp bridge
        guard let context = LlamaCppBridge.loadModel(
            withPath: path,
            contextSize: contextSize,
            threads: threadCount
        ) else {
            print("❌ [InferenceService] Failed to load model")
            throw ModelError.loadFailed
        }

        self.modelContext = context
        self.modelPath = path
        self.isLoaded = true

        print("✅ [InferenceService] Model loaded successfully")

        // Get and log model info
        let info = LlamaCppBridge.getModelInfo(context)
        print("ℹ️ [InferenceService] Model info: \(info)")
    }

    /// Unload the current model
    func unloadModel() {
        guard isLoaded, let context = modelContext else { return }

        print("🗑️ [InferenceService] Unloading model")

        LlamaCppBridge.freeModel(context)
        modelContext = nil
        isLoaded = false
        modelPath = nil

        print("✅ [InferenceService] Model unloaded")
    }

    /// Generate text completion (non-streaming)
    func generate(
        prompt: String,
        temperature: Double = 0.7,
        maxTokens: Int = 512,
        topP: Double = 0.9
    ) async -> String {
        guard isLoaded, let context = modelContext else {
            return "❌ Error: No model loaded. Please load a model first."
        }

        print("🤖 [InferenceService] Generating response...")
        print("📝 Prompt: \(prompt.prefix(100))\(prompt.count > 100 ? "..." : "")")
        print("⚙️ Parameters: temp=\(temperature), maxTokens=\(maxTokens), topP=\(topP)")

        let startTime = Date()

        // Call llama.cpp bridge for generation
        let response = LlamaCppBridge.generate(
            with: context,
            prompt: prompt,
            maxTokens: Int32(maxTokens),
            temperature: Float(temperature),
            topP: Float(topP)
        )

        let elapsed = Date().timeIntervalSince(startTime)
        print("⏱️ [InferenceService] Generation completed in \(String(format: "%.2f", elapsed))s")

        return response
    }

    /// Generate text with streaming (calls callback for each token)
    func generateStreaming(
        prompt: String,
        temperature: Double = 0.7,
        maxTokens: Int = 512,
        topP: Double = 0.9,
        onToken: @escaping (String) -> Void
    ) async {
        guard isLoaded, let context = modelContext else {
            onToken("❌ Error: No model loaded")
            return
        }

        print("🌊 [InferenceService] Starting streaming generation...")

        // Use llama.cpp bridge streaming
        LlamaCppBridge.generateStream(
            with: context,
            prompt: prompt,
            maxTokens: Int32(maxTokens),
            temperature: Float(temperature),
            topP: Float(topP)
        ) { token in
            // Forward token to caller on main actor
            Task { @MainActor in
                onToken(token)
            }
        }

        print("✅ [InferenceService] Streaming completed")
    }

    /// Check if a model is currently loaded
    func isModelLoaded() -> Bool {
        return isLoaded
    }

    /// Get the path of the currently loaded model
    func getCurrentModelPath() -> String? {
        return modelPath
    }

    /// Get model information
    func getModelInfo() -> [String: Any] {
        guard isLoaded, let context = modelContext else {
            return ["error": "No model loaded"]
        }

        return LlamaCppBridge.getModelInfo(context) as? [String: Any] ?? [:]
    }
}

// MARK: - Error Types

enum ModelError: Error {
    case fileNotFound
    case loadFailed
    case contextCreationFailed
    case generationFailed

    var localizedDescription: String {
        switch self {
        case .fileNotFound:
            return "Model file not found at specified path"
        case .loadFailed:
            return "Failed to load model into memory"
        case .contextCreationFailed:
            return "Failed to create inference context"
        case .generationFailed:
            return "Text generation failed"
        }
    }
}
