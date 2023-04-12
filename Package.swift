// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Filters",
    products: [
        .library(
            name: "Filters",
            targets: ["Filters"]),
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
          name: "Cxxh",
          dependencies: [],
          path: "Sources/Cxxh"
        ),
        .target(
            name: "Filters",
            dependencies: [
              .target(name: "Cmurmur3"),
              .target(name: "Cxxh")
            ]),
        .testTarget(
            name: "FilterTests",
            dependencies: ["Filters"],
            resources: [.copy("keys.txt")]
        )
    ]
)
