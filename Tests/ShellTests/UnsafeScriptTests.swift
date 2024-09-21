import XCTest
@testable import Shell

final class UnsafeScriptTests: XCTestCase {
    func testUnsafeScript() async throws {
        let script = UnsafeScript {
            """
            echo "Hello";
            echo 'World';
            """
        }
        try await script()
    }
    
    func testShells() async throws {
        for shell in Shell.allCases {
            guard await Command.isAvailable(shell.rawValue) else {
                print("Checking: \(shell) - not available. Skip.")
                continue
            }
            print("Checking: \(shell)")
            let script = UnsafeScript(shell: shell) {
                """
                echo "Hello";
                echo 'World';
                """
            }
            try await script()
        }
    }
    
    func testExpressibleByStringLiteral() async throws {
        let script: UnsafeScript =
        """
        echo 'Hello';
        echo 'World';
        """
        try await script()
    }
}
