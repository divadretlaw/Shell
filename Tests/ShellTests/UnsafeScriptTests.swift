import XCTest
@testable import Shell

final class UnsafeScriptTests: XCTestCase {
    func testEcho() async throws {
        let script = UnsafeScript("echo 'Hello World'")
        try await script()
    }
}
