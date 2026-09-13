// © Copyright 2026, The Great Rift Valley Software Company. MIT License.

import Foundation
import XCTest
import RVS_PersistentPrefs

final class RVS_PersistentPrefs_Regression_Tests: XCTestCase {
    private final class Preferences: RVS_PersistentPrefs {
        var store: UserDefaults?
        override var userDefaults: UserDefaults? { store }
        override var keys: [String] { ["first", "second", "nested"] }

        init(store: UserDefaults?, key: String = "preferences", values: [String: Any]? = [:]) {
            self.store = store
            super.init(key: key, values: values)
        }
    }

    private var suiteName = ""
    private var store: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "RVS.PersistentPrefs.Tests.\(UUID().uuidString)"
        store = try XCTUnwrap(UserDefaults(suiteName: suiteName))
    }

    override func tearDownWithError() throws {
        store.removePersistentDomain(forName: suiteName)
        store = nil
        try super.tearDownWithError()
    }

    func testNilInitialValuesLoadsExistingPreferences() {
        store.set(["first": 42], forKey: "preferences")
        let prefs = Preferences(store: store, values: nil)
        XCTAssertNil(prefs.lastError)
        XCTAssertEqual(prefs["first"] as? Int, 42)
    }

    func testMissingPreferencesAreEmptyWithoutAnError() {
        let prefs = Preferences(store: store)
        XCTAssertNil(prefs.lastError)
        XCTAssertTrue(prefs.values.isEmpty)
        XCTAssertNil(prefs.lastError)
        XCTAssertNil(store.object(forKey: "preferences"))
    }

    func testInitializerMergesButAssignmentReplaces() {
        store.set(["first": 1, "second": 2], forKey: "preferences")
        let prefs = Preferences(store: store, values: ["first": 3])
        XCTAssertEqual(prefs.values as? [String: Int], ["first": 3, "second": 2])
        prefs.values = ["first": 4]
        XCTAssertNil(prefs.lastError)
        XCTAssertEqual(store.dictionary(forKey: "preferences") as? [String: Int], ["first": 4])
    }

    func testInvalidKeysRejectTheWholeWrite() {
        let prefs = Preferences(store: store, values: ["first": 1])
        prefs.values = ["first": 2, "z": 3, "a": 4]
        guard case .incorrectKeys(let keys)? = prefs.lastError else {
            return XCTFail("Expected an invalid-key error")
        }
        XCTAssertEqual(keys, ["a", "z"])
        XCTAssertEqual(store.dictionary(forKey: "preferences") as? [String: Int], ["first": 1])
        XCTAssertEqual(prefs["first"] as? Int, 1)
        XCTAssertNil(prefs.lastError, "A successful read clears the preceding error")
    }

    func testNestedNonPropertyListValuesRejectTheWholeWrite() {
        let prefs = Preferences(store: store, values: ["first": 1])
        prefs.values = ["first": 2, "nested": ["unsupported": NSObject()]]
        guard case .valuesNotPlistCompatible(let keys)? = prefs.lastError else {
            return XCTFail("Expected a property-list error")
        }
        XCTAssertEqual(keys, ["nested"])
        XCTAssertEqual(store.dictionary(forKey: "preferences") as? [String: Int], ["first": 1])
    }

    func testPropertyListTypesRoundTrip() {
        let date = Date(timeIntervalSince1970: 12345)
        let data = Data([0, 1, 254, 255])
        let prefs = Preferences(store: store, values: ["nested": ["date": date, "data": data,
                                                                "array": [true, 2, "three"] as [Any]]])
        XCTAssertNil(prefs.lastError)
        let nested = prefs["nested"] as? [String: Any]
        XCTAssertEqual(nested?["date"] as? Date, date)
        XCTAssertEqual(nested?["data"] as? Data, data)
        XCTAssertEqual((nested?["array"] as? [Any])?.count, 3)
    }

    func testUnavailableStoreReportsReadWriteAndDeleteFailures() {
        let prefs = Preferences(store: nil)
        guard case .userDefaultsUnavailable? = prefs.lastError else {
            return XCTFail("Expected an unavailable-store error")
        }
        prefs.values = ["first": 1]
        XCTAssertNotNil(prefs.lastError)
        XCTAssertTrue(prefs.values.isEmpty)
        XCTAssertNotNil(prefs.lastError)
        prefs.flush()
        XCTAssertNotNil(prefs.lastError)
        prefs.clear()
        XCTAssertNotNil(prefs.lastError)
        prefs.deleteAll()
        XCTAssertNotNil(prefs.lastError)
    }

    func testFailedReadDoesNotReturnValuesFromPreviousStoreOrKey() {
        let prefs = Preferences(store: store, values: ["first": 1])
        prefs.store = nil
        XCTAssertTrue(prefs.values.isEmpty)
        XCTAssertNotNil(prefs.lastError)
        prefs.store = store
        store.set("unexpected scalar", forKey: "another")
        prefs.key = "another"
        XCTAssertTrue(prefs.values.isEmpty)
        XCTAssertNotNil(prefs.lastError)
    }

    func testMalformedStorageIsNotOverwrittenByInitializationOrSubscript() {
        store.set("unexpected scalar", forKey: "preferences")
        let prefs = Preferences(store: store, values: ["first": 1])
        guard case .invalidStoredValue(let key)? = prefs.lastError else {
            return XCTFail("Expected a malformed-collection error")
        }
        XCTAssertEqual(key, "preferences")
        prefs["first"] = 2
        XCTAssertNotNil(prefs.lastError)
        XCTAssertEqual(store.string(forKey: "preferences"), "unexpected scalar")
    }

    func testMalformedStorageIsNotOverwrittenByDictionaryMutation() {
        store.set("unexpected scalar", forKey: "preferences")
        let prefs = Preferences(store: store)
        prefs.values["first"] = 2
        XCTAssertNotNil(prefs.lastError)
        XCTAssertEqual(store.string(forKey: "preferences"), "unexpected scalar")
    }

    func testExplicitReplacementCanRepairMalformedStorage() {
        store.set("unexpected scalar", forKey: "preferences")
        let prefs = Preferences(store: store)
        prefs.values = ["first": 2]
        XCTAssertNil(prefs.lastError)
        XCTAssertEqual(prefs["first"] as? Int, 2)
    }

    func testFlushReportsErrorsAndRecoversAfterStorageIsRepaired() {
        let prefs = Preferences(store: store, values: ["first": 1])
        store.set("unexpected scalar", forKey: "preferences")
        prefs.flush()
        XCTAssertNotNil(prefs.lastError)
        store.set(["second": 2], forKey: "preferences")
        prefs.flush()
        XCTAssertNil(prefs.lastError)
        XCTAssertEqual(prefs.values as? [String: Int], ["second": 2])
    }

    func testRemovingOneValueAndClearingOnlyAffectsThisCollection() {
        store.set("keep", forKey: "unrelated")
        let prefs = Preferences(store: store, values: ["first": 1, "second": 2])
        prefs["first"] = nil
        XCTAssertEqual(prefs.values as? [String: Int], ["second": 2])
        prefs.clear()
        XCTAssertNil(prefs.lastError)
        XCTAssertNil(store.object(forKey: "preferences"))
        prefs.values = ["first": 3]
        prefs.deleteAll()
        XCTAssertNil(prefs.lastError)
        XCTAssertNil(store.object(forKey: "preferences"))
        XCTAssertEqual(store.string(forKey: "unrelated"), "keep")
    }

    func testRegisteredFallbackReappearsAfterClear() {
        // The registration domain is shared by all suites in this process.
        let key = "registered-\(UUID().uuidString)"
        store.register(defaults: [key: ["first": 10]])
        let prefs = Preferences(store: store, key: key, values: ["first": 20])
        prefs.clear()
        XCTAssertEqual(prefs["first"] as? Int, 10)
        XCTAssertNil(store.persistentDomain(forName: suiteName)?[key])
    }

    func testKVOReportsOnlySuccessfulLocalWrites() {
        let prefs = Preferences(store: store, values: ["first": 1])
        var oldValues: [Int?] = []
        var newValues: [Int?] = []
        let observation = prefs.observe(\.values, options: [.old, .new]) { _, change in
            oldValues.append(change.oldValue?["first"] as? Int)
            newValues.append(change.newValue?["first"] as? Int)
        }
        defer { observation.invalidate() }
        prefs.values["first"] = 2
        XCTAssertEqual(oldValues, [1])
        XCTAssertEqual(newValues, [2])
        prefs.values = ["illegal": 3]
        XCTAssertNotNil(prefs.lastError, "KVO must not erase a rejected write's error")
        XCTAssertEqual(newValues.count, 1)
        let other = Preferences(store: store, values: ["first": 4])
        XCTAssertNil(other.lastError)
        XCTAssertEqual(prefs["first"] as? Int, 4)
        prefs.flush()
        XCTAssertEqual(newValues.count, 1, "External changes and reloads do not notify")
        prefs.clear()
        XCTAssertEqual(newValues, [2, nil])
    }

    func testKVOOldValueReadDoesNotMarkASuccessfulRepairAsFailed() {
        store.set("unexpected scalar", forKey: "preferences")
        let prefs = Preferences(store: store)
        var notificationCount = 0
        let observation = prefs.observe(\.values, options: [.old]) { _, _ in
            notificationCount += 1
        }
        defer { observation.invalidate() }
        prefs.values = ["first": 1]
        XCTAssertNil(prefs.lastError)
        XCTAssertEqual(notificationCount, 1)
        XCTAssertEqual(store.dictionary(forKey: "preferences") as? [String: Int], ["first": 1])
    }
}
