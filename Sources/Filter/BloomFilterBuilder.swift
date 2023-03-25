//
//  BloomFilterBuilder.swift
//  
//
//  Created by 叶永平 on 2023/3/17.
//

import Foundation

/*
 f 误报率
 m 布隆过滤器中的bit位数
 n 要插入的元素数量
 k hash函数的数量
 
 n = ceil(m / (-k / log(1 - exp(log(f) / k))))
 f = pow(1 - exp(-k / (m / n)), k)
 m = ceil((n * log(f)) / log(1 / pow(2, log(2))));
 k = round((m / n) * log(2));
 */


/// Calculate the best k value
/// - Parameters:
///   - m: bitmap capacity
///   - n: maximum number of items
/// - Returns: hash times
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


///  Calculation false positive  rate
/// - Parameters:
///   - m: bitmap capacity
///   - n: maximum number of items
///   - k: hash times
/// - Returns:  false positive  rate
fileprivate func falsePositiveProbability(m: Int, n: Int, k: Int) -> Double {
  let _k = Double(k)
  let _n = Double(n)
  let _m = Double(m)
  let f = pow(1.0 - exp(-_k * _n / _m), _k)
  return f
}

/// bloom filter builder
public final class BloomFilterBuilder {
  
  // m and n
  private struct MaN {
    let m: Int
    let n: Int
  }
  
  private var hasher: (any Hasher)?
  private var safety: Bool?
  private var man: MaN?
  private var bitmapBuilder: ((Int) -> Bitmap)?
  
  private init(bitmapBuilder: ((Int) -> Bitmap)? = nil, hasher: (any Hasher)? = nil) {
    self.bitmapBuilder = bitmapBuilder
    self.hasher = hasher
  }
  
  /// The default is based on inserting up to 10000 elements m/n = 20, the error rate at this time is 6.71e-05 < 1e-4
  public static let `default` = BloomFilterBuilder(hasher: DefaultHasher())
  
  /// build Filter
  /// - Returns: filter
  public func build() -> Filter {
    let bitmapBuilder = bitmapBuilder ??  { (m: Int) in CompressedBitmap(m) }
    let hasher = hasher ?? DefaultHasher()
    let man = man ?? MaN(m: 20 * 10000, n: 10000)
    let hashCount = optimalK(m: man.m, n: man.n)
    if let safety, safety {
      return SafetyBloomFilter(bitmap: bitmapBuilder(man.m), hashCount: hashCount, hasher: hasher)
    } else {
      return BloomFilter(hashCount: hashCount, bitmap: bitmapBuilder(man.m), hasher: hasher)
    }
  }
  
  /// Configuration capacity and m/n
  /// - Parameters:
  ///   - maxElements: maximum elements to add
  ///   - mnRate: The rate of the bitmap capacity to themaximum elements
  /// - Returns: builder
  public func with(maxElements: Int, mnRate: Int = 24) -> Self {
    man = MaN(m: maxElements*mnRate, n: maxElements)
    return self
  }
  
  /// Configuration capacity and fasle positive rate
  /// - Parameters:
  ///   - maxElements: maximum elements to add
  ///   - falsePositiveRate: false positive rate for maximum elements
  /// - Returns: builder
  public func with(maxElements: Int, falsePositiveRate: Double) -> Self {
    let n = Double(maxElements)
    let f = falsePositiveRate
    let m = Int(ceil((n * log(f)) / log(1 / pow(2, log(2)))))
    man = MaN(m: m, n: maxElements)
    return self
  }

  /// Configuration bitmap
  /// - Parameter builder: bitmap builder
  /// - Returns:
  public func with(bitmap builder: @escaping (Int) -> Bitmap) -> Self {
    bitmapBuilder = builder
    return self
  }
  
  /// set hasher
  /// - Parameter hasher: hasher
  /// - Returns: builder
  public func with(hasher: any Hasher) -> Self {
    self.hasher = hasher
    return self
  }
  
  /// Configuration thread safety filter
  /// - Parameter safety: ture if thread safety, false if not
  /// - Returns: builder
  public func with(safety: Bool) -> Self {
    self.safety = safety
    return self
  }
}
