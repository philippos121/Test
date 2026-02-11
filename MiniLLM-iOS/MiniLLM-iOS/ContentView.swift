//
//  ContentView.swift
//  MiniLLM
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelManager: ModelManager
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ModelsView()
                .tabItem {
                    Label("Models", systemImage: "cube.box")
                }
                .tag(0)

            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
                .tag(1)

            TrainingView()
                .tabItem {
                    Label("Train", systemImage: "cpu")
                }
                .tag(2)

            ServerView()
                .tabItem {
                    Label("Server", systemImage: "network")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
    }
}
