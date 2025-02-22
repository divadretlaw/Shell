import Testing
@testable import Shell

struct ExpansionTests {
    @Test
    func expand() {
        let environment = ["TEST": "1"]
        #expect("$TEST".expand(with: environment) == "1")
        #expect("${TEST}".expand(with: environment) == "1")
        #expect("${TEST:-}".expand(with: environment) == "1")
    }
    
    @Test
    func expandUnknown() {
        let environment = ["TEST": "1"]
        #expect("$UNKNOWN".expand(with: environment) == "")
        #expect("${UNKNOWN}".expand(with: environment) == "")
        #expect("${UNKNOWN:-fallback}".expand(with: environment) == "fallback")
    }
    
    @Test
    func expandLevel() {
        let environment = ["TEST": "$OTHER", "OTHER": "1"]
        #expect("$TEST".expand(with: environment) == "1")
        #expect("${TEST}".expand(with: environment) == "1")
        #expect("${TEST:-}".expand(with: environment) == "1")
    }
    
    @Test
    func expandMulti() {
        let environment = ["TEST": "1", "OTHER": "2"]
        #expect("$TEST $OTHER".expand(with: environment) == "1 2")
        #expect("${TEST} ${OTHER}".expand(with: environment) == "1 2")
        #expect("${TEST:-} ${OTHER:-}".expand(with: environment) == "1 2")
    }
}
