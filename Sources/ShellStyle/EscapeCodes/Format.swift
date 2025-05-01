//
//  Format.swift
//  ShellStyle
//
//  Created by David Walter on 23.02.25.
//

import Foundation

public enum Format: UInt8, CaseIterable, Sendable, SGRRepresentable {
    case normal = 0
    case bold = 1
    case faint = 2
    case italic = 3
    case underline = 4
    case slowBlink = 5
    case rapidBlink = 6
    case invert = 7
    case concealed = 8
    case crossedOut = 9
    case doubleUnderline = 21

    // MARK: - SGRRepresentable

    var sgr: [UInt8] {
        [rawValue]
    }
}

public enum InverseFormat: UInt8, CaseIterable, Sendable, SGRRepresentable {
    case notBold = 22
    case notItalic = 23
    case notUnderline = 24
    case notBlinking = 25
    case notConcealed = 28
    case notCrossedOut = 29

    static let notFaint = InverseFormat.notBold

    // MARK: - SGRRepresentable

    var sgr: [UInt8] {
        [rawValue]
    }
}
