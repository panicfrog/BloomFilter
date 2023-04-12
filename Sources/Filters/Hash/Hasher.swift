//
//  Hasher.swift
//  
//
//  Created by 叶永平 on 2023/3/17.
//

import Foundation

public protocol Hasher {
  associatedtype I: FixedWidthInteger
  func hashValues(_ data: Data, seed: UInt32) -> I
}

public final class DefaultHasher: Hasher {
  public typealias I = UInt32
  public func hashValues(_ data: Data, seed: UInt32) -> I {
    MurmurHash3.x86_32(data, seed: seed)
  }
}

public final class Xxhasher: Hasher {
  public typealias I = UInt32
  public func hashValues(_ data: Data, seed: UInt32) -> I {
    XXH.xxh32(data, seed: seed)
  }
}
