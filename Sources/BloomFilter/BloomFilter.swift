import Foundation

/*
 f 误报率
 m 布隆过滤器中的bit位数
 n 要插入的元素数量
 k hash函数的数量
 */

// http://pages.cs.wisc.edu/~cao/papers/summary-cache/node8.html

@inline(__always)
func ceil64(_ v: Int) -> Int {
  (v + 63) >> 6
}

fileprivate func optimalK(m: Int, n: Int) -> Int {
  let _m = Double(m)
  let _n = Double(n)
  let k = _m / _n * M_LN2
  let ck = Int(ceil(k))
  let fk = Int(floor(k))
  let ckf = falsePositiveProbability(m: m, n: n, k: ck)
  let fkf = falsePositiveProbability(m: m, n: n, k: fk)
  return ckf > fkf ? fk : ck
}

fileprivate func falsePositiveProbability(m: Int, n: Int, k: Int) -> Double {
  let _k = Double(k)
  let _n = Double(n)
  let _m = Double(m)
  let f = pow(1.0 - exp(-_k * _n / _m), _k)
  return f
}

open class BloomFilter {
  private var bits: [UInt64]
  private var bitsCount: Int
  private let hashCount: Int
  private let seed: UInt32
  
  // m/n 最优比例（平衡误报率和内存占用）9.8385e-6 < 1e-5
  public static let mnRate1e_5 = 24
  private static let UINT64_BITS: Int = 64
  
  /// init function
  /// - Parameters:
  ///   - maxElements: maximum capacity
  ///   - seed: hash seed
  ///   - rate: rate of bit to maximum capacity
  public init(maxElements: Int, seed: UInt32 = 0, rate: Int = mnRate1e_5) {
    let n = maxElements
    let m = n * rate
    let k = optimalK(m: m, n: n)
    //        print("optimal K \(k)")
    self.bits = Array(repeating: 0, count: ceil64(m))
    self.hashCount = k
    self.bitsCount = m
    self.seed = seed
  }
  
  
  @inline(__always)
  private func locationIndex(_ value: Int) -> (location: Int, index: Int) {
    return (location: value / BloomFilter.UINT64_BITS, index: value % BloomFilter.UINT64_BITS)
  }
  
  /// add to bloom filter
  open func add(_ element: String) {
    let locations = self.hashValues(element)
    for location in locations {
      let (lct, idx) = locationIndex(location)
      self.bits[lct] = self.bits[lct] | 1 << idx
    }
  }
  
  /// if the value is in the bloom filter
  /// - Parameter string: value
  /// - Returns: result
  open func contains(_ element: String) -> Bool {
    let hashes = self.hashValues(element)
    for hash in hashes {
      let (lct, idx) = locationIndex(hash)
      if self.bits[lct] & 1 << idx == 0 {
        return false
      }
    }
    return true
  }
  
  private func hashValues(_ string: String) -> [Int] {
    var hashValues = [Int]()
    let data = string.data(using: .utf8)!
    for i in 0..<self.hashCount {
      let hash = MurmurHash3.sum32(data, seed: self.seed &+ UInt32(i))
      let index = abs(Int(hash)) % self.bitsCount
      hashValues.append(index)
    }
    return hashValues
  }
}
