// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "RVS_Persistent_Prefs",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .macOS(.v10.14),
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "RVS-Persistent-Prefs",
            type: .dynamic,
            targets: ["RVS_Persistent_Prefs"])
    ],
    targets: [
        .target(
            name: "RVS_Persistent_Prefs",
            path: "./src")
    ]
)
