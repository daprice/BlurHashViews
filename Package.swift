// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BlurHashViews",
	platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BlurHashViews",
            targets: ["BlurHashViews"]),
    ],
	dependencies: [
		.package(url: "https://github.com/daprice/SwiftKMeansPlusPlus.git", from: "1.0.0"),
	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BlurHashViews",
			dependencies: [
				.product(name: "SwiftKMeansPlusPlus", package: "SwiftKMeansPlusPlus")
			]
		),

    ]
)
