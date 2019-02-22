// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "VoteApp",
    dependencies: [
        // 💧 Vapor
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.1"),
        // 🔵 Swift ORM built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),
        // 🍁 Leaf
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        // ⛔️ Authentication
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc")//,
        // 🔑 CryptoSwift
        //.package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "0.14.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentPostgreSQL", "Leaf", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
