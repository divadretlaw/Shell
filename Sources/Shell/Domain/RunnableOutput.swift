//
//  RunnableOutput.swift
//  Shell
//
//  Created by David Walter on 10.09.24.
//

import Foundation

/// Shell output types
public enum RunnableOutput: Hashable, Equatable, Sendable {
    /// The ``Runnable`` wrote to `stdout`
    case output(Data)
    /// The ``Runnable`` wrote to `stderr`
    case error(Data)
}
