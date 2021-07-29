// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target {
    static func target(name: String,
                       sources: [String],
                       dependencies: [Target.Dependency] = [])
    -> Target {
        return .target(name: name,
                       dependencies: dependencies,
                       path: "Sources",
                       exclude: [],
                       sources: sources,
                       publicHeadersPath: nil,
                       cSettings: nil,
                       cxxSettings: nil,
                       swiftSettings: nil,
                       linkerSettings: nil)
    }
}

let package = Package(
    name: "AppsPlus",
    products: [
        .library(
            name: "AppsPlus",
            targets: ["AppsPlus"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppsPlus",
            sources: ["Data"]),
    ]
)
