//
//  Lock.swift
//  Shell
//
//  Created by David Walter on 14.09.24.
//

import Foundation

@propertyWrapper
final class Lock<T>: @unchecked Sendable where T: Sendable {
    private var _value: T
    private let lock: NSLocking
    
    init(_ value: T, lock: NSLocking = NSLock()) {
        self._value = value
        self.lock = lock
    }
    
    var wrappedValue: T {
        get {
            lock.withLock {
                _value
            }
        }
        set {
            lock.withLock {
                _value = newValue
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

