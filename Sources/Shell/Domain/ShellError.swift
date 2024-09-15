//
//  ShellError.swift
//  Shell
//
//  Created by David Walter on 10.09.24.
//

import Foundation

public enum ShellError: Error {
    case terminated(_ status: Int32, stderr: String?)
    case signalled(_ status: Int32)
}
