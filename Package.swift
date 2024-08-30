// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlbyWidget",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AlbyWidget",
            targets: ["AlbyWidget"])
    ],
    dependencies: [
        .package(url: "https://github.com/lucaszischka/BottomSheet.git", from: "3.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AlbyWidget",
            dependencies: [.product(name: "BottomSheet", package: "BottomSheet", condition: .when(platforms: [.iOS]))]
        )
    ],
    swiftLanguageVersions: [.v5]
)
