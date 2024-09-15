import XCTest
@testable import Shell

final class UnsafeScriptTests: XCTestCase {
    func testEcho() async throws {
        let script = UnsafeScript {
            """
            echo 'Hello';
            echo 'World';
            """
        }
        try await script()
    }
    
    func testScriptShells() async throws {
        for shell in Shell.allCases {
            guard await Command.isAvailable(shell.rawValue) else {
                print("Checking: \(shell) - not available. Skip.")
                continue
            }
            print("Checking: \(shell)")
            let script = UnsafeScript(shell: shell) {
                """
                echo 'Hello';
                echo 'World';
                """
            }
            try await script()
        }
    }
}
