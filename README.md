# Filter

This is a library for implementing Bloom and Cuckoo filters in Swift. The library provides two filters `BloomFilter` and `CuckooFilter` which can be used to create and manipulate Bloom and Cuckoo filters.

## Installation

#### SPM

The library can be installed using [swift package manager](https://www.swift.org/package-manager/)

```swift
// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YourPackage",
    products: [
        .library(name: "YourPackage", targets: ["YourPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/panicfrog/Filter.git", from: "0.0.2"),
    ],
    targets: [
        .target(
            name: "YourPackage",
            dependencies: ["Filter"]),
    ]
)
```

#### Xcode

File -> Add packages  https://github.com/panicfrog/Filter.git

## Usage

```swift
// create bloom filter with `BloomFilterBuilder`
let bloom = BloomFilterBuilder.default
        .with(maxElements: max)
        .with(safety: true)
        .build()
// add item to filter
bloom.add("hello")
// determine whether item is comtained in the bloom filter
bloom.contains("hello")
```

you can also use mmap to mapping bloom's bitmap to a file

```swift
// create bloom filter with `BloomFilterBuilder`, that can mapping bitmap to file using mmap
let url = URL(string: "<path your want to mapping>")!
let bloom = BloomFilterBuilder.default
  .with(maxElements: max)
  .with { m in
    try! MmapBitmap(m, path: url)
  }.build()
// add item to filter
bloom.add("item1")
// determine whether item is comtained in the bloom filter
bloom.contains("item1")
```

## API

You can clone the warehouse code, and then use Swift-DocC to produce the api documentation for local preview, and the online documentation is coming soon ...

```shell
swift package --disable-sandbox preview-documentation --target Filter
```

## License

This library is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.
