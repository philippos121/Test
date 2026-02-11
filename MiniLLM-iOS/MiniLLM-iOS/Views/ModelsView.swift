//
//  ModelsView.swift
//  MiniLLM
//

import SwiftUI

struct ModelsView: View {
    @EnvironmentObject var modelManager: ModelManager

    var body: some View {
        NavigationView {
            List {
                Section {
                    if let currentModel = modelManager.currentModel {
                        CurrentModelCard(model: currentModel)
                    } else {
                        Text("No model loaded")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                } header: {
                    Text("Current Model")
                }

                Section {
                    ForEach(modelManager.availableModels) { model in
                        ModelRow(model: model)
                    }
                } header: {
                    Text("Available Models")
                } footer: {
                    Text("Models are quantized for efficient on-device inference")
                        .font(.caption)
                }
            }
            .navigationTitle("Models")
            .refreshable {
                // Refresh model list
            }
        }
    }
}

struct ModelRow: View {
    @EnvironmentObject var modelManager: ModelManager
    let model: LLMModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.displayName)
                        .font(.headline)

                    Text(model.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if model.isDownloaded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if let progress = model.downloadProgress {
                    ProgressView(value: progress)
                        .frame(width: 40)
                } else {
                    Image(systemName: "icloud.and.arrow.down")
                        .foregroundColor(.blue)
                }
            }

            HStack {
                Label(model.parameters, systemImage: "cpu")
                Spacer()
                Label(model.size, systemImage: "internaldrive")
                Spacer()
                Label(model.quantization, systemImage: "chart.bar.fill")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            if let progress = model.downloadProgress {
                ProgressView(value: progress) {
                    Text("\(Int(progress * 100))% downloaded")
                        .font(.caption)
                }
            }

            HStack {
                if model.isDownloaded {
                    Button {
                        Task {
                            await modelManager.loadModel(model)
                        }
                    } label: {
                        Label("Load", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(modelManager.currentModel?.id == model.id)

                    Button(role: .destructive) {
                        modelManager.deleteModel(model)
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button {
                        Task {
                            await modelManager.downloadModel(model)
                        }
                    } label: {
                        Label("Download", systemImage: "arrow.down.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.downloadProgress != nil)
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

struct CurrentModelCard: View {
    let model: LLMModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text(model.displayName)
                        .font(.headline)
                    Text("Loaded and ready")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }

            Divider()

            HStack {
                InfoChip(icon: "cpu", text: model.parameters)
                InfoChip(icon: "memorychip", text: model.quantization)
                InfoChip(icon: "text.alignleft", text: "\(model.contextLength) ctx")
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

struct InfoChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
    }
}
