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
    
    func testFailingScript() async throws {
        let script = UnsafeScript {
            """
            exit 1
            """
        }
        await XCTAssertThrowsError(try await script()) { error in
            switch error {
            case let RunnableError.terminated(code, _):
                XCTAssertEqual(code, 1)
            default:
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testShells() async throws {
        for shell in Shell.allCases {
            guard await shell.isAvailable else {
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
