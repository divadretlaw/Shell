//
//  URL+Extensions.swift
//  Run
//
//  Created by David Walter on 14.09.24.
//

import Foundation

extension URL {
    public init?(systemPath item: String?, environment: [String: String] = ProcessInfo.processInfo.environment) {
        if let path = environment["PATH"], let url = URL._systemPath(item: item, path: path) {
            self = url
        } else {
            return nil
        }
    }
    
    private static func _systemPath(item: String?, path: String) -> URL? {
        guard let item else { return nil }
        
        for directory in path.split(separator: ":") {
            let url = URL(filePath: String(directory), directoryHint: .isDirectory).appending(path: item)
            if FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) {
                return url
            }
        }
        
        return nil
    }
}
