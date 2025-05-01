// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shell",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Shell",
            targets: ["Shell"]
        ),
        .library(
            name: "ShellStyle",
            targets: ["ShellStyle"]
        )
    ],
    targets: [
        .target(
            name: "Shell",
            dependencies: ["SwiftSystem"]
        ),
        .target( name: "ShellStyle"),
        .target(name: "SwiftSystem"),
        .testTarget(
            name: "ShellTests",
            dependencies: ["Shell"]
        ),
        .testTarget(
            name: "ShellStyleTests",
            dependencies: ["ShellStyle"]
        )
    ]
)
