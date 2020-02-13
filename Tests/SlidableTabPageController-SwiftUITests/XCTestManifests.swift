import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SlidableTabPageController_SwiftUITests.allTests),
    ]
}
#endif
