// swift-tools-version: 5.9
// Package manifest for MiniLLM dependencies

import PackageDescription

let package = Package(
    name: "MiniLLM",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "MiniLLM",
            targets: ["MiniLLM"]
        )
    ],
    dependencies: [
        // llama.cpp Swift bindings
        // Note: You would add the actual llama.cpp package here
        // .package(url: "https://github.com/ggerganov/llama.cpp", branch: "master")
    ],
    targets: [
        .target(
            name: "MiniLLM",
            dependencies: []
        )
    ]
)
