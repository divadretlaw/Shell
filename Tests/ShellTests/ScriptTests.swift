import XCTest
@testable import Shell

final class ScriptTests: XCTestCase {
    func testScript() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let output = try await script.capture()
        XCTAssertEqual("Hello\nWorld", output, trimming: .whitespacesAndNewlines)
    }
    
    func testFailingScript() async throws {
        let script = Script {
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
            let script = Script(shell: shell) {
                """
                echo "Hello";
                echo 'World';
                """
            }
            let output = try await script.capture()
            XCTAssertEqual("Hello\nWorld", output, trimming: .whitespacesAndNewlines)
        }
    }
    
    func testExpressibleByStringLiteral() async throws {
        let script: Script =
        """
        echo "Hello";
        echo 'World';
        """
        let output = try await script.capture()
        XCTAssertEqual("Hello\nWorld", output, trimming: .whitespacesAndNewlines)
    }
    
    func testPipe() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let rev = Command("rev")
        let task = script | rev
        let output = try await task.capture()
        XCTAssertEqual("olleH\ndlroW", output, trimming: .whitespacesAndNewlines)
    }
    
    func testRedirect() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let rev = Command("rev")
        let task = rev.redirected(from: script)
        let output = try await task.capture()
        XCTAssertEqual("olleH\ndlroW", output, trimming: .whitespacesAndNewlines)
    }
    
    func testMultiPipe() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let task = script | Command("rev") | Command("cat") | Command("rev")
        let output = try await task.capture()
        XCTAssertEqual("Hello\nWorld", output, trimming: .whitespacesAndNewlines)
    }
    
    func testMultiRedirection() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let task = Command("rev").redirected(from: Command("cat").redirected(from: Command("rev").redirected(from: script)))
        let output = try await task.capture()
        XCTAssertEqual("Hello\nWorld", output, trimming: .whitespacesAndNewlines)
    }
    
    func testPiped() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let rev = Command("rev")
        guard let task = try [script, rev].piped() else { return }
        let output = try await task.capture()
        XCTAssertEqual("olleH\ndlroW", output, trimming: .whitespacesAndNewlines)
    }
    
    func testScriptProgress() async throws {
        let script = Script {
            """
            echo "Hello";
            sleep 1;
            echo 'World';
            sleep 1;
            echo "Another Hello";
            sleep 1;
            echo 'Another World';
            """
        }
        
        try await script()
    }
    
    func testWrite() async throws {
        try await XCTTemporaryDirectory { directory in
            let file = directory.appending(path: "test.txt")
            let script = Script {
                """
                echo 'Hello' > \(file.path());
                """
            }
            
            try await script()
            let string = try String(contentsOf: file)
            XCTAssertEqual("Hello", string, trimming: .whitespacesAndNewlines)
        }
    }
}
