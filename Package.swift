// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault")
]

let package = Package(
    name: "Notifications",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Notifications",
            targets: ["Notifications"])
    ],
    targets: [
        .target(
            name: "Notifications",
            swiftSettings: swiftSettings),
        .testTarget(
            name: "NotificationsTests",
            dependencies: ["Notifications"],
            swiftSettings: swiftSettings)
    ]
)
