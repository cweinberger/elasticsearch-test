// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "elasticsearch-test",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),

        .package(url: "https://github.com/ryangrimm/VaporElasticsearch.git", .branch("feature/remove-whitespaces-in-folders"))
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Elasticsearch"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

