//
//  DefaultColor.swift
//  ShellStyle
//
//  Created by David Walter on 23.02.25.
//

import Foundation

/// Default terminal color
public enum DefaultColor: CaseIterable, Sendable {
    /// Black
    ///
    /// > Note: The actual color depends on the terminal emulator in use
    case black
    /// Red
    ///
    /// > Note: The actual color depends on the terminal emulator in use
    case red
    /// Green
    ///
    /// > Note: The actual color depends on the terminal emulator in use
    case green
    /// Yellow
    ///
    /// > Note: The actual color depends on the terminal emulator in use
    case yellow
    /// Blue
    ///
    /// > Note: The actual color depends on the terminal emulator in use
    case blue
    /// Magenta
    ///
    /// > Note: The actual color depends on the terminal emulator in use
    case magenta
    ///Cyan
    ///
    /// > Note: The actual color depends on the terminal emulator in use
    case cyan
    /// White
    ///
    /// > Note: The actual color depends on the terminal emulator in use
    case white
}
