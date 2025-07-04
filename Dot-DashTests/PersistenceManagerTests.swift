
import XCTest
@testable import Dot_Dash

class PersistenceManagerTests: XCTestCase {

    var persistenceManager: PersistenceManager!

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager()
        // Start with a clean slate before each test
        persistenceManager.getRules().forEach { persistenceManager.delete(rule: $0) }
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
    }

    func testAddRule() throws {
        let initialCount = persistenceManager.getRules().count
        let newRule = ExpansionRule(command: ".testAdd", replacementText: "Added for test")
        persistenceManager.add(rule: newRule)
        let newCount = persistenceManager.getRules().count
        XCTAssertEqual(newCount, initialCount + 1, "A rule should have been added.")
    }

    func testDeleteRule() throws {
        let ruleToDelete = ExpansionRule(command: ".testDelete", replacementText: "To be deleted")
        persistenceManager.add(rule: ruleToDelete)
        let initialCount = persistenceManager.getRules().count

        persistenceManager.delete(rule: ruleToDelete)
        let newCount = persistenceManager.getRules().count

        XCTAssertEqual(newCount, initialCount - 1, "A rule should have been deleted.")
    }

    func testLoadRules() throws {
        let rule1 = ExpansionRule(command: ".testLoad1", replacementText: "Loaded 1")
        let rule2 = ExpansionRule(command: ".testLoad2", replacementText: "Loaded 2")
        persistenceManager.add(rule: rule1)
        persistenceManager.add(rule: rule2)

        // Create a new instance to force a load from disk
        let newPersistenceManager = PersistenceManager()
        let loadedRules = newPersistenceManager.getRules()

        XCTAssertEqual(loadedRules.count, 2, "Should load the correct number of rules from disk.")
        XCTAssertTrue(loadedRules.contains(where: { $0.command == ".testLoad1" }), "Loaded rules should contain the first rule.")
        XCTAssertTrue(loadedRules.contains(where: { $0.command == ".testLoad2" }), "Loaded rules should contain the second rule.")
    }
}
