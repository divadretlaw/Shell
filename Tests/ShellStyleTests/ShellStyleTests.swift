import Testing
@testable import ShellStyle

struct ShellStyleTests {
    @Test
    func styles() {
        for format in Format.allCases {
            print("Styles".format(format))
        }
    }

    @Test
    func combinedStyles() {
        print("Combined Styles".bold().italic().underline())
        print("\("Hello".underline()) \("Combined".italic()) Styles".bold())
    }

    @Test
    func combinedColors() {
        let test = "\("Hello".foregroundColor(.red).inverseFormat(.notUnderline)) \("Combined".inverseFormat(.notUnderline)) \("Colors".foregroundColor(.blue))"
        print(test.foregroundColor(.green).underline(127))
    }

    @Test
    func inverseStyle() {
        let test = "Hello \("Inverse".inverseFormat(.notUnderline)) World"
        print(test.foregroundColor(.green).underline())
    }

    @Test
    func foregroundColors() {
        for color in DefaultColor.allCases {
            print("Foreground".foregroundColor(color))
        }
    }

    @Test
    func backgroundColors() {
        for color in DefaultColor.allCases {
            print("Background".backgroundColor(color))
        }
    }
}
