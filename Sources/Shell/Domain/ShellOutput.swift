//
//  ShellOutput.swift
//  Shell
//
//  Created by David Walter on 10.09.24.
//

import Foundation

public enum ShellOutput: Hashable, Equatable, Sendable {
    /// The process wrote to `stdout`
    case output(Data)
    /// The process wrote to `stderr`
    case error(Data)
}
