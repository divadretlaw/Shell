//
//  Font.swift
//  ShellStyle
//
//  Created by David Walter on 23.02.25.
//

import Foundation

public enum Font: UInt8, CaseIterable, Sendable, SGRRepresentable {
    case primary = 10
    case alternative1 = 11
    case alternative2 = 12
    case alternative3 = 13
    case alternative4 = 14
    case alternative5 = 15
    case alternative6 = 16
    case alternative7 = 17
    case alternative8 = 18
    case alternative9 = 19
    case fraktur = 20

    var sgr: [UInt8] {
        [rawValue]
    }
}
