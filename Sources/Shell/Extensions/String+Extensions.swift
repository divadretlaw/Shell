//
//  String+Extensions.swift
//  Shell
//
//  Created by David Walter on 22.02.25.
//

import Foundation

extension String {
    func expand(with environment: [String: String]) -> String {
        do {
            var result = self
            
            for match in matches(of: try Regex("\\${\\w+:-.*?}")) {
                let variable = self[match.range]
                let keyContent = String(variable.dropFirst(2).dropLast())
                let parts = keyContent.split(separator: ":-", maxSplits: 1, omittingEmptySubsequences: false)
                if let key = parts.first, let value = environment[String(key)] {
                    result = result.replacingOccurrences(of: variable, with: value.expand(with: environment))
                } else if let fallback = parts.last {
                    result = result.replacingOccurrences(of: variable, with: String(fallback).expand(with: environment))
                } else {
                    result = result.replacingOccurrences(of: variable, with: "")
                }
            }
            
            for match in matches(of: try Regex("\\${\\w+}")) {
                let variable = self[match.range]
                let key = variable.dropFirst(2).dropLast()
                if let value = environment[String(key)] {
                    result = result.replacingOccurrences(of: variable, with: value.expand(with: environment))
                } else {
                    result = result.replacingOccurrences(of: variable, with: "")
                }
            }
            
            for match in matches(of:  try Regex("\\$\\w+")) {
                let variable = self[match.range]
                let key = variable.dropFirst()
                if let value = environment[String(key)] {
                    result = result.replacingOccurrences(of: variable, with: value.expand(with: environment))
                } else {
                    result = result.replacingOccurrences(of: variable, with: "")
                }
            }
            
            return result
        } catch {
            return self
        }
    }
}
