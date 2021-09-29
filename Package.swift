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
            exclude: Array(Set(["Data", "UI", "Testing"]).subtracting(sources)),
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
            exclude: [],
            sources: sources,
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
            name: "AppsPlusData",
            targets: ["AppsPlusData"]
        ),
        .library(
            name: "AppsPlusUI",
            targets: ["AppsPlusUI"]
        ),
        .library(
            name: "AppsPlusTesting",
            targets: ["AppsPlusTesting"]
        ),
        .library(
            name: "AutoUpdater",
            targets: ["AutoUpdater"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/typelift/SwiftCheck", .exact("0.12.0"))
    ],
    targets: [
        .target(
            name: "AppsPlusData",
            sources: ["Data"]
        ),
        .testTarget(
            name: "AppsPlusDataTests",
            sources: ["Data"],
            dependencies: ["AppsPlusData", "SwiftCheck"]
        ),
        .target(
            name: "AppsPlusUI",
            sources: ["UI"]
        ),
        .target(
            name: "AppsPlusTesting",
            sources: ["Testing"],
            dependencies: ["AppsPlusData", "SwiftCheck"]
        ),
        .target(
            name: "AutoUpdater",
            sources: ["AutoUpdater"]
        ),
        .testTarget(
            name: "AutoUpdaterTests",
            sources: ["AutoUpdater"],
            dependencies: ["AutoUpdater"]
        )
    ]
)
