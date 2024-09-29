//
//  Command.swift
//  Shell
//
//  Created by David Walter on 10.09.24.
//

import Foundation

/// A command to run
public final class Command: Runnable, ExpressibleByArrayLiteral {
    private let process: Process
    private let standardOutput: Pipe
    private let standardError: Pipe
    private let queue: DispatchQueue
    private let _caller: Lock<Runnable?>
    
    // MARK: - init
    
    /// Create a command to execute
    /// - Parameters:
    ///   - arguments: The command arguments. The first argument is the executable.
    ///   - currentDirectoryURL: The directory url the command should be executed in.
    ///   - environment: The environment the command should inherit.
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
    
    /// Create a command to execute
    /// - Parameters:
    ///   - arguments: The command arguments. The first argument is the executable.
    ///   - currentDirectoryURL: The directory url the command should be executed in.
    ///   - environment: The environment the command should inherit.
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
    
    /// Create a command to execute
    /// - Parameters:
    ///   - url: The url to the executable.
    ///   - arguments: The command arguments.
    ///   - currentDirectoryURL: The directory url the command should be executed in.
    ///   - environment: The environment the command should inherit.
    public init(
        url: URL,
        arguments: [String]? = nil,
        currentDirectoryURL: URL? = URL(filePath: FileManager.default.currentDirectoryPath),
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        let process = Process()
        let stdout = Pipe()
        let stderr = Pipe()
        
        process.executableURL = url
        process.arguments = arguments ?? []
        process.currentDirectoryURL = currentDirectoryURL
        process.environment = environment
        process.standardOutput = stdout
        process.standardError = stderr
        
        let name = url.lastPathComponent
        self.process = process
        self.standardOutput = stdout
        self.standardError = stderr
        self.queue = DispatchQueue(label: "at.davidwalter.shell.\(name)")
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
                try FileHandle.standardOutput.write(contentsOf: data)
            case let .error(data):
                try FileHandle.standardError.write(contentsOf: data)
            }
        }
    }
    
    public func capture() async throws -> String {
        var results: [String] = []
        for try await output in stream() {
            switch output {
            case let .output(data):
                if let string = String(data: data, encoding: .utf8) {
                    results.append(string)
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
    
    public func stream() -> AsyncThrowingStream<RunnableOutput, Error> {
        AsyncThrowingStream(RunnableOutput.self, bufferingPolicy: .unbounded) { continuation in
            queue.async { [weak self] in
                guard let self else {
                    return continuation.finish()
                }
                
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
                
                // if process.standardInput == nil {
                //     let stdin = Pipe()
                //     process.standardInput = stdin
                //     let fileHandle = FileHandle(fileDescriptor: STDIN_FILENO)
                //     fileHandle.readabilityHandler = { handle in
                //         let data = handle.availableData
                //         if !data.isEmpty {
                //             stdin.fileHandleForWriting.write(data)
                //         }
                //     }
                // }
                
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
                    
                    let terminationStatus = process.terminationStatus
                    switch process.terminationReason {
                    case .exit:
                        if terminationStatus != 0 {
                            throw RunnableError.terminated(terminationStatus, stderr: error.wrappedValue.joined())
                        }
                    case .uncaughtSignal:
                        if terminationStatus != 0 {
                            throw RunnableError.signalled(terminationStatus)
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
}
