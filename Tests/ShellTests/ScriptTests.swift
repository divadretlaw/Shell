import XCTest
@testable import Shell

final class ScriptTests: XCTestCase {
    func testEchoScript() async throws {
        let script = Script {
            """
            echo 'Hello';
            echo 'World';
            """
        }
        let output = try await script.capture()
        XCTAssertEqual("Hello\nWorld", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testEchoScriptExpressibleByStringLiteral() async throws {
        let script: Script =
        """
        echo 'Hello';
        echo 'World';
        """
        let output = try await script.capture()
        XCTAssertEqual("Hello\nWorld", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testPipe() async throws {
        let script = Script {
            """
            echo 'Hello';
            echo 'World';
            """
        }
        let task = script | Command("cat")
        let output = try await task.capture()
        XCTAssertEqual("Hello\nWorld", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testRedirect() async throws {
        let script = Script {
            """
            echo 'Hello';
            echo 'World';
            """
        }
        let cat = Command("cat")
        let task = cat.redirected(from: script)
        let output = try await task.capture()
        XCTAssertEqual("Hello\nWorld", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
