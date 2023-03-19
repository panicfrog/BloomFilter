//
//  File.swift
//  
//
//  Created by mac studio on 2023/3/18.
//

import Foundation


func itod(i: Int) -> Data {
    var _i = i
    return withUnsafeBytes(of: &_i) { Data($0) }
}

public struct FaI {
    public let fp: Fingerprint
    public let i1: Int
    public let i2: Int
    
    private init(fp: Fingerprint, i1: Int, i2: Int) {
        self.fp = fp
        self.i1 = i1
        self.i2 = i2
    }
    
    init<T: Hashable>(data: T) {
        let (fpHash, indexHash) = getHash(data: data)
        let fpHashArr = itod(i: fpHash)
        var validFpHash = itod(i: 0)
        var n: Data.Element = 0
        var fp: Fingerprint = Fingerprint.empty()
        
        // increment every byte of the hash until we find one that is a valid fingerprint
        while true {
            for (i, v) in fpHashArr.enumerated() {
                validFpHash[i] = v + n
            }
            
            if let val = Fingerprint(data: validFpHash) {
                fp = val
                break
            }
            n += 1
        }
        let i1 = indexHash
        let i2 = getAltIndex(fp: fp, i: i1)
        self.init(fp: fp, i1: i1, i2: i2)
    }
    
    public func rendomIndex() -> Int {
        if Bool.random() {
            return i1
        } else {
            return i2
        }
    }
}

func getHash<T: Hashable>(data: T) -> (high: Int, low: Int) {
    let hash = data.hashValue
    // split 64bit hash value in the upper and the lower 32bit parts,
    // one used for the fingerprint, the other used for the indexes.
    let helfwise = MemoryLayout<Int>.size / 2 * 8
    var tem = 0xFFFFFFFF
    if helfwise == 16 {
        tem = 0xFFFF
    }
    return (hash >> helfwise, hash & tem)
}

public func getAltIndex(fp: Fingerprint, i: Int) -> Int {
    (i ^ getHash(data: fp.data).1)
}

