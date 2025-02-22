//
//  Lock.swift
//  Shell
//
//  Created by David Walter on 14.09.24.
//

import Foundation
import os

@propertyWrapper
final class Lock<T>: @unchecked Sendable where T: Sendable {
    private let _value: OSAllocatedUnfairLock<T>
    
    init(_ value: T) {
        self._value = OSAllocatedUnfairLock(initialState: value)
    }
    
    var wrappedValue: T {
        get {
            _value.withLock {
                $0
            }
        }
        set {
            _value.withLock {
                $0 = newValue
            }
        }
    }
}

// MARK: - String

extension Lock: ExpressibleByStringLiteral where T: ExpressibleByStringLiteral {
    convenience init(stringLiteral value: T.StringLiteralType) {
        self.init(T.init(stringLiteral: value))
    }
}

extension Lock: ExpressibleByUnicodeScalarLiteral where T: ExpressibleByUnicodeScalarLiteral {
    convenience init(unicodeScalarLiteral value: T.UnicodeScalarLiteralType) {
        self.init(T.init(unicodeScalarLiteral: value))
    }
}

extension Lock: ExpressibleByExtendedGraphemeClusterLiteral where T: ExpressibleByExtendedGraphemeClusterLiteral {
    convenience init(extendedGraphemeClusterLiteral value: T.ExtendedGraphemeClusterLiteralType) {
        self.init(T.init(extendedGraphemeClusterLiteral: value))
    }
}

// MARK: - Optional

extension Lock: ExpressibleByNilLiteral where T: ExpressibleByNilLiteral {
    convenience init(nilLiteral: ()) {
        self.init(nil)
    }
}

// MARK: - Array

extension Lock: ExpressibleByArrayLiteral where T: ExpressibleByArrayLiteral {
    convenience init(arrayLiteral elements: T.ArrayLiteralElement...) {
        self.init(elements as! T)
    }
}

