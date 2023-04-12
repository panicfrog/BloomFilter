//
//  BloomFilter.swift
//
//
//  Created by 叶永平 on 2023/3/17.
//

import Foundation

public final class BloomFilter: Filter {
    
    private var bitmap: Bitmap
    private let hashCount: Int
    private let hasher: any Hasher
    
    /// create bloom filter
    /// - Parameters:
    ///   - hashCount: bits count per element
    ///   - bitmap: bitmap
    ///   - hasher: hasher
    public init(hashCount: Int, bitmap: Bitmap, hasher: any Hasher) {
        self.hashCount = hashCount
        self.bitmap = bitmap
        self.hasher = hasher
    }
    
    /// add element to bloom filter
    /// - Parameter element: element
    public func add(_ element: FilterElement) {
        let data = element.data()
        let locations = hashValues(data)
        for location in locations {
            bitmap.set(value: true, for: location)
        }
    }
    
    /// determine whether the bloom filter contains this element
    /// - Parameter element: element
    /// - Returns: result
    public func contains(_ element: FilterElement) -> Bool {
        let data = element.data()
        let hashes = hashValues(data)
        for hash in hashes where bitmap.get(for: hash) == false {
            return false
        }
        return true
    }
    
    private func hashValues(_ data: Data) -> [Int] {
        var hashValues = Array(repeating: 0, count: hashCount)
        let bitsCount = Int64(bitmap.count)
        for i in 0..<hashCount {
            let hash = hasher.hashValues(data, seed: UInt32(i))
            hashValues[i] = Int(abs(Int64(hash)) % bitsCount)
        }
        return hashValues
    }
    
}
