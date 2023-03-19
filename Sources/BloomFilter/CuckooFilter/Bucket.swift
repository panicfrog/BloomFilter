//
//  Bucket.swift
//  
//
//  Created by mac studio on 2023/3/18.
//

import Foundation

let BUCKET_SLOT_COUNT: Int = 4
let EMPTY_FINGERPRINT_DATA = itod(i: 100)

public struct Fingerprint: Equatable {
    var data: Data

    init?(data: Data) {
        guard !data.isEmpty else { return nil }
        self.data = data
    }

    static func empty() -> Fingerprint {
        return Fingerprint(data: EMPTY_FINGERPRINT_DATA)!
    }

    var isEmpty: Bool {
        data == EMPTY_FINGERPRINT_DATA
    }
}

struct Bucket {
    var entries: [Fingerprint]

    init() {
        self.entries = [Fingerprint](repeating: Fingerprint.empty(), count: BUCKET_SLOT_COUNT)
    }

    /// Inserts the fingerprint into the buffer if the buffer is not full. This operation is O(1).
    @discardableResult
    mutating func insert(fp: Fingerprint) -> Bool {
        for (idx, entry) in entries.enumerated() {
            if entry.isEmpty {
                entries[idx] = fp
                return true
            }
        }
        return false
    }

    /// Deletes the given fingerprint from the bucket. This operation is O(1).
    @discardableResult
    mutating func delete(fp: Fingerprint) -> Bool {
        if let idx = entries.firstIndex(where: { $0 == fp }) {
            entries[idx] = Fingerprint.empty()
            return true
        }
        return false
    }

    /// Returns the index of the given fingerprint, if its found. O(1)
    func getFingerprintIndex(fp: Fingerprint) -> Int? {
        return entries.firstIndex(where: { $0 == fp })
    }

    /// Returns all current fingerprint data of the current buffer for storage.
    func getFingerprintData() -> [UInt8] {
        return entries.flatMap { $0.data }
    }

    /// Empties the bucket by setting each used entry to Fingerprint::empty(). Returns the number of entries that were modified.
    mutating func clear() {
        self = Bucket()
    }
}

extension Bucket: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Fingerprint...) {
        self.init()
        for (idx, element) in elements.enumerated() {
            entries[idx] = element
        }
    }
}
