//
//  MurmurHash3.swift
//  
//
//  Created by 叶永平 on 2023/3/15.
//

import Foundation
#if canImport(Cmurmur3)
import Cmurmur3
#endif


// 实现了MurmurHash3算法
//
// 该算法是一种非加密型哈希算法，它的特点是速度快，对于小数据块计算很快，而且对于哈希碰撞的情况也很少。
public struct MurmurHash3 {
  
  /// wrap MurmurHash3_x86_32 to swift
  /// - Parameters:
  ///   - data: data
  ///   - seed: seed
  /// - Returns: hash value
    public static func sum32(_ data: Data, seed: UInt32) -> UInt32 {
      let len = Int32(data.count)
      return data.withUnsafeBytes { dataPtr in
        var result: UInt32 = 0
        let buffer: UnsafePointer<UInt8> = dataPtr.baseAddress!.assumingMemoryBound(to: UInt8.self)
        MurmurHash3_x86_32(buffer, len, seed, &result)
        return result
      }
    }
  
  /// wrap MurmurHash3_x64_128 to swift
  /// - Parameters:
  ///   - data: data
  ///   - seed: seed
  /// - Returns: hash value
  public static func sum64(_ data: Data, seed: UInt32) -> UInt64 {
    let len = Int32(data.count)
    return data.withUnsafeBytes { dataPtr in
      var result: UInt64 = 0
      let buffer: UnsafePointer<UInt8> = dataPtr.baseAddress!.assumingMemoryBound(to: UInt8.self)
      MurmurHash3_x64_128(buffer, len, seed, &result)
      return result
    }
  }
  
  /// wrap c MurmurHash3_x86_128 to swift
  /// - Parameters:
  ///   - data: data
  ///   - seed: seed
  /// - Returns: hash value
  public static func sum128(_ data: Data, seed: UInt32) -> UInt64 {
    let len = Int32(data.count)
    return data.withUnsafeBytes { dataPtr in
      var result: UInt64 = 0
      let buffer: UnsafePointer<UInt8> = dataPtr.baseAddress!.assumingMemoryBound(to: UInt8.self)
      MurmurHash3_x86_128(buffer, len, seed, &result)
      return result
    }
  }
  
}
