import XCTest
@testable import AL1Core

final class AL1CoreTests: XCTestCase {
    func testVersionIsNonEmpty() {
        XCTAssertFalse(AL1Core.version.isEmpty)
    }
}
