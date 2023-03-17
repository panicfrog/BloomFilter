//
//  CompressedBitmap.swift
//  
//
//  Created by 叶永平 on 2023/3/17.
//

import Foundation

@inline(__always)
private func ceil64(_ v: Int) -> Int {
  (v + 63) >> 6
}

final class CompressedBitmap {
  private var bits: ContiguousArray<UInt64>
  private let capacity: Int
  
  private static let UINT64_BITS: Int = 64
  
  @inline(__always)
  private static func locationIndex(_ value: Int) -> (location: Int, index: Int) {
    return (location: value / UINT64_BITS, index: value % UINT64_BITS)
  }
  
  init(_ capacity: Int) {
    self.capacity = capacity
    self.bits = ContiguousArray(repeating: 0, count: ceil64(capacity))
  }
}

extension CompressedBitmap: Bitmap {
  func set(value: Bool, for index: Int) {
    guard capacity > index else { return }
    let (lct, idx) = CompressedBitmap.locationIndex(index)
    if value {
      self.bits[lct] = self.bits[lct] | 1 << idx
    } else {
      self.bits[lct] = self.bits[lct] ^ 1 << idx
    }
  }
  
  func get(for index: Int) -> Bool? {
    guard capacity > index else { return nil }
    let (lct, idx) = CompressedBitmap.locationIndex(index)
    return !(self.bits[lct] & 1 << idx == 0)
  }
}
