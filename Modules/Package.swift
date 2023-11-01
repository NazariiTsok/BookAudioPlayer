// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookAudioPlayerApp",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]),
        
        
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.3"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture",  from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0"),
    ],
    targets: [
        // MARK: - Features
        
        .target(
            name: "AppFeature",
            dependencies: [
                "BookFeature",
                "SharedFeature",
                "SubscriptionFeature",
                "StoreKitClient",
                .tca, .swiftUINavigation, .xctest, .swiftCollections
            ]
        ),
        .target(
            name: "SubscriptionFeature",
            dependencies: [
                "SharedFeature",
                "StoreKitClient",
                .tca
            ]
        ),
        .target(
            name: "BookFeature",
            dependencies: [
                "AudioBookClient",
                "AudioPlayerFeature",
                "TextBookFeature",
                "SubscriptionFeature",
                "SharedFeature",
                .tca
            ]
        ),
        .target(
            name: "AudioPlayerFeature",
            dependencies: [
                "AudioBookClient",
                "SharedFeature",
                "AudioPlayerClient",
                .tca
            ]
        ),
        .target(
            name: "TextBookFeature",
            dependencies: [
                "SharedFeature",
                .tca
            ]
        ),
        .target(
            name: "SharedFeature",
            dependencies: [
                .tca
            ]
        ),
        .target(
            name: "AudioPlayerClient",
            dependencies: [
                "SharedFeature",
                .tca, .xctest
            ]
        ),
        .target(
            name: "AudioBookClient",
            dependencies: [
                "SharedFeature",
                .tca, .xctest
            ]
        ),
        .target(
            name: "PremiumClient",
            dependencies: [
                "SharedFeature",
                .tca, .xctest
            ]
        ),
        .target(
            name: "StoreKitClient",
            dependencies: [
                "PremiumClient",
                "SharedFeature",
                .tca, .xctest
            ]
        ),
        .testTarget(
            name: "BookAudioPlayerAppTests",
            dependencies: ["AppFeature"]),
    ]
)


private extension Target.Dependency {
    static let tca: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let tcaDependencies: Self = .product(name: "Dependencies", package: "swift-composable-architecture")
    static let swiftCollections: Self = .product(name: "Collections", package: "swift-collections")
    static let swiftUINavigation: Self = .product(name: "SwiftUINavigation", package: "swiftui-navigation")
    static let xctest: Self = .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
    
}
