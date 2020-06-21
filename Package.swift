// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "RVS_Persistent_Prefs",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .macOS(.v10_14),
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "RVS-Persistent-Prefs",
            targets: ["RVS_Persistent_Prefs"])
    ],
    dependencies: [
        .package(
            name: "RVS-Generic-Swift-Toolbox",
            url: "git@github.com:RiftValleySoftware/RVS_Generic_Swift_Toolbox.git",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "RVS_Persistent_Prefs",
            path: "./src")
    ]
)
