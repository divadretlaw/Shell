//
//  Shell.swift
//  Shell
//
//  Created by David Walter on 14.09.24.
//

import Foundation

/// The known shells
public enum Shell: String, CaseIterable, Identifiable, Equatable, Hashable, Sendable, CustomStringConvertible {
    case sh = "sh"
    case bash = "bash"
    case csh = "csh"
    case dash = "dash"
    case fish = "fish"
    case tcsh = "tcsh"
    case zsh = "zsh"
    
    // MARK: - Identifiable
    
    public var id: String {
        rawValue
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        switch self {
        case .sh:
            "Bourne shell"
        case .bash:
            "Bash"
        case .csh:
            "C Shell"
        case .dash:
            "Debian Almquist shell"
        case .fish:
            "Fish"
        case .tcsh:
            "TENEX C Shell"
        case .zsh:
            "Z shell"
        }
    }
}
