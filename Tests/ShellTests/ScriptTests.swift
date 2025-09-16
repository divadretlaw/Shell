import Testing
@testable import Shell

struct ScriptTests {
    @Test func script() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let output = try await script.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello\nWorld")
    }

    @Test func failingScript() async throws {
        let script = Script {
            """
            exit 1
            """
        }
        await #expect(throws: RunnableError.self) {
            try await script()
        }
    }

    @Test func shells() async throws {
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
            #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello\nWorld")
        }
    }

    @Test func expressibleByStringLiteral() async throws {
        let script: Script =
            """
            echo "Hello";
            echo 'World';
            """
        let output = try await script.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello\nWorld")
    }

    @Test func pipe() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let rev = Command("rev")
        let task = script | rev
        let output = try await task.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "olleH\ndlroW")
    }

    @Test func redirect() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let rev = Command("rev")
        let task = rev.redirected(from: script)
        let output = try await task.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "olleH\ndlroW")
    }

    @Test func multiPipe() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let task = script | Command("rev") | Command("cat") | Command("rev")
        let output = try await task.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello\nWorld")
    }

    @Test func multiRedirection() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let task = Command("rev").redirected(from: Command("cat").redirected(from: Command("rev").redirected(from: script)))
        let output = try await task.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello\nWorld")
    }

    @Test func piped() async throws {
        let script = Script {
            """
            echo "Hello";
            echo 'World';
            """
        }
        let rev = Command("rev")
        guard let task = try [script, rev].piped() else { return }
        let output = try await task.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "olleH\ndlroW")
    }

    @Test func scriptProgress() async throws {
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

    @Test func write() async throws {
        try await withTemporaryDirectory { directory in
            let file = directory.appending(path: "test.txt")
            let script = Script {
                """
                echo 'Hello' > \(file.path());
                """
            }

            try await script()
            let output = try String(contentsOf: file)
            #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello")
        }
    }
}
