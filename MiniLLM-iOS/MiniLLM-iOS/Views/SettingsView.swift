//
//  SettingsView.swift
//  MiniLLM
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var modelManager: ModelManager
    @State private var showClearDataAlert = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Model Loaded")
                        Spacer()
                        Text(modelManager.currentModel?.displayName ?? "None")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }

                Section {
                    NavigationLink {
                        StorageView()
                    } label: {
                        Label("Storage Management", systemImage: "internaldrive")
                    }

                    NavigationLink {
                        PerformanceView()
                    } label: {
                        Label("Performance", systemImage: "speedometer")
                    }
                } header: {
                    Text("System")
                }

                Section {
                    Link(destination: URL(string: "https://github.com/ggerganov/llama.cpp")!) {
                        HStack {
                            Label("llama.cpp", systemImage: "link")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption)
                        }
                    }

                    Link(destination: URL(string: "https://huggingface.co/models")!) {
                        HStack {
                            Label("Hugging Face", systemImage: "link")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Resources")
                }

                Section {
                    Button(role: .destructive) {
                        showClearDataAlert = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("This will delete all downloaded models and training data")
                }
            }
            .navigationTitle("Settings")
            .alert("Clear All Data?", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will delete all downloaded models, datasets, and chat history. This action cannot be undone.")
            }
        }
    }

    private func clearAllData() {
        // Clear all models
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try? FileManager.default.removeItem(at: documentsPath.appendingPathComponent("models"))
        try? FileManager.default.removeItem(at: documentsPath.appendingPathComponent("adapters"))

        // Clear user defaults
        UserDefaults.standard.removeObject(forKey: "downloadedModels")

        // Unload current model
        modelManager.unloadModel()
    }
}

struct StorageView: View {
    @State private var storageUsed: String = "Calculating..."
    @State private var modelsSize: String = "..."
    @State private var adaptersSize: String = "..."

    var body: some View {
        List {
            Section {
                HStack {
                    Label("Models", systemImage: "cube.box")
                    Spacer()
                    Text(modelsSize)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Label("LoRA Adapters", systemImage: "cpu")
                    Spacer()
                    Text(adaptersSize)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Storage Usage")
            }

            Section {
                HStack {
                    Text("Total Used")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(storageUsed)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Storage")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            calculateStorage()
        }
    }

    private func calculateStorage() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let modelsPath = documentsPath.appendingPathComponent("models")
        let adaptersPath = documentsPath.appendingPathComponent("adapters")

        modelsSize = formatBytes(directorySize(at: modelsPath))
        adaptersSize = formatBytes(directorySize(at: adaptersPath))

        let total = directorySize(at: modelsPath) + directorySize(at: adaptersPath)
        storageUsed = formatBytes(total)
    }

    private func directorySize(at url: URL) -> Int64 {
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }

        var totalSize: Int64 = 0

        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                  let fileSize = resourceValues.fileSize else {
                continue
            }
            totalSize += Int64(fileSize)
        }

        return totalSize
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct PerformanceView: View {
    var body: some View {
        List {
            Section {
                Toggle("Use Metal Acceleration", isOn: .constant(true))
                Toggle("Optimize for Battery", isOn: .constant(false))
            } header: {
                Text("Inference")
            } footer: {
                Text("Metal provides GPU acceleration for faster inference. Battery optimization reduces performance but extends battery life.")
            }

            Section {
                Picker("Thread Count", selection: .constant(4)) {
                    Text("2 threads").tag(2)
                    Text("4 threads").tag(4)
                    Text("6 threads").tag(6)
                    Text("8 threads").tag(8)
                }
            } header: {
                Text("CPU")
            }
        }
        .navigationTitle("Performance")
        .navigationBarTitleDisplayMode(.inline)
    }
}
