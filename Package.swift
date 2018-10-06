// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "elasticsearch-test",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0"),

        .package(url: "https://github.com/nodes-vapor/n-meta.git", from: "3.0.0-beta"),

        .package(url: "https://github.com/twof/VaporMailgunService.git", from: "1.1.0"),
        // change to use version 0.1.1 as soon as it is released
        .package(url: "https://github.com/ryangrimm/VaporElasticsearch.git", .branch("feature/remove-whitespaces-in-folders"))

    ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "FluentMySQL",
            "Redis",
            "NMeta",
            "Mailgun",
            "Elasticsearch"
            ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
