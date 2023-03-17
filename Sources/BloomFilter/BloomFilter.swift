import Foundation

public final class BloomFilter {
  private var bitmap: Bitmap
  private let hashCount: Int
  private let hasher: any Hasher
 
  /// create bloom filter
  /// - Parameters:
  ///   - hashCount: bit count per element
  ///   - bitmap: bitmap
  ///   - hasher: hasher
  public init(hashCount: Int, bitmap: Bitmap, hasher: any Hasher) {
    self.hashCount = hashCount
    self.bitmap = bitmap
    self.hasher = hasher
  }
  
  /// add to bloom filter
  public func add(_ element: String) {
    let locations = hashValues(element)
    for location in locations {
      bitmap.set(value: true, for: location)
    }
  }
  
  /// add to bloom filter
  public func add(_ element: Data) {
    let locations = hashValues(element)
    for location in locations {
      bitmap.set(value: true, for: location)
    }
  }
  
  /// if the value is in the bloom filter
  /// - Parameter string: value
  /// - Returns: result
  public func contains(_ element: String) -> Bool {
    let hashes = hashValues(element)
    for hash in hashes where bitmap.get(for: hash) == false {
      return false
    }
    return true
  }
  
  /// if the value is in the bloom filter
  /// - Parameter string: value
  /// - Returns: result
  public func contains(_ element: Data) -> Bool {
    let hashes = hashValues(element)
    for hash in hashes where bitmap.get(for: hash) == false {
      return false
    }
    return true
  }
  
  private func hashValues(_ value: String) -> [Int] {
    let data = value.data(using: .utf8)!
    return hashValues(data)
  }
    
  private func hashValues(_ data: Data) -> [Int] {
    var hashValues = Array(repeating: 0, count: hashCount)
    let bitsCount = bitmap.count
    for i in 0..<hashCount {
      let hash = hasher.hashValues(data, seed: UInt32(i))
      hashValues[i] = abs(Int(hash)) % bitsCount
    }
    return hashValues
  }
  
}
