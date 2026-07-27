// swift-tools-version: 5.9

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "PartCue",
    defaultLocalization: "ja",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "PartCue",
            targets: ["AppModule"],
            bundleIdentifier: "dev.suisan.partcue",
            displayVersion: "0.2.0",
            bundleVersion: "2",
            appIcon: .placeholder(icon: .note),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [
                .phone
            ],
            supportedInterfaceOrientations: [
                .landscapeRight,
                .landscapeLeft
            ],
            appCategory: .music
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources"
        )
    ]
)