// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "RVS_Persistent_Prefs",
    products: [
        .library(
            name: "RVS-Persistent_Prefs",
            type: .dynamic,
            targets: ["RVS_Persistent_Prefs"])
    ],
    targets: [
        .target(
            name: "RVS_Persistent_Prefs",
            path: "./src")
    ]
)
