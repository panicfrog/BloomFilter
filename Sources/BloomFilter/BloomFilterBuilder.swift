//
//  File.swift
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
 */

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

/// bloom filter builder
public final class BloomFilterBuilder {
  private var bitmap: Bitmap?
  private var hasher: (any Hasher)?
  private var hashCount: Int?
  
  private init(bitmap: Bitmap? = nil, hasher: (any Hasher)? = nil, hashCount: Int? = nil) {
    self.bitmap = bitmap
    self.hasher = hasher
    self.hashCount = hashCount
  }
  
  /// The default is based on inserting up to 10000 elements m/n = 20, the error rate at this time is 6.71e-05 < 1e-4
  static let `default` = BloomFilterBuilder(bitmap: CompressedBitmap(20*10000),
                                            hasher: DefaultHasher(),
                                            hashCount: optimalK(m: 20*10000, n: 10000))
  
  public func build() -> Filter {
    let bitmap = self.bitmap ?? CompressedBitmap(20*10000)
    let hasher = self.hasher ?? DefaultHasher()
    let hashCount = self.hashCount ?? optimalK(m: 20*10000, n: 10000)
    return BloomFilter(hashCount: hashCount, bitmap: bitmap, hasher: hasher)
  }
  
  /// Configuration capacity and m/n
  /// - Parameters:
  ///   - maxElements: maximum elements to add
  ///   - mnRate: The ratio of the bitmap capacity to themaximum elements
  public func with(maxElements: Int, mnRate: Int = 24) -> Self {
    let n = maxElements
    let m = n * mnRate
    let k = optimalK(m: m, n: n)
    self.bitmap = CompressedBitmap(m)
    self.hashCount = k
    return self
  }
  
  /// set hasher
  /// - Parameter hasher: hasher
  public func with(hasher: any Hasher) -> Self {
    self.hasher = hasher
    return self
  }
}
