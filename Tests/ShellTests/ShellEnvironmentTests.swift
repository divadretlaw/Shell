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
    
    func testExpand() {
        let environment = ["TEST": "1"]
        XCTAssertEqual(ShellEnvironment.expand(arguments: ["$TEST", "$OTHER"], environment: environment), ["1", ""])
        XCTAssertEqual(ShellEnvironment.expand(arguments: ["${TEST}", "${OTHER}"], environment: environment), ["1", ""])
        XCTAssertEqual(ShellEnvironment.expand(arguments: ["${TEST:-2}", "${OTHER:-3}"], environment: environment), ["1", "3"])
        
        XCTAssertEqual(ShellEnvironment.expand(arguments: ["$TEST,${OTHER:-3},${TEST:-2}"], environment: environment), ["1,3,1"])
    }
    
    func testExpandExpand() {
        let environment = ["TEST": "$OTHER", "OTHER": "1"]
        XCTAssertEqual(ShellEnvironment.expand(arguments: ["${OTHER_TEST:-$TEST}"], environment: environment), ["1"])
    }
}
