//
//  ShellError.swift
//  Shell
//
//  Created by David Walter on 10.09.24.
//

import Foundation

/// Shell related errors
public enum ShellError: Error {
    /// The ``Runnable`` terminated
    case terminated(_ status: Int32, stderr: String?)
    /// The ``Runnable`` was signalled
    case signalled(_ status: Int32)
}
