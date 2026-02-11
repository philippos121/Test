//
//  ServerService.swift
//  MiniLLM
//
//  OpenAI-compatible API server running on device
//

import Foundation
import Network

actor ServerService {
    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private weak var modelManager: ModelManager?

    func startServer(
        port: UInt16,
        modelManager: ModelManager,
        onRequest: @escaping (ServerRequest) -> Void
    ) async throws {
        self.modelManager = modelManager

        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true

        listener = try NWListener(using: params, on: NWEndpoint.Port(integerLiteral: port))

        listener?.newConnectionHandler = { [weak self] connection in
            Task {
                await self?.handleConnection(connection, onRequest: onRequest)
            }
        }

        listener?.start(queue: .global())
    }

    func stopServer() {
        listener?.cancel()
        connections.forEach { $0.cancel() }
        connections.removeAll()
        listener = nil
    }

    private func handleConnection(_ connection: NWConnection, onRequest: @escaping (ServerRequest) -> Void) {
        connections.append(connection)

        connection.start(queue: .global())

        receiveRequest(connection: connection, onRequest: onRequest)
    }

    private func receiveRequest(connection: NWConnection, onRequest: @escaping (ServerRequest) -> Void) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let data = data, let request = String(data: data, encoding: .utf8) else {
                connection.cancel()
                return
            }

            Task {
                await self?.handleHTTPRequest(request, connection: connection, onRequest: onRequest)
            }

            if !isComplete {
                self?.receiveRequest(connection: connection, onRequest: onRequest)
            }
        }
    }

    private func handleHTTPRequest(_ request: String, connection: NWConnection, onRequest: @escaping (ServerRequest) -> Void) async {
        let startTime = Date()
        let lines = request.components(separatedBy: "\r\n")

        guard let requestLine = lines.first else {
            sendResponse(connection: connection, statusCode: 400, body: "Bad Request")
            return
        }

        let components = requestLine.components(separatedBy: " ")
        guard components.count >= 2 else {
            sendResponse(connection: connection, statusCode: 400, body: "Bad Request")
            return
        }

        let method = components[0]
        let path = components[1]

        // Handle different endpoints
        switch path {
        case "/v1/chat/completions":
            await handleChatCompletion(request: request, connection: connection, startTime: startTime, onRequest: onRequest)

        case "/v1/models":
            await handleModels(connection: connection, startTime: startTime, onRequest: onRequest)

        case "/health":
            sendResponse(connection: connection, statusCode: 200, body: "{\"status\":\"ok\"}")

        default:
            sendResponse(connection: connection, statusCode: 404, body: "Not Found")
        }
    }

    private func handleChatCompletion(
        request: String,
        connection: NWConnection,
        startTime: Date,
        onRequest: @escaping (ServerRequest) -> Void
    ) async {
        // Parse JSON body
        guard let bodyStart = request.range(of: "\r\n\r\n")?.upperBound,
              let bodyData = String(request[bodyStart...]).data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any],
              let messages = json["messages"] as? [[String: String]] else {
            sendResponse(connection: connection, statusCode: 400, body: "{\"error\":\"Invalid request\"}")
            return
        }

        // Extract prompt from messages
        let prompt = messages.last?["content"] ?? ""
        let temperature = json["temperature"] as? Double ?? 0.7
        let maxTokens = json["max_tokens"] as? Int ?? 512

        // Generate response using model
        guard let modelManager = modelManager else {
            sendResponse(connection: connection, statusCode: 500, body: "{\"error\":\"No model loaded\"}")
            return
        }

        let response = await modelManager.generate(prompt: prompt, temperature: temperature, maxTokens: maxTokens)

        // Format as OpenAI-compatible response
        let responseJSON: [String: Any] = [
            "id": "chatcmpl-\(UUID().uuidString)",
            "object": "chat.completion",
            "created": Int(Date().timeIntervalSince1970),
            "model": modelManager.currentModel?.name ?? "unknown",
            "choices": [
                [
                    "index": 0,
                    "message": [
                        "role": "assistant",
                        "content": response
                    ],
                    "finish_reason": "stop"
                ]
            ]
        ]

        if let responseData = try? JSONSerialization.data(withJSONObject: responseJSON),
           let responseString = String(data: responseData, encoding: .utf8) {
            sendResponse(connection: connection, statusCode: 200, body: responseString, contentType: "application/json")

            let serverRequest = ServerRequest(
                timestamp: Date(),
                method: "POST",
                endpoint: "/v1/chat/completions",
                prompt: prompt,
                responseTime: Date().timeIntervalSince(startTime)
            )
            onRequest(serverRequest)
        }
    }

    private func handleModels(
        connection: NWConnection,
        startTime: Date,
        onRequest: @escaping (ServerRequest) -> Void
    ) async {
        let responseJSON: [String: Any] = [
            "object": "list",
            "data": [
                [
                    "id": modelManager?.currentModel?.name ?? "no-model-loaded",
                    "object": "model",
                    "created": Int(Date().timeIntervalSince1970),
                    "owned_by": "local"
                ]
            ]
        ]

        if let responseData = try? JSONSerialization.data(withJSONObject: responseJSON),
           let responseString = String(data: responseData, encoding: .utf8) {
            sendResponse(connection: connection, statusCode: 200, body: responseString, contentType: "application/json")

            let serverRequest = ServerRequest(
                timestamp: Date(),
                method: "GET",
                endpoint: "/v1/models",
                prompt: nil,
                responseTime: Date().timeIntervalSince(startTime)
            )
            onRequest(serverRequest)
        }
    }

    private func sendResponse(connection: NWConnection, statusCode: Int, body: String, contentType: String = "text/plain") {
        let statusText = statusCode == 200 ? "OK" : statusCode == 404 ? "Not Found" : "Error"
        let response = """
        HTTP/1.1 \(statusCode) \(statusText)\r
        Content-Type: \(contentType)\r
        Content-Length: \(body.utf8.count)\r
        Access-Control-Allow-Origin: *\r
        \r
        \(body)
        """

        guard let data = response.data(using: .utf8) else { return }

        connection.send(content: data, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
}
