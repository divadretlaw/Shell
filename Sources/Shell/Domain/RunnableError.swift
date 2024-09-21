//
//  RunnableError.swift
//  Shell
//
//  Created by David Walter on 10.09.24.
//

import Foundation

/// Shell related errors
public enum RunnableError: Error, CustomStringConvertible {
    /// The ``Runnable`` terminated
    case terminated(_ status: Int32, stderr: String?)
    /// The ``Runnable`` was signalled
    case signalled(_ status: Int32)
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        switch self {
        case let .terminated(status, _):
            return "The command terminated with: \(status)"
        case let .signalled(status):
            return "The command terminated after receiving a signal with: \(status)"
        }
    }
}
