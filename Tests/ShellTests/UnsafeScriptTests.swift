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
    
    func testEchoBash() async throws {
        let script = UnsafeScript(shell: .bash) {
            """
            echo 'Hello';
            echo 'World';
            """
        }
        try await script()
    }
    
    func testEchoZsh() async throws {
        let script = UnsafeScript(shell: .zsh) {
            """
            echo 'Hello';
            echo 'World';
            """
        }
        try await script()
    }
    
    func testEchoSh() async throws {
        let script = UnsafeScript(shell: .sh) {
            """
            echo 'Hello';
            echo 'World';
            """
        }
        try await script()
    }
}
