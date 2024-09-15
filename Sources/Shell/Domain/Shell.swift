//
//  Shell.swift
//  Shell
//
//  Created by David Walter on 14.09.24.
//

import Foundation

/// The known shells
public enum Shell: String, Identifiable, Equatable, Hashable, Sendable {
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
}
