//
//  MiniLLMApp.swift
//  MiniLLM - On-Device AI
//
//  Download, train, and host mini open-source LLMs on your iPhone
//

import SwiftUI

@main
struct MiniLLMApp: App {
    @StateObject private var modelManager = ModelManager()
    @StateObject private var serverManager = ServerManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelManager)
                .environmentObject(serverManager)
        }
    }
}
