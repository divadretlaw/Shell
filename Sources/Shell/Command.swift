//
//  Command.swift
//  Shell
//
//  Created by David Walter on 10.09.24.
//

import Foundation

public final class Command: Runnable, ExpressibleByArrayLiteral {
    private let process: Process
    private let standardOutput: Pipe
    private let standardError: Pipe
    private let _caller: Lock<Runnable?>
    
    // MARK: - init
    
    public convenience init(
        _ arguments: String...,
        currentDirectoryURL: URL? = URL(filePath: FileManager.default.currentDirectoryPath),
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        self.init(
            arguments: arguments,
            currentDirectoryURL: currentDirectoryURL,
            environment: environment
        )
    }
    
    public convenience init(
        arguments: [String],
        currentDirectoryURL: URL? = URL(filePath: FileManager.default.currentDirectoryPath),
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        if let url = URL(systemPath: arguments.first, environment: environment) {
            self.init(url: url, arguments: Array(arguments.dropFirst()), currentDirectoryURL: currentDirectoryURL, environment: environment)
        } else {
            self.init(url: URL(filePath: "/usr/bin/env"), arguments: arguments, currentDirectoryURL: currentDirectoryURL, environment: environment)
        }
    }
    
    public init(
        url: URL,
        arguments: [String],
        currentDirectoryURL: URL? = URL(filePath: FileManager.default.currentDirectoryPath),
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        let process = Process()
        let stdout = Pipe()
        let stderr = Pipe()
        
        process.executableURL = url
        process.arguments = arguments
        process.currentDirectoryURL = currentDirectoryURL
        process.environment = environment
        process.standardOutput = stdout
        process.standardError = stderr
        
        self.process = process
        self.standardOutput = stdout
        self.standardError = stderr
        self._caller = nil
    }
    
    // MARK: - ExpressibleByArrayLiteral
    
    public convenience init(arrayLiteral elements: String...) {
        self.init(arguments: elements)
    }
    
    // MARK: - Runnable
    
    public var caller: Runnable? {
        _caller.wrappedValue
    }
    
    public var stdout: Pipe {
        standardOutput
    }
    
    public func redirected(from runner: Runnable) -> Runnable {
        _caller.wrappedValue = runner
        process.standardInput = runner.stdout
        return self
    }
    
    public func run() throws {
        if let caller {
            try caller.run()
        }
        try process.run()
    }
    
    public func callAsFunction() async throws {
        for try await output in stream() {
            switch output {
            case let .output(data):
                if let string = String(data: data, encoding: .utf8) {
                    fputs(string, Darwin.stdout)
                    fflush(Darwin.stdout)
                }
            case let .error(data):
                if let string = String(data: data, encoding: .utf8) {
                    fputs(string, Darwin.stderr)
                    fflush(Darwin.stderr)
                }
            }
        }
    }
    
    public func capture() async throws -> String {
        var results: [String] = []
        for try await output in stream() {
            switch output {
            case let .output(data):
                if let string = String(data: data, encoding: .utf8) {
                    fputs(string, Darwin.stdout)
                    results.append(string)
                    fflush(Darwin.stdout)
                }
            case let .error(data):
                if let string = String(data: data, encoding: .utf8) {
                    fputs(string, Darwin.stderr)
                    fflush(Darwin.stderr)
                }
            }
        }
        return results.joined()
    }
    
    public func stream() -> AsyncThrowingStream<ShellOutput, Error> {
        AsyncThrowingStream(ShellOutput.self, bufferingPolicy: .unbounded) { continuation in
            continuation.onTermination = { [process] termination in
                switch termination {
                case .cancelled:
                    if process.isRunning {
                        process.terminate()
                    }
                default:
                    break
                }
            }
            
            let error: Lock<[String]> = []
            
            standardOutput.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if !data.isEmpty {
                    continuation.yield(.output(data))
                }
            }
            
            standardError.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if !data.isEmpty, let output = String(data: data, encoding: .utf8) {
                    error.wrappedValue.append(output)
                }
            }
            
            do {
                try run()
                process.waitUntilExit()
                
                if let data = try standardOutput.fileHandleForReading.readToEnd(), !data.isEmpty {
                    continuation.yield(.output(data))
                }
                
                if let data = try standardError.fileHandleForReading.readToEnd(), !data.isEmpty {
                    continuation.yield(.error(data))
                    if let output = String(data: data, encoding: .utf8) {
                        error.wrappedValue.append(output)
                    }
                }
                
                switch process.terminationReason {
                case .exit:
                    if process.terminationStatus != 0 {
                        throw ShellError.terminated(process.terminationStatus, stderr: error.wrappedValue.joined())
                    }
                case .uncaughtSignal:
                    if process.terminationStatus != 0 {
                        throw ShellError.signalled(process.terminationStatus)
                    }
                @unknown default:
                    break
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}