// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target {
    static func target(
        name: String,
        sources: [String],
        dependencies: [Target.Dependency] = []
    ) -> Target {
        .target(
            name: name,
            dependencies: dependencies,
            path: "Sources",
            exclude: [],
            sources: sources,
            publicHeadersPath: nil,
            cSettings: nil,
            cxxSettings: nil,
            swiftSettings: nil,
            linkerSettings: nil
        )
    }
}

extension Target {
    static func testTarget(
        name: String,
        sources: [String],
        dependencies: [Target.Dependency] = []
    ) -> Target {
        .testTarget(
            name: name,
            dependencies: dependencies,
            path: "Tests",
            exclude: [], sources: sources,
            resources: nil,
            cSettings: nil,
            cxxSettings: nil,
            swiftSettings: nil,
            linkerSettings: nil
        )
    }
}

let package = Package(
    name: "AppsPlus",
    products: [
        .library(
            name: "AppsPlus",
            targets: ["AppsPlus"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/typelift/SwiftCheck", .exact("0.12.0"))
    ],
    targets: [
        .target(
            name: "AppsPlus",
            sources: ["Data"]
        ),
        .testTarget(
            name: "AppsPlusTests",
            sources: ["Data"],
            dependencies: ["AppsPlus", "SwiftCheck"]
        )
    ]
)
