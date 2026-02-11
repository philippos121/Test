//
//  ModelManager.swift
//  MiniLLM
//

import Foundation
import Combine

@MainActor
class ModelManager: ObservableObject {
    @Published var availableModels: [LLMModel] = LLMModel.availableModels
    @Published var downloadingModels: Set<UUID> = []
    @Published var currentModel: LLMModel?
    @Published var isModelLoaded = false

    private let downloadService = ModelDownloadService()
    private let inferenceService = InferenceService()

    init() {
        loadDownloadedModels()
    }

    func downloadModel(_ model: LLMModel) async {
        guard !downloadingModels.contains(model.id) else { return }

        downloadingModels.insert(model.id)

        do {
            let localPath = try await downloadService.downloadModel(model) { progress in
                Task { @MainActor in
                    if let index = self.availableModels.firstIndex(where: { $0.id == model.id }) {
                        self.availableModels[index].downloadProgress = progress
                    }
                }
            }

            if let index = availableModels.firstIndex(where: { $0.id == model.id }) {
                availableModels[index].isDownloaded = true
                availableModels[index].localPath = localPath
                availableModels[index].downloadProgress = nil
            }

            downloadingModels.remove(model.id)
            saveModelState()
        } catch {
            print("Download failed: \(error)")
            downloadingModels.remove(model.id)
            if let index = availableModels.firstIndex(where: { $0.id == model.id }) {
                availableModels[index].downloadProgress = nil
            }
        }
    }

    func deleteModel(_ model: LLMModel) {
        guard let localPath = model.localPath else { return }

        try? FileManager.default.removeItem(atPath: localPath)

        if let index = availableModels.firstIndex(where: { $0.id == model.id }) {
            availableModels[index].isDownloaded = false
            availableModels[index].localPath = nil
        }

        if currentModel?.id == model.id {
            unloadModel()
        }

        saveModelState()
    }

    func loadModel(_ model: LLMModel) async {
        guard model.isDownloaded, let localPath = model.localPath else { return }

        do {
            try await inferenceService.loadModel(path: localPath)
            currentModel = model
            isModelLoaded = true
        } catch {
            print("Failed to load model: \(error)")
            isModelLoaded = false
        }
    }

    func unloadModel() {
        inferenceService.unloadModel()
        currentModel = nil
        isModelLoaded = false
    }

    func generate(prompt: String, temperature: Double = 0.7, maxTokens: Int = 512) async -> String {
        guard isModelLoaded else { return "No model loaded" }
        return await inferenceService.generate(prompt: prompt, temperature: temperature, maxTokens: maxTokens)
    }

    private func loadDownloadedModels() {
        // Load persisted model state
        if let data = UserDefaults.standard.data(forKey: "downloadedModels"),
           let decoded = try? JSONDecoder().decode([LLMModel].self, from: data) {
            // Merge with available models
            for downloadedModel in decoded where downloadedModel.isDownloaded {
                if let index = availableModels.firstIndex(where: { $0.name == downloadedModel.name }) {
                    availableModels[index].isDownloaded = downloadedModel.isDownloaded
                    availableModels[index].localPath = downloadedModel.localPath
                }
            }
        }
    }

    private func saveModelState() {
        if let encoded = try? JSONEncoder().encode(availableModels) {
            UserDefaults.standard.set(encoded, forKey: "downloadedModels")
        }
    }
}
