//
//  CuckooFilter.swift
//  
//
//  Created by mac studio on 2023/3/18.
//

import Foundation

public enum CuckooError: Error {
    case NoEnoughSpace
}

public final class CuckooFilter {
    private(set) var buckets: [Bucket]
    private(set) var count: Int
    let MAX_BUCKET: Int = 500
    
    init(buckets: Int) {
        // TODO: 使用Builder模式的是需要考虑最佳size
        self.buckets = [Bucket](repeating: Bucket(), count: buckets)
        self.count = 0
    }
    
    public func add<T: Hashable>(_ data: T) -> Result<(), CuckooError> {
        let fai = FaI(data: data)
        if put(fp: fai.fp, at: fai.i1) || put(fp: fai.fp, at: fai.i2) {
            return .success(())
        }
        let _count = buckets.count
        var fp = fai.fp
        var index = fai.rendomIndex()
        
        for _ in 0..<MAX_BUCKET {
            let bucketIdx = index % _count
            // TODO: Int转Int32会有溢出的问题
            let idx = Int(arc4random_uniform(UInt32(BUCKET_SIZE)))
            let otherFp = buckets[bucketIdx].buffer[idx]
            buckets[bucketIdx].buffer[idx] = fp
            index = getAltIndex(fp: otherFp, i: index)
            if put(fp: otherFp, at: index) {
                return .success(())
            }
            fp = otherFp
        }
        
        return .failure(.NoEnoughSpace)
    }
    
    public func contains<T: Hashable>(_ data: T) -> Bool {
        let fai = FaI(data: data)
        let _count = buckets.count
        if buckets[fai.i1 % _count].getFingerprintIndex(fp: fai.fp) != nil
            || buckets[fai.i2 % _count].getFingerprintIndex(fp: fai.fp) != nil {
            return true
        }
        return false
    }
    
    private func put(fp: Fingerprint, at index: Int) -> Bool {
        let _count = self.buckets.count
        if buckets[index % _count].insert(fp: fp) {
            count += 1
            return true
        } else {
            return false
        }
    }
}
