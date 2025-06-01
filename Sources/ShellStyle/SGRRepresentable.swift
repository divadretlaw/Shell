//
//  SGRRepresentable.swift
//  ShellStyle
//
//  Created by David Walter on 23.02.25.
//

import Foundation

protocol SGRRepresentable: Sendable {
    var sgr: [UInt8] { get }
}

extension Array: SGRRepresentable where Element == UInt8 {
    var sgr: [UInt8] {
        self
    }
}

extension Set: SGRRepresentable where Element: SGRRepresentable {
    var sgr: [UInt8] {
        flatMap { $0.sgr }
    }
}
