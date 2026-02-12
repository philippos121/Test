//
//  ChatView.swift
//  MiniLLM
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var modelManager: ModelManager
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isGenerating = false
    @State private var showSettings = false
    @State private var showExportSheet = false

    @State private var temperature: Double = 0.7
    @State private var maxTokens: Int = 512

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Model indicator
                if let model = modelManager.currentModel {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text(model.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        if !messages.isEmpty {
                            Text("\(messages.count) messages")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemBackground))
                }

                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if messages.isEmpty {
                                EmptyStateView()
                            } else {
                                ForEach(messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }

                            if isGenerating {
                                HStack {
                                    ProgressView()
                                        .padding(.trailing, 8)
                                    Text("Thinking...")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                // Input area
                HStack(spacing: 12) {
                    TextField("Message...", text: $inputText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...5)
                        .disabled(!modelManager.isModelLoaded || isGenerating)

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !modelManager.isModelLoaded || isGenerating)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            showSettings.toggle()
                        } label: {
                            Label("Settings", systemImage: "slider.horizontal.3")
                        }

                        Button {
                            showExportSheet = true
                        } label: {
                            Label("Export Chat", systemImage: "square.and.arrow.up")
                        }
                        .disabled(messages.isEmpty)

                        Divider()

                        Button(role: .destructive) {
                            messages.removeAll()
                        } label: {
                            Label("Clear Chat", systemImage: "trash")
                        }
                        .disabled(messages.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                ChatSettingsView(temperature: $temperature, maxTokens: $maxTokens)
            }
            .sheet(isPresented: $showExportSheet) {
                if let exportURL = createExportFile() {
                    ShareSheet(activityItems: [exportURL])
                }
            }
        }
    }

    private func sendMessage() {
        let userMessage = ChatMessage(role: "user", content: inputText)
        messages.append(userMessage)

        let prompt = inputText
        inputText = ""
        isGenerating = true

        Task {
            let response = await modelManager.generate(
                prompt: prompt,
                temperature: temperature,
                maxTokens: maxTokens
            )

            let assistantMessage = ChatMessage(role: "assistant", content: response)
            messages.append(assistantMessage)
            isGenerating = false
        }
    }

    private func createExportFile() -> URL? {
        let exportData = messages.map { msg in
            ["role": msg.role, "content": msg.content,
             "timestamp": ISO8601DateFormatter().string(from: msg.timestamp)]
        }

        guard let jsonData = try? JSONSerialization.data(
            withJSONObject: [
                "messages": exportData,
                "model": modelManager.currentModel?.displayName ?? "Unknown"
            ],
            options: .prettyPrinted
        ) else { return nil }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("minillm_chat_\(Int(Date().timeIntervalSince1970)).json")
        try? jsonData.write(to: tempURL)
        return tempURL
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == "user" {
                Spacer()
            }

            VStack(alignment: message.role == "user" ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.role == "user" ? Color.blue : Color.secondary.opacity(0.2))
                    .foregroundColor(message.role == "user" ? .white : .primary)
                    .cornerRadius(16)
                    .textSelection(.enabled)

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .contextMenu {
                Button {
                    UIPasteboard.general.string = message.content
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }

            if message.role == "assistant" {
                Spacer()
            }
        }
    }
}

struct EmptyStateView: View {
    @EnvironmentObject var modelManager: ModelManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            if modelManager.isModelLoaded {
                Text("Start a conversation")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("Ask anything to \(modelManager.currentModel?.displayName ?? "the model")")
                    .foregroundColor(.secondary)
            } else {
                Text("No model loaded")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("Load a model from the Models tab to start chatting")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
}

struct ChatSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var temperature: Double
    @Binding var maxTokens: Int

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Temperature")
                            Spacer()
                            Text(String(format: "%.2f", temperature))
                                .foregroundColor(.secondary)
                        }

                        Slider(value: $temperature, in: 0...2, step: 0.1)

                        Text("Higher values make output more random, lower values more focused")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Sampling")
                }

                Section {
                    Stepper(value: $maxTokens, in: 128...2048, step: 128) {
                        HStack {
                            Text("Max Tokens")
                            Spacer()
                            Text("\(maxTokens)")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Length")
                } footer: {
                    Text("Maximum number of tokens to generate. More tokens = longer responses but slower generation")
                }
            }
            .navigationTitle("Generation Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
