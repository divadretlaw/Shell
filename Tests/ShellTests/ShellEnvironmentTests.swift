import Foundation
import Testing
@testable import Shell

struct ShellEnvironmentTests {
    @Test func defaultEnvironment() {
        #expect(!ShellEnvironment.shared.environment.isEmpty)
    }

    @Test func setEnvironment() {
        ShellEnvironment.shared.set(environment: ["TEST": "1"])
        #expect(ShellEnvironment.shared.environment["TEST"] == "1")
    }
}
