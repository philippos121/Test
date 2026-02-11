//
//  ServerView.swift
//  MiniLLM
//

import SwiftUI

struct ServerView: View {
    @EnvironmentObject var modelManager: ModelManager
    @EnvironmentObject var serverManager: ServerManager

    var body: some View {
        NavigationView {
            List {
                Section {
                    ServerStatusCard(
                        isRunning: serverManager.isServerRunning,
                        serverURL: serverManager.serverURL,
                        requestCount: serverManager.requestCount
                    )
                } header: {
                    Text("Status")
                }

                Section {
                    Button {
                        if serverManager.isServerRunning {
                            serverManager.stopServer()
                        } else {
                            serverManager.startServer(modelManager: modelManager)
                        }
                    } label: {
                        Label(
                            serverManager.isServerRunning ? "Stop Server" : "Start Server",
                            systemImage: serverManager.isServerRunning ? "stop.circle.fill" : "play.circle.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(serverManager.isServerRunning ? .red : .green)
                    .disabled(!modelManager.isModelLoaded)

                    if !modelManager.isModelLoaded {
                        Text("Load a model first to start the server")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Control")
                }

                if serverManager.isServerRunning {
                    Section {
                        APIEndpointsView(baseURL: serverManager.serverURL)
                    } header: {
                        Text("API Endpoints")
                    }

                    Section {
                        ForEach(serverManager.recentRequests) { request in
                            RequestRow(request: request)
                        }
                    } header: {
                        Text("Recent Requests")
                    }
                }
            }
            .navigationTitle("Local Server")
        }
    }
}

struct ServerStatusCard: View {
    let isRunning: Bool
    let serverURL: String
    let requestCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isRunning ? "antenna.radiowaves.left.and.right" : "network.slash")
                    .foregroundColor(isRunning ? .green : .secondary)
                    .font(.title2)

                VStack(alignment: .leading) {
                    Text(isRunning ? "Server Running" : "Server Offline")
                        .font(.headline)

                    if isRunning {
                        Text(serverURL)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                }

                Spacer()

                if isRunning {
                    VStack(alignment: .trailing) {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)

                        Text("\(requestCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if isRunning {
                Divider()

                Text("Your model is now accessible via OpenAI-compatible API from any device on your network")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(isRunning ? Color.green.opacity(0.1) : Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

struct APIEndpointsView: View {
    let baseURL: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            EndpointRow(
                method: "POST",
                path: "/v1/chat/completions",
                description: "Chat completion (OpenAI compatible)"
            )

            EndpointRow(
                method: "GET",
                path: "/v1/models",
                description: "List available models"
            )

            EndpointRow(
                method: "GET",
                path: "/health",
                description: "Health check"
            )

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Example cURL Request:")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text("""
                curl \(baseURL)/v1/chat/completions \\
                  -H "Content-Type: application/json" \\
                  -d '{
                    "messages": [{"role": "user", "content": "Hello!"}],
                    "temperature": 0.7,
                    "max_tokens": 512
                  }'
                """)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EndpointRow: View {
    let method: String
    let path: String
    let description: String

    var body: some View {
        HStack {
            Text(method)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(methodColor)
                .cornerRadius(4)

            VStack(alignment: .leading, spacing: 2) {
                Text(path)
                    .font(.caption)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var methodColor: Color {
        switch method {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "DELETE": return .red
        default: return .gray
        }
    }
}

struct RequestRow: View {
    let request: ServerRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(request.method)
                    .font(.caption)
                    .fontWeight(.bold)

                Text(request.endpoint)
                    .font(.caption)

                Spacer()

                Text("\(Int(request.responseTime * 1000))ms")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let prompt = request.prompt {
                Text(prompt)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Text(request.timestamp.formatted(date: .omitted, time: .standard))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
