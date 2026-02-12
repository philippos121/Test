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
    let size: String
    let parameters: String
    let downloadURL: String
    let quantization: String
    let contextLength: Int
    let category: ModelCategory
    var isDownloaded: Bool
    var localPath: String?
    var downloadProgress: Double?

    enum ModelCategory: String, Codable, CaseIterable {
        case tiny = "Tiny"       // < 500M params
        case small = "Small"     // 500M - 1.5B
        case medium = "Medium"   // 1.5B - 3B
    }

    static let availableModels: [LLMModel] = [
        // --- Tiny models (ideal for quick responses / low memory) ---
        LLMModel(
            id: UUID(),
            name: "smollm-360m",
            displayName: "SmolLM 360M",
            description: "Ultra-tiny, very fast. Good for basic tasks.",
            size: "387 MB",
            parameters: "360M",
            downloadURL: "https://huggingface.co/mlx-community/SmolLM-360M-Instruct-GGUF/resolve/main/smollm-360m-instruct-add-basics-q8_0.gguf",
            quantization: "Q8_0",
            contextLength: 2048,
            category: .tiny,
            isDownloaded: false
        ),
        LLMModel(
            id: UUID(),
            name: "qwen2-0.5b",
            displayName: "Qwen2 0.5B (Alibaba)",
            description: "Tiny but capable instruction-following model.",
            size: "400 MB",
            parameters: "0.5B",
            downloadURL: "https://huggingface.co/Qwen/Qwen2-0.5B-Instruct-GGUF/resolve/main/qwen2-0_5b-instruct-q4_k_m.gguf",
            quantization: "Q4_K_M",
            contextLength: 32768,
            category: .tiny,
            isDownloaded: false
        ),

        // --- Small models (good balance) ---
        LLMModel(
            id: UUID(),
            name: "tinyllama",
            displayName: "TinyLlama 1.1B",
            description: "Ultra-lightweight Llama variant, fast inference.",
            size: "637 MB",
            parameters: "1.1B",
            downloadURL: "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf",
            quantization: "Q4_K_M",
            contextLength: 2048,
            category: .small,
            isDownloaded: false
        ),
        LLMModel(
            id: UUID(),
            name: "llama-3.2-1b",
            displayName: "Llama 3.2 1B (Meta)",
            description: "Meta's latest small model. Strong instruction following.",
            size: "800 MB",
            parameters: "1B",
            downloadURL: "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf",
            quantization: "Q4_K_M",
            contextLength: 131072,
            category: .small,
            isDownloaded: false
        ),
        LLMModel(
            id: UUID(),
            name: "qwen2-1.5b",
            displayName: "Qwen2 1.5B (Alibaba)",
            description: "Multilingual with strong reasoning. Recommended.",
            size: "986 MB",
            parameters: "1.5B",
            downloadURL: "https://huggingface.co/Qwen/Qwen2-1.5B-Instruct-GGUF/resolve/main/qwen2-1_5b-instruct-q4_k_m.gguf",
            quantization: "Q4_K_M",
            contextLength: 32768,
            category: .small,
            isDownloaded: false
        ),

        // --- Medium models (best quality, more memory) ---
        LLMModel(
            id: UUID(),
            name: "gemma-2b",
            displayName: "Gemma 2B (Google)",
            description: "Google's compact model with solid instruction following.",
            size: "1.4 GB",
            parameters: "2B",
            downloadURL: "https://huggingface.co/lmstudio-ai/gemma-2b-it-GGUF/resolve/main/gemma-2b-it-Q4_K_M.gguf",
            quantization: "Q4_K_M",
            contextLength: 8192,
            category: .medium,
            isDownloaded: false
        ),
        LLMModel(
            id: UUID(),
            name: "phi-2",
            displayName: "Phi-2 (Microsoft)",
            description: "2.7B parameters, excellent reasoning ability.",
            size: "1.6 GB",
            parameters: "2.7B",
            downloadURL: "https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf",
            quantization: "Q4_K_M",
            contextLength: 2048,
            category: .medium,
            isDownloaded: false
        ),
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
