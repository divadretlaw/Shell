//
//  Command+isAvailable.swift
//  Shell
//
//  Created by David Walter on 15.09.24.
//

import Foundation

extension Command {
    /// Checks if a given command is available
    /// - Parameters:
    ///   - command: The command to check.
    ///   - environment: The environment the check should inherit.
    /// - Returns: Whether the command is available
    public static func isAvailable(
        _ command: String,
        environment: [String: String] = ShellEnvironment.shared.environment
    ) async -> Bool {
        guard let value = command.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return false
        }
        
        do {
            let command = Command("command", "-v", value, environment: environment)
            _ = try await command.capture()
            return true
        } catch {
            return false
        }
    }
}
