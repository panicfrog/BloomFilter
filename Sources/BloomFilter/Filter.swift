//
//  Filter.swift
//  
//
//  Created by mac studio on 2023/3/18.
//
import Foundation

public protocol FilterElement {
    func data() -> Data
}

extension String: FilterElement {
    public func data() -> Data {
        data(using: .utf8)!
    }
}

extension Data: FilterElement {
    public func data() -> Data {
        self
    }
}

public protocol Filter {
    func add(_ element: FilterElement)
    func contains(_ element: FilterElement) -> Bool
}
