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
}
