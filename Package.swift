// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Filter",
    products: [
        .library(
            name: "Filter",
            targets: ["Filter"]),
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
          name: "Cmurmur3",
          dependencies: [],
          path: "Sources/Cmurmur3"
        ),
      
        .target(
            name: "Filter",
            dependencies: [
              .target(name: "Cmurmur3")
            ]),
        .testTarget(
            name: "FilterTests",
            dependencies: ["Filter"],
            resources: [.copy("keys.txt")]
        )
    ]
)
