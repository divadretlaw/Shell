//
//  UnsafeScript.swift
//  Shell
//
//  Created by David Walter on 14.09.24.
//

import Foundation
import SwiftSystem

public final class UnsafeScript: ExpressibleByStringLiteral {
    private let script: String
    
    // MARK: - init
    
    public convenience init(script: () -> String) {
        self.init(script())
    }
    
    public init(_ script: String) {
        self.script = script
    }
    
    // MARK: - ExpressibleByStringLiteral
    
    public convenience init(stringLiteral value: String) {
        self.init(value)
    }
    
    // MARK: -
    
    public func run() throws {
        swiftSystem(script)
    }
    
    public func callAsFunction() async throws {
        let terminationStatus = swiftSystem(script)
        if terminationStatus != 0 {
            throw ShellError.terminated(terminationStatus, stderr: nil)
        }
    }
}
