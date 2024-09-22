import Foundation
import XCTest

func XCTAssertEqual(
    _ expression1: @autoclosure () throws -> String,
    _ expression2: @autoclosure () throws -> String,
    trimming characters: CharacterSet,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    try XCTAssertEqual(
        expression1().trimmingCharacters(in: characters),
        expression2().trimmingCharacters(in: characters),
        message(),
        file: file,
        line: line
    )
}
