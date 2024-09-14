//
//  ShellError.swift
//  Shell
//
//  Created by David Walter on 10.09.24.
//

import Foundation

public enum ShellError: Error {
    case terminated(Int32, stderr: String?)
    case signalled(Int32)
}
