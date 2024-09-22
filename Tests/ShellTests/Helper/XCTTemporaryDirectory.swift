import Foundation
import XCTest

func XCTTemporaryDirectory(
    path: String? = nil,
    fileManager: FileManager = .default,
    perform: (URL) async throws -> Void
) async throws {
    let directory = fileManager.temporaryDirectory.appending(path: path ?? UUID().uuidString)

    do {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try await perform(directory)
        try fileManager.removeItem(at: directory)
    } catch {
        try fileManager.removeItem(at: directory)
        throw error
    }
}
