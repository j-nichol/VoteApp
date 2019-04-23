// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "VoteApp",
    dependencies: [
        // 💧 Vapor
        .package(url: "https://github.com/vapor/vapor.git", from: "3.2.2"),
        // 🔵 Swift ORM built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        // 🍁 Leaf
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.2"),
        // ⛔️ Authentication
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.3")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentPostgreSQL", "Leaf", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
    ]
)
