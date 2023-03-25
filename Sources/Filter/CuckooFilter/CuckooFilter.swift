//
//  CuckooFilter.swift
//
//  implement cuckoo filter from https://www.cs.cmu.edu/~dga/papers/cuckoo-conext2014.pdf
//
//  Created by mac studio on 2023/3/18.
//

import Foundation



public enum CuckooError: Error {
    case NoEnoughSpace
}


/*
 ```
 Algorithm 1: Insert(x)
 f = fingerprint(x);
 i1 = hash(x);
 i2 = i1 ^ hash(f);
 if bucket[i1] or bucket[i2] has an empty entry then
    add f to the bucket;
    return Done;
 // must relocate existing items;
 i = randonmly pick i1 or i2;
 for n = 0; n < MaxNumKicks; n++ do
    randomly select an entry e form bucket[i];
    swap f and fingerprint stored in entry e;
    i = i ^ hash(f);
    if bucket[i] has an empty ectry then
        add f to bucket[i];
        return Done;
 // Hashtable is considered full;
 return Failure
 
 
 Algorithm 2: Lookup(x)
 f = fingerprint(x);
 i1 = hash(x);
 i2 = i1 ^ hash(f);
 if bucket[i1] or bucket[i2] has f then
    return True;
 return Flase;
 
 
 Algorithm 3: Delete(x)
 f = fingerprint(x);
 i1 = hash(x);
 i2 = i ^ hash(f);
 if bucket[i1] or bucket[i2] has f then
    remove a copy of f from this bucket;
    return True;
 return False;
 
 ```
 */

public final class CuckooFilter {
    private(set) var buckets: [Bucket]
    private(set) var count: Int
    let MAX_NUM_KICKS: Int = 500
    
    init(buckets: Int = 1 << 20 - 1) {
        // TODO: 使用Builder模式的是需要考虑最佳size
        self.buckets = [Bucket](repeating: Bucket(), count: buckets)
        self.count = 0
    }
    
    /// add element to cuckoo filter
    /// - Parameter data: data
    /// - Returns: true if add success, false if add failed
    public func add<T: Hashable>(_ data: T) -> Result<(), CuckooError> {
        let fai = FaI(data: data)
        if put(fp: fai.fp, at: fai.i1) || put(fp: fai.fp, at: fai.i2) {
            return .success(())
        }
        let _count = buckets.count
        var fp = fai.fp
        var index = fai.rendomIndex()
        
        for _ in 0..<MAX_NUM_KICKS {
            let bucketIdx = index % _count
            // TODO: Int转Int32会有溢出的问题
            let entryIdx = Int(arc4random_uniform(UInt32(BUCKET_SLOT_COUNT)))
            let otherFp = buckets[bucketIdx].entries[entryIdx]
            buckets[bucketIdx].entries[entryIdx] = fp
            index = getAltIndex(fp: otherFp, i: index)
            if put(fp: otherFp, at: index) {
                return .success(())
            }
            fp = otherFp
        }
        return .failure(.NoEnoughSpace)
    }
    
    /// if element added to cuckoo filter
    /// - Parameter data: data
    /// - Returns: true if added, false if not
    public func contains<T: Hashable>(_ data: T) -> Bool {
        let fai = FaI(data: data)
        let _count = buckets.count
        if buckets[fai.i1 % _count].getFingerprintIndex(fp: fai.fp) != nil
            || buckets[fai.i2 % _count].getFingerprintIndex(fp: fai.fp) != nil {
            return true
        } else {
            return false
        }
    }
    
    /// delete element from filter
    /// - Parameter data: data
    /// - Returns: true if delete success, false if delete failed
    public func delete<T: Hashable>(data: T) -> Bool {
        let fai = FaI(data: data)
        let result1 = remove(fp: fai.fp, from: fai.i1)
        let result2 = remove(fp: fai.fp, from: fai.i2)
        return  result1 || result2
    }
    
    private func put(fp: Fingerprint, at index: Int) -> Bool {
        let _count = buckets.count
        if buckets[index % _count].insert(fp: fp) {
            count += 1
            return true
        } else {
            return false
        }
    }
    
    private func remove(fp: Fingerprint, from index: Int) -> Bool {
        let _count = buckets.count
        if buckets[index % _count].delete(fp: fp) {
            count -= 1
            return true
        } else {
            return false
        }
    }
}
