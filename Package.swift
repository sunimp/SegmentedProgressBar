// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SegmentedProgressBar",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SegmentedProgressBar",
            targets: ["SegmentedProgressBar"]
        ),
    ],
    targets: [
        .target(
            name: "SegmentedProgressBar"
        ),
    ]
)
