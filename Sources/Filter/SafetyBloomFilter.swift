//
//  SafetyBloomFilter.swift
//  
//
//  Created by mac studio on 2023/3/18.
//

import Foundation

final class SafetyBloomFilter: Filter {
    
    private var bitmap: Bitmap
    private let hashCount: Int
    private let hasher: any Hasher
    private let queue = DispatchQueue(label: "github.io.panicfrog.BloomFilter.SafetyBloomFilter",
                                      attributes: .concurrent)
    
    /// create bloom filter
    /// - Parameters:
    ///   - bitmap: bitmap
    ///   - hashCount: bits count per element
    ///   - hasher: hasher
    init(bitmap: Bitmap, hashCount: Int, hasher: any Hasher) {
        self.bitmap = bitmap
        self.hashCount = hashCount
        self.hasher = hasher
    }
    
    /// add element to bloom filter
    /// - Parameter element: element
    func add(_ element: FilterElement) {
        let data = element.data()
        let locations = hashValues(data)
        queue.async(flags: .barrier) {
            for location in locations {
                self.bitmap.set(value: true, for: location)
            }
        }
    }
    
    /// determine whether the bloom filter contains this element
    /// - Parameter element: element
    /// - Returns: result
    func contains(_ element: FilterElement) -> Bool {
        let data = element.data()
        let hashes = hashValues(data)
        var result = true
        queue.sync {
            for hash in hashes where bitmap.get(for: hash) == false {
                result = false
            }
        }
        return result
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
