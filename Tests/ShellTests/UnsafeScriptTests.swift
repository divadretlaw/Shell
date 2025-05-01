import Testing
@testable import Shell

struct UnsafeScriptTests {
    @Test
    func unsafeScript() async throws {
        let script = UnsafeScript {
            """
            echo "Hello";
            echo 'World';
            """
        }
        try await script()
    }

    @Test
    func failingScript() async throws {
        let script = UnsafeScript {
            """
            exit 1
            """
        }
        await #expect(throws: RunnableError.self) {
            try await script()
        }
    }

    @Test
    func shells() async throws {
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

    @Test
    func expressibleByStringLiteral() async throws {
        let script: UnsafeScript =
            """
            echo 'Hello';
            echo 'World';
            """
        try await script()
    }
}
