import XCTest
@testable import BloomFilter

final class BloomFilterTests: XCTestCase {
  func testMurmur3() throws {
    let sum32 = MurmurHash3.sum32("Hello, world".data(using: .utf8)!, seed: 0)
    let sum64 = MurmurHash3.sum64("Hello, world".data(using: .utf8)!, seed: 0)
    let sum128 = MurmurHash3.sum128("Hello, world".data(using: .utf8)!, seed: 0)
    print("sum with 'hello, world', sum32: \(sum32), sum64: \(sum64), sum128: \(sum128)")
    XCTAssertEqual(sum32, 1785891924)
    XCTAssertEqual(sum64, 16992797472532904308)
    XCTAssertEqual(sum128, 16509527251599854760)
  }
  func testBloomFilter() throws {
    let bloom = BloomFilterBuilder.default
      .with(maxElements: 5)
      .build()
    bloom.add("Hello, world")
    XCTAssertEqual(bloom.contains("Hello, world"), true)
    XCTAssertEqual(bloom.contains("bloom"), false)
    bloom.add("bloom")
    XCTAssertEqual(bloom.contains("bloom"), true)
  }
  func testOverflow() throws {
    let bloom = BloomFilterBuilder.default
      .with(maxElements: 50)
      .build()
    bloom.add("Hello, world")
    XCTAssertEqual(bloom.contains("Hello, world"), true)
  }
  
  func testBigCollection() throws {
    let max = 30000
    let bloom = BloomFilterBuilder.default
      .with(maxElements: max)
      .build()
    for i in 0..<max {
      bloom.add("\(i)")
      XCTAssertEqual(bloom.contains("\(i + 1)"), false)
    }
    for i in 0..<max {
      XCTAssertEqual(bloom.contains("\(i)"), true)
    }
    XCTAssertEqual(bloom.contains("\(max)"), false)
  }
}
