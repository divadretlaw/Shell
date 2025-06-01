# Shell

Run Shell commands from Swift

## `Shell`

### Examples

Simply run a command

```swift
let command = Command("echo", "Hello")
try await command()
// prints - Hello
```

Run a command and capture the output

```swift
let command = Command("echo", "Hello")
let output = try await command.capture()
// output: Hello
```

Pipe commands

```swift
let echo = Command("echo", "Hello")
let rev = Command("rev")
let command = echo | rev
let output = try await command.capture()
// output: olleH
```

## `ShellStyle`

Style terminal output

## License

See [LICENSE](LICENSE)
