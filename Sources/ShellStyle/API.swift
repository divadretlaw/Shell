//
//  API.swift
//  ShellStyle
//
//  Created by David Walter on 23.02.25.
//

import Foundation

extension String {
    // MARK: - Format
    
    /// Applies the given format to the text.
    /// - Parameter format: The formats to apply.
    /// - Returns: Text with the applied formats.
    public func format(_ format: Format...) -> String {
        ShellString.parse(self)
            .format(Set(format), overwrite: true)
            .render()
    }

    /// Applies the given inverse format to the text.
    /// - Parameter format: The inverse formats to apply.
    /// - Returns: Text with the applied inverse formats.
    public func inverseFormat(_ format: InverseFormat...) -> String {
        ShellString.parse(self)
            .inverseFormat(Set(format), overwrite: true)
            .render()
    }
    
    /// Applies a bold font weight to the text.
    /// - Returns: Text with applied bold font weight.
    public func bold() -> String {
        ShellString.parse(self)
            .format(.bold)
            .render()
    }
    
    /// Applies italics to the text.
    /// - Returns: Text with applied italics.
    public func italic() -> String {
        ShellString.parse(self)
            .format(.italic)
            .render()
    }
    
    /// Applies an underline to the text.
    /// - Returns: Text with a line running along its baseline.
    public func underline() -> String {
        ShellString.parse(self)
            .format(.underline)
            .render()
    }

    /// Applies an underline to the text.
    /// - Parameters:
    ///     - color: The color of the underline.
    /// - Returns: Text with a line running along its baseline.
    public func underline(_ color: UInt8) -> String {
        ShellString.parse(self)
            .format(.underline)
            .underlineColor(.bit8(Color8bit(color, element: .underline)))
            .render()
    }

    /// Applies an underline to the text.
    /// - Parameters:
    ///     - red: The red part of the color of the underline.
    ///     - green: The green part of the color of the underline.
    ///     - blue: The blue part of the color of the underline.
    /// - Returns: Text with a line running along its baseline.
    public func underline(red: UInt8, green: UInt8, blue: UInt8) -> String {
        ShellString.parse(self)
            .format(.underline)
            .underlineColor(.bit24(Color24bit(red: red, green: green, blue: blue, element: .underline)))
            .render()
    }

    // MARK: - Foreground Color
    
    /// Sets the color of the text.
    /// - Parameters:
    ///   - color: The color to use when displaying this text.
    ///   - isBright: Whether the color is the bright variant. Defaults to `false`.
    /// - Returns: A text that uses the color value you supply.
    public func foregroundColor(_ color: DefaultColor, isBright: Bool = false) -> String {
        ShellString.parse(self)
            .foregroundColor(.named(.init(color: color, isBackground: false, isBright: isBright)))
            .render()
    }
    
    /// Sets the color of the text.
    /// - Parameter color: The color of the text
    /// - Returns: A text that uses the color value you supply.
    public func foregroundColor(_ color: UInt8) -> String {
        ShellString.parse(self)
            .foregroundColor(.bit8(Color8bit(color, element: .foreground)))
            .render()
    }
    
    /// Sets the color of the text.
    /// - Parameters:
    ///     - red: The red part of the color of the text.
    ///     - green: The green part of the color of the text.
    ///     - blue: The blue part of the color of the text.
    /// - Returns: A text that uses the color value you supply.
    public func foregroundColor(red: UInt8, green: UInt8, blue: UInt8) -> String {
        ShellString.parse(self)
            .foregroundColor(.bit24(Color24bit(red: red, green: green, blue: blue, element: .foreground)))
            .render()
    }

    // MARK: - Background Color

    /// Sets the background color of the text.
    /// - Parameters:
    ///   - color: The background color to use when displaying this text.
    ///   - isBright: Whether the color is the bright variant. Defaults to `false`.
    /// - Returns: A text that uses the background color value you supply.
    public func backgroundColor(_ color: DefaultColor, isBright: Bool = false) -> String {
        ShellString.parse(self)
            .backgroundColor(.named(.init(color: color, isBackground: true, isBright: isBright)))
            .render()
    }

    /// Sets the background color of the text.
    /// - Parameter color: The background color of the text
    /// - Returns: A text that uses the background color value you supply.
    public func backgroundColor(_ color: UInt8) -> String {
        ShellString.parse(self)
            .backgroundColor(.bit8(Color8bit(color, element: .background)))
            .render()
    }

    /// Sets the background color of the text.
    /// - Parameters:
    ///     - red: The red part of the background color of the text.
    ///     - green: The green part of the background color of the text.
    ///     - blue: The blue part of the background color of the text.
    /// - Returns: A text that uses the background color value you supply.
    public func backgroundColor(red: UInt8, green: UInt8, blue: UInt8) -> String {
        ShellString.parse(self)
            .backgroundColor(.bit24(Color24bit(red: red, green: green, blue: blue, element: .background)))
            .render()
    }
}
