//
//  LLMModel.swift
//  MiniLLM
//

import Foundation

struct LLMModel: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let displayName: String
    let description: String
    let size: String // e.g., "1.5 GB"
    let parameters: String // e.g., "3B", "7B"
    let downloadURL: String
    let quantization: String // e.g., "Q4_K_M", "Q5_K_S"
    let contextLength: Int
    var isDownloaded: Bool
    var localPath: String?
    var downloadProgress: Double?

    // Popular mini models optimized for mobile
    static let availableModels: [LLMModel] = [
        LLMModel(
            id: UUID(),
            name: "phi-2",
            displayName: "Phi-2 (Microsoft)",
            description: "2.7B parameter model, excellent reasoning",
            size: "1.6 GB",
            parameters: "2.7B",
            downloadURL: "https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf",
            quantization: "Q4_K_M",
            contextLength: 2048,
            isDownloaded: false
        ),
        LLMModel(
            id: UUID(),
            name: "tinyllama",
            displayName: "TinyLlama 1.1B",
            description: "Ultra-lightweight Llama model",
            size: "637 MB",
            parameters: "1.1B",
            downloadURL: "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf",
            quantization: "Q4_K_M",
            contextLength: 2048,
            isDownloaded: false
        ),
        LLMModel(
            id: UUID(),
            name: "gemma-2b",
            displayName: "Gemma 2B (Google)",
            description: "Google's efficient 2B model",
            size: "1.4 GB",
            parameters: "2B",
            downloadURL: "https://huggingface.co/lmstudio-ai/gemma-2b-it-GGUF/resolve/main/gemma-2b-it-q4_k_m.gguf",
            quantization: "Q4_K_M",
            contextLength: 8192,
            isDownloaded: false
        ),
        LLMModel(
            id: UUID(),
            name: "llama-3.2-1b",
            displayName: "Llama 3.2 1B (Meta)",
            description: "Latest Llama model, optimized for mobile",
            size: "800 MB",
            parameters: "1B",
            downloadURL: "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf",
            quantization: "Q4_K_M",
            contextLength: 131072,
            isDownloaded: false
        ),
        LLMModel(
            id: UUID(),
            name: "qwen-1.8b",
            displayName: "Qwen 1.8B (Alibaba)",
            description: "Multilingual, fast inference",
            size: "1.1 GB",
            parameters: "1.8B",
            downloadURL: "https://huggingface.co/Qwen/Qwen2-1.5B-Instruct-GGUF/resolve/main/qwen2-1_5b-instruct-q4_k_m.gguf",
            quantization: "Q4_K_M",
            contextLength: 32768,
            isDownloaded: false
        )
    ]
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: String // "user" or "assistant"
    let content: String
    let timestamp: Date

    init(id: UUID = UUID(), role: String, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

struct TrainingDataset: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    var examples: [TrainingExample]
    let createdAt: Date
}

struct TrainingExample: Identifiable, Codable {
    let id: UUID
    let input: String
    let output: String
}
