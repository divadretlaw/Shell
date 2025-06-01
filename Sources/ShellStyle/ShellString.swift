//
//  ShellString.swift
//  ShellStyle
//
//  Created by David Walter on 23.02.25.
//

import Foundation

struct ShellString {
    // Format & Inverse Format
    private var format: Set<Format>
    private var inverseFormat: Set<InverseFormat>

    // Font
    private var font: Font?

    // Colors
    private var foregroundColor: Color?
    private var backgroundColor: Color?
    private var underlineColor: Color?

    // Others
    private var other: [UInt8]

    private let rawValue: String

    init(rawValue: Substring) {
        self.format = []
        self.inverseFormat = []
        self.font = nil
        self.foregroundColor = nil
        self.backgroundColor = nil
        self.underlineColor = nil
        self.other = []
        self.rawValue = String(rawValue)
    }

    static func parse(_ string: String) -> [ShellString] {
        let parts = string.split(separator: "\u{001B}[0m")
        return parts.map { ShellString($0) }
    }

    private init(_ string: Substring) {
        guard string.hasPrefix("\u{001B}[") else {
            self.init(rawValue: string)
            return
        }

        do {
            let regex = try Regex("\u{001B}\\[.*?m")

            if let prefix = string.prefixMatch(of: regex) {
                var format: Set<Format> = []
                var inverseFormat: Set<InverseFormat> = []
                var font: Font?
                var foregroundColor: Color?
                var backgroundColor: Color?
                var underlineColor: Color?
                var other: [UInt8] = []

                let variable = string[prefix.range]
                let styles = variable.dropFirst(2).dropLast().split(separator: ";")
                    .map(String.init)
                    .compactMap(UInt8.init)

                var iterator = styles.makeIterator()

                while let code = iterator.next() {
                    switch code {
                    case 10,      // Default font
                         11...19, // Alternative font n
                         20:      // Fraktur
                        if let value = Font(rawValue: code) {
                            font = value
                        }
                    case 30...37,   // Foreground colors
                         38,        // 8/24 bit foreground color
                         39,        // Default foreground color
                         40...47,   // Background colors
                         48,        // 8/24 bit background color
                         49,        // Default background color
                         58,        // 8/24 bit underline color
                         90...97,   // Bright foreground colors
                         100...107: // Bright background colors
                        if let value = Color(rawValue: code, iterator: &iterator) {
                            switch value.element {
                            case .foreground:
                                foregroundColor = value
                            case .background:
                                backgroundColor = value
                            case .underline:
                                underlineColor = value
                            default:
                                continue
                            }
                        }
                    default:
                        if let value = Format(rawValue: code) {
                            format.insert(value)
                        }
                        if let value = InverseFormat(rawValue: code) {
                            inverseFormat.insert(value)
                        }
                        other.append(code)
                    }
                }

                let rawValue =
                    if string.hasSuffix("\u{001B}[0m") {
                        string.dropFirst(variable.count).dropLast(4)
                    } else {
                        string.dropFirst(variable.count)
                    }

                self = ShellString(rawValue: rawValue)
                    .format(format)
                    .inverseFormat(inverseFormat)
                    .font(font)
                    .foregroundColor(foregroundColor)
                    .backgroundColor(backgroundColor)
                    .underlineColor(underlineColor)
                    .other(other)
            } else {
                self.init(rawValue: string)
            }
        } catch {
            self.init(rawValue: string)
        }
    }

    // MARK: - Render

    private var codes: [UInt8] {
        let codes: [SGRRepresentable?] = [
            format, inverseFormat, // Basic format
            font, // Fonts
            foregroundColor, backgroundColor, underlineColor, // Colors
            other // Everything else
        ]
        return codes
            .compactMap { $0 }
            .flatMap { $0.sgr }
    }

    func render() -> String {
        "\u{001B}[\(codes.map(\.description).joined(separator: ";"))m\(rawValue)\u{001B}[0m"
    }

    // MARK: - Modifier

    fileprivate func other(_ other: [UInt8]) -> Self {
        var string = self
        string.other = other
        return string
    }

    func format(_ values: Format..., overwrite: Bool = false) -> Self {
        var string = self
        if overwrite {
            string.format = Set(values)
        } else {
            string.format = string.format.union(values)
        }
        return string
    }

    func format(_ values: Set<Format>, overwrite: Bool = false) -> Self {
        var string = self
        if overwrite {
            string.format = values
        } else {
            string.format = string.format.union(values)
        }
        return string
    }

    func inverseFormat(_ values: InverseFormat..., overwrite: Bool = false) -> Self {
        var string = self
        if overwrite {
            string.inverseFormat = Set(values)
        } else {
            string.inverseFormat = string.inverseFormat.union(values)
        }
        return string
    }

    func inverseFormat(_ values: Set<InverseFormat>, overwrite: Bool = false) -> Self {
        var string = self
        if overwrite {
            string.inverseFormat = values
        } else {
            string.inverseFormat = string.inverseFormat.union(values)
        }
        return string
    }

    func font(_ value: Font?) -> Self {
        var string = self
        string.font = value
        return string
    }

    func foregroundColor(_ value: Color?, overwrite: Bool = false) -> Self {
        var string = self
        guard string.foregroundColor == nil || overwrite else { return self }
        string.foregroundColor = value
        return string
    }

    func backgroundColor(_ value: Color?, overwrite: Bool = false) -> Self {
        var string = self
        guard string.backgroundColor == nil || overwrite else { return self }
        string.backgroundColor = value
        return string
    }

    func underlineColor(_ value: Color?, overwrite: Bool = false) -> Self {
        var string = self
        guard string.underlineColor == nil || overwrite else { return self }
        string.underlineColor = value
        return string
    }
}

// MARK: -

extension [ShellString] {
    // MARK: - Render

    func render() -> String {
        map { $0.render() }.joined()
    }

    // MARK: - Modifier

    private func other(_ other: [UInt8]) -> Self {
        map { $0.other(other) }
    }

    func format(_ values: Format..., overwrite: Bool = false) -> Self {
        format(Set(values), overwrite: overwrite)
    }

    func format(_ values: Set<Format>, overwrite: Bool = false) -> Self {
        map { $0.format(values, overwrite: overwrite) }
    }

    func inverseFormat(_ values: InverseFormat..., overwrite: Bool = false) -> Self {
        inverseFormat(Set(values), overwrite: overwrite)
    }

    func inverseFormat(_ values: Set<InverseFormat>, overwrite: Bool = false) -> Self {
        map { $0.inverseFormat(values, overwrite: overwrite) }
    }

    func font(_ value: Font?) -> Self {
        map { $0.font(value) }
    }

    func foregroundColor(_ value: Color?) -> Self {
        map { $0.foregroundColor(value, overwrite: count == 1) }
    }

    func backgroundColor(_ value: Color?) -> Self {
        map { $0.backgroundColor(value, overwrite: count == 1) }
    }

    func underlineColor(_ value: Color?) -> Self {
        map { $0.underlineColor(value, overwrite: count == 1) }
    }
}
