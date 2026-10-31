// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DesignTokens",
    platforms: [
        .iOS(.v26),
        .macCatalyst(.v26)  // Docs gate: lets xcodebuild run tests on the host without a simulator
    ],
    products: [
        .library(
            name: "DesignTokens",
            targets: ["DesignTokens"]
        )
    ],
    targets: [
        .target(
            name: "DesignTokens"
        ),
        .testTarget(
            name: "DesignTokensTests",
            dependencies: ["DesignTokens"]
        )
    ]
)
