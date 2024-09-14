import XCTest
@testable import Shell

final class CommandTests: XCTestCase {
    func testEcho() async throws {
        let run = Command("echo", "Hello World")
        let output = try await run.capture()
        XCTAssertEqual("Hello World", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testEchoExpressibleByArrayLiteral() async throws {
        let run: Command = ["echo", "Hello World"]
        let output = try await run.capture()
        XCTAssertEqual("Hello World", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testPipe() async throws {
        let echo = Command("echo", "Hello World")
        let cat = Command("cat")
        let task = echo | cat
        let output = try await task.capture()
        XCTAssertEqual("Hello World", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testRedirect() async throws {
        let echo = Command("echo", "Hello World")
        let cat = Command("cat")
        let task = cat.redirected(from: echo)
        let output = try await task.capture()
        XCTAssertEqual("Hello World", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testMultiPipe() async throws {
        let echo = Command("echo", "Hello World")
        let task = echo | Command("cat") | Command("cat") | Command("cat")
        let output = try await task.capture()
        XCTAssertEqual("Hello World", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testMultiRedirection() async throws {
        let echo = Command("echo", "Hello World")
        let task = Command("cat").redirected(from: Command("cat").redirected(from: Command("cat").redirected(from: echo)))
        let output = try await task.capture()
        XCTAssertEqual("Hello World", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testPiped() async throws {
        let echo = Command("echo", "Hello World")
        let cat = Command("cat")
        guard let task = try [echo, cat].piped() else { return }
        let output = try await task.capture()
        XCTAssertEqual("Hello World", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
