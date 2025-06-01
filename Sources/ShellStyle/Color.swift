//
//  Color.swift
//  ShellStyle
//
//  Created by David Walter on 23.02.25.
//

import Foundation

enum Color: Sendable, SGRRepresentable {
    case named(ColorNamed)
    case bit8(Color8bit)
    case bit24(Color24bit)

    init?(rawValue: UInt8, iterator: inout IndexingIterator<[UInt8]>) {
        if let value = ColorNamed(rawValue: rawValue) {
            self = .named(value)
        } else if let element = ColorElement(rawValue: rawValue) {
            guard let second = iterator.next() else {
                return nil
            }

            switch second {
            case 2:
                guard let red = iterator.next(), let green = iterator.next(), let blue = iterator.next() else {
                    return nil
                }
                self = .bit24(Color24bit(red: red, green: green, blue: blue, element: element))
            case 5:
                guard let color = iterator.next() else { return nil }
                self = .bit8(Color8bit(color, element: element))
            default:
                return nil
            }
        } else {
            return nil
        }
    }

    var element: ColorElement? {
        switch self {
        case let .named(value):
            if value.isForeground {
                .foreground
            } else if value.isBackground {
                .background
            } else {
                nil
            }
        case let .bit8(value):
            value.element
        case let .bit24(value):
            value.element
        }
    }

    // MARK: SGRRepresentable

    var sgr: [UInt8] {
        switch self {
        case let .named(value):
            value.sgr
        case let .bit8(value):
            value.sgr
        case let .bit24(value):
            value.sgr
        }
    }
}

enum ColorElement: UInt8 {
    case foreground = 38
    case background = 48
    case underline = 58
}

struct ColorNamed: RawRepresentable, SGRRepresentable {
    let rawValue: UInt8

    init?(rawValue: UInt8) {
        switch rawValue {
        case 30...37:
            self.rawValue = rawValue
        case 39:
            self.rawValue = rawValue
        case 40...47:
            self.rawValue = rawValue
        case 49:
            self.rawValue = rawValue
        case 90...97:
            self.rawValue = rawValue
        case 100...107:
            self.rawValue = rawValue
        default:
            return nil
        }
    }

    init(color: DefaultColor, isBackground: Bool, isBright: Bool) {
        var rawValue: UInt8 =
            switch color {
            case .black:
                30
            case .red:
                31
            case .green:
                32
            case .yellow:
                33
            case .blue:
                34
            case .magenta:
                35
            case .cyan:
                36
            case .white:
                37
            }

        if isBackground {
            rawValue += 10
        }
        if isBright {
            rawValue += 60
        }

        self.rawValue = rawValue
    }

    var isBright: Bool {
        switch rawValue {
        case 90...97, 100...107:
            return true
        default:
            return false
        }
    }

    var isForeground: Bool {
        switch rawValue {
        case 30...37, 39, 90...97:
            return true
        default:
            return false
        }
    }

    var isBackground: Bool {
        switch rawValue {
        case 40...47, 49, 100...107:
            return true
        default:
            return false
        }
    }

    // MARK: SGRRepresentable

    var sgr: [UInt8] {
        [rawValue]
    }
}

struct Color8bit: SGRRepresentable {
    private let rawValue: UInt8
    let element: ColorElement

    init(_ rawValue: UInt8, element: ColorElement) {
        self.rawValue = rawValue
        self.element = element
    }

    var isForeground: Bool {
        switch element {
        case .foreground:
            true
        default:
            false
        }
    }

    var isBackground: Bool {
        switch element {
        case .background:
            true
        default:
            false
        }
    }

    // MARK: SGRRepresentable

    var sgr: [UInt8] {
        [element.rawValue, 5, rawValue]
    }
}

struct Color24bit: SGRRepresentable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8

    let element: ColorElement

    init(red: UInt8, green: UInt8, blue: UInt8, element: ColorElement) {
        self.red = red
        self.green = green
        self.blue = blue
        self.element = element
    }

    var isForeground: Bool {
        switch element {
        case .foreground:
            true
        default:
            false
        }
    }

    var isBackground: Bool {
        switch element {
        case .background:
            true
        default:
            false
        }
    }

    // MARK: SGRRepresentable

    var sgr: [UInt8] {
        [element.rawValue, 2, red, green, blue]
    }
}
