//
//  Bitmap.swift
//  
//
//  Created by 叶永平 on 2023/3/17.
//

import Foundation


public protocol Bitmap {
  func `set`(value: Bool, for index: Int)
  func `get`(for index: Int) -> Bool?
  var count: Int { get }
}


private let UINT64_BITS: Int = 64

@inline(__always)
internal func locationIndex(_ value: Int) -> (location: Int, index: Int) {
  return (location: value / UINT64_BITS, index: value % UINT64_BITS)
}

@inline(__always)
internal func ceil64(_ v: Int) -> Int {
  (v + 63) >> 6
}
