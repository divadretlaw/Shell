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
    
    func testEchoScriptBash() async throws {
        let script = Script(shell: .bash) {
            """
            echo 'Hello';
            echo 'World';
            """
        }
        let output = try await script.capture()
        XCTAssertEqual("Hello\nWorld", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testEchoScriptZs() async throws {
        let script = Script(shell: .zsh) {
            """
            echo 'Hello';
            echo 'World';
            """
        }
        let output = try await script.capture()
        XCTAssertEqual("Hello\nWorld", output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testEchoScriptSh() async throws {
        let script = Script(shell: .sh) {
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
        let task = script | Command("rev") | Command("rev")
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
    
    func testProgressScript() async throws {
        let script = Script {
            """
            echo 'Hello';
            sleep 1;
            echo 'World';
            sleep 1;
            echo 'Another Hello';
            sleep 1;
            echo 'Another World';
            """
        }
        
        try await script()
    }
}
