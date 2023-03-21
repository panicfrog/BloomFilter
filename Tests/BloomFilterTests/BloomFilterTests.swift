import XCTest
@testable import BloomFilter

/// Read text file line by line in efficient way
public class LineReader {
  public let path: String
  private let trimmed: Bool
  
  fileprivate let file: UnsafeMutablePointer<FILE>!
  
  init?(path: String, trimmed: Bool = true) {
    self.path = path
    self.trimmed = trimmed
    file = fopen(path, "r")
    guard file != nil else { return nil }
  }
  
  public var nextLine: String? {
    var line: UnsafeMutablePointer<CChar>?
    var linecap: Int = 0
    defer { free(line) }
    if trimmed {
      guard getline(&line, &linecap, file) > 0 else { return nil }
      return String(cString: line!).trimmingCharacters(in: .newlines)
    } else {
      return getline(&line, &linecap, file) > 0 ? String(cString: line!) : nil
    }
  }
  
  deinit {
    fclose(file)
  }
}

extension LineReader: Sequence {
   public func makeIterator() -> AnyIterator<String> {
      return AnyIterator<String> {
         return self.nextLine
      }
   }
}

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
      .with(maxElements: max, falsePositiveRate: 0.00001)
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
  
  func testUniqKeys() throws {
    let max = 30000
    let bloom = BloomFilterBuilder.default
      .with(maxElements: max, falsePositiveRate: 0.00001)
      .build()
    let path = Bundle.module.url(forResource: "keys", withExtension: "txt")
    guard let path, let file = LineReader(path: path.relativePath) else {
      return
    }
    for line in file {
//      print(line)
      XCTAssertFalse(bloom.contains(line), "expect not contains \(line)")
      bloom.add(line)
    }
    for line in file {
      XCTAssertTrue(bloom.contains(line), "expect contains \(line)")
    }
  }
  
  
  func testMmapBitmap() throws {
    let max = 30000
    let url = URL(string: "/Users/yyp/Desktop/logs/bloom.cache")!
    let bloom = BloomFilterBuilder.default
      .with(maxElements: max)
      .with { m in
        try! MmapBitmap(m, path: url)
      }.build()
    for i in 0..<max {
      bloom.add("\(i)")
      XCTAssertEqual(bloom.contains("\(i + 1)"), false)
    }
    for i in 0..<max {
      XCTAssertEqual(bloom.contains("\(i)"), true)
    }
    XCTAssertEqual(bloom.contains("\(max)"), false)
  }
    
  func testSafetyBigCollection() throws {
      let max = 30000
      let bloom = BloomFilterBuilder.default
        .with(maxElements: max)
        .with(safety: true)
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
