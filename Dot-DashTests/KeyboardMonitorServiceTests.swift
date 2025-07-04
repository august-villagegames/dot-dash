
import XCTest
@testable import Dot_Dash

class KeyboardMonitorServiceTests: XCTestCase {

    var keyboardMonitorService: KeyboardMonitorService!

    override func setUpWithError() throws {
        keyboardMonitorService = KeyboardMonitorService()
    }

    override func tearDownWithError() throws {
        keyboardMonitorService = nil
    }

    func testStartAndStop() {
        // This test ensures that the start and stop methods can be called without crashing.
        // A true test of the event tap would require UI testing.
        keyboardMonitorService.start()
        keyboardMonitorService.stop()
    }

    // The handle() method is the core logic, but it's private and tied to the C-style callback.
    // To test it, you would need to refactor it to be more testable, or use UI tests.
    // For this example, we are focusing on the parts that can be easily unit tested.

}
