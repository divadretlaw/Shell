import Foundation
import Testing
@testable import Shell

struct CommandTests {
    @Test func commandWithoutArguments() async throws {
        let command = Command("uptime")
        let output = try await command.capture()
        #expect(output.contains("load average"))
    }

    @Test func commandWithArguments() async throws {
        let command = Command("echo", "Hello World")
        let output = try await command.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello World")
    }

    @Test func commandWithEnvironment() async throws {
        let command = Command("echo", "$TEST", environment: ["TEST": "Hello World"])
        let output = try await command.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello World")
    }

    @Test func failingCommand() async throws {
        let command = Command("cd", "notADirectory")
        await #expect(throws: RunnableError.self) {
            try await command()
        }
    }

    @Test func unavailableCommand() async throws {
        let command = Command("someUnavailableCommand")
        do {
            try await command()
            Issue.record("Expected failure")
        } catch let error as RunnableError {
            switch error {
            case let .terminated(code, _):
                #expect(code == 127)
            default:
                Issue.record(error)
            }
        } catch {
            Issue.record(error)
        }
    }

    @Test func commands() async throws {
        let directory = URL(filePath: #filePath).deletingLastPathComponent()

        let ls = Command("ls", currentDirectoryURL: directory)
        let cat = Command(url: URL(filePath: "/bin/cat"))
        let grep = Command(url: URL(filePath: "/usr/bin/grep"), arguments: ["CommandTests.swift"])

        let task = ls | cat | grep

        let output = try await task.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "CommandTests.swift")
    }

    @Test func expressibleByArrayLiteral() async throws {
        let run: Command = ["echo", "Hello World"]
        let output = try await run.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello World")
    }

    @Test func pipe() async throws {
        let echo = Command("echo", "Hello World")
        let rev = Command("rev")
        let task = echo | rev
        let output = try await task.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "dlroW olleH")
    }

    @Test func redirect() async throws {
        let echo = Command("echo", "Hello World")
        let rev = Command("rev")
        let task = rev.redirected(from: echo)
        let output = try await task.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "dlroW olleH")
    }

    @Test func multiPipe() async throws {
        let echo = Command("echo", "Hello World")
        let task = echo | Command("rev") | Command("cat") | Command("rev")
        let output = try await task.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello World")
    }

    @Test func multiRedirection() async throws {
        let echo = Command("echo", "Hello World")
        let task = Command("rev").redirected(from: Command("cat").redirected(from: Command("rev").redirected(from: echo)))
        let output = try await task.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello World")
    }

    @Test func piped() async throws {
        let echo = Command("echo", "Hello World")
        let rev = Command("rev")
        guard let task = try [echo, rev].piped() else { return }
        let output = try await task.capture()
        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "dlroW olleH")
    }

    @Test func isAvailable() async throws {
        let cat = await Command.isAvailable("cat")
        #expect(cat)
        let someUnavailableCommand = await Command.isAvailable("someUnavailableCommand")
        #expect(!someUnavailableCommand)
    }
}
