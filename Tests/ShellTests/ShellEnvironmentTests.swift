import XCTest
@testable import Shell

final class ShellEnvironmentTests: XCTestCase {
    func testDefault() {
        XCTAssertEqual(ShellEnvironment.shared.environment, ProcessInfo.processInfo.environment)
    }
    
    func testSet() {
        ShellEnvironment.shared.set(environment: ["TEST": "1"])
        XCTAssertNotEqual(ShellEnvironment.shared.environment, ProcessInfo.processInfo.environment)
        XCTAssertEqual(ShellEnvironment.shared.environment["TEST"], "1")
    }
}

