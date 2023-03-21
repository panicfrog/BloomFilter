//
//  CompressedBitmap.swift
//  
//
//  Created by 叶永平 on 2023/3/21.
//

import Foundation

final class CompressedBitmap: Bitmap {
  private(set) var bits: ContiguousArray<UInt64>
  private let capacity: Int
  
  init(_ capacity: Int) {
    self.capacity = capacity
    self.bits = ContiguousArray(repeating: 0, count: ceil64(capacity))
  }
  
  var count: Int { capacity }
  
  func set(value: Bool, for index: Int) {
    guard capacity > index else { return }
    let (lct, idx) = locationIndex(index)
    if value {
      bits[lct] = bits[lct] | 1 << idx
    } else {
      bits[lct] = bits[lct] ^ 1 << idx
    }
  }
  
  func get(for index: Int) -> Bool? {
    guard capacity > index else { return nil }
    let (lct, idx) = locationIndex(index)
    return !(bits[lct] & 1 << idx == 0)
  }
}
