import XCTest
@testable import Shell

final class CommandTests: XCTestCase {
    func testCommand() async throws {
        let command = Command("echo", "Hello World")
        let output = try await command.capture()
        XCTAssertEqual("Hello World", output, trimming: .whitespacesAndNewlines)
    }
    
    func testFailingCommand() async throws {
        let command = Command("false")
        do {
            try await command()
            XCTFail("Expected failure")
        } catch let error as RunnableError {
            switch error {
            case let .terminated(code, _):
                XCTAssertEqual(code, 1)
            default:
                XCTFail(error.localizedDescription)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testUnavailableCommand() async throws {
        let command = Command("someUnavailableCommand")
        do {
            try await command()
            XCTFail("Expected failure")
        } catch let error as RunnableError {
            switch error {
            case let .terminated(code, _):
                XCTAssertEqual(code, 127)
            default:
                XCTFail(error.localizedDescription)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    func testCommands() async throws {
        let directory = URL(filePath: #filePath).deletingLastPathComponent()
        
        let ls = Command("ls", currentDirectoryURL: directory)
        let cat = Command(url: URL(filePath: "/bin/cat"))
        let grep = Command(url: URL(filePath: "/usr/bin/grep"), arguments: ["CommandTests.swift"])
        
        let task = ls | cat | grep
        
        let output = try await task.capture()
        XCTAssertEqual("CommandTests.swift", output, trimming: .whitespacesAndNewlines)
    }
    
    func testExpressibleByArrayLiteral() async throws {
        let run: Command = ["echo", "Hello World"]
        let output = try await run.capture()
        XCTAssertEqual("Hello World", output, trimming: .whitespacesAndNewlines)
    }
    
    func testPipe() async throws {
        let echo = Command("echo", "Hello World")
        let cat = Command("rev")
        let task = echo | cat
        let output = try await task.capture()
        XCTAssertEqual("dlroW olleH", output, trimming: .whitespacesAndNewlines)
    }
    
    func testRedirect() async throws {
        let echo = Command("echo", "Hello World")
        let cat = Command("rev")
        let task = cat.redirected(from: echo)
        let output = try await task.capture()
        XCTAssertEqual("dlroW olleH", output, trimming: .whitespacesAndNewlines)
    }
    
    func testMultiPipe() async throws {
        let echo = Command("echo", "Hello World")
        let task = echo | Command("rev") | Command("cat") | Command("rev")
        let output = try await task.capture()
        XCTAssertEqual("Hello World", output, trimming: .whitespacesAndNewlines)
    }
    
    func testMultiRedirection() async throws {
        let echo = Command("echo", "Hello World")
        let task = Command("rev").redirected(from: Command("cat").redirected(from: Command("rev").redirected(from: echo)))
        let output = try await task.capture()
        XCTAssertEqual("Hello World", output, trimming: .whitespacesAndNewlines)
    }
    
    func testPiped() async throws {
        let echo = Command("echo", "Hello World")
        let cat = Command("rev")
        guard let task = try [echo, cat].piped() else { return }
        let output = try await task.capture()
        XCTAssertEqual("dlroW olleH", output, trimming: .whitespacesAndNewlines)
    }
    
    func testIsAvailable() async throws {
        let echo = await Command.isAvailable("cat")
        XCTAssertTrue(echo)
        let someUnavailableCommand = await Command.isAvailable("someUnavailableCommand")
        XCTAssertFalse(someUnavailableCommand)
    }
}
