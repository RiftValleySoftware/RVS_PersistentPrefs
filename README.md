![Icon](icon.png)

# RVS_PersistentPrefs

A Swift base class for storing small collections of app preferences as a validated dictionary in `UserDefaults`.

Version **1.7.0**. See the [changelog](CHANGELOG.md), [DocC guide](Sources/RVS_PersistentPrefs/RVS_PersistentPrefs.docc/RVS_PersistentPrefs.md), and [privacy declaration](PRIVACY.md).

## Installation

Add `https://github.com/RiftValleySoftware/RVS_PersistentPrefs` as a Swift package dependency in Xcode, then import `RVS_PersistentPrefs`. The package requires Swift tools 5.5 or later and supports iOS/iPadOS 15, tvOS 11, macOS 10.14, and watchOS 5 or later. The test harnesses may require newer system versions.

The Xcode project’s macOS targets require macOS 12 or later for compatibility with Xcode 27. It also provides a macOS framework target for direct integration or Carthage (`github "RiftValleySoftware/RVS_PersistentPrefs"`). For source-only integration, copy [RVS_PersistentPrefs.swift](Sources/RVS_PersistentPrefs/RVS_PersistentPrefs.swift) and include [PrivacyInfo.xcprivacy](Sources/RVS_PersistentPrefs/PrivacyInfo.xcprivacy) in the app's resources, or incorporate its applicable declarations into the app's existing manifest. Swift Package Manager and the framework target package that manifest automatically.

## Quick start

```swift
import RVS_PersistentPrefs

final class AppPreferences: RVS_PersistentPrefs {
    override var keys: [String] { ["launchCount", "appearance"] }

    var launchCount: Int {
        get { self["launchCount"] as? Int ?? 0 }
        set { self["launchCount"] = newValue }
    }

    var appearance: String {
        get { self["appearance"] as? String ?? "system" }
        set { self["appearance"] = newValue }
    }
}

let prefs = AppPreferences(key: "com.example.app.preferences")
if let error = prefs.lastError {
    // Handle a read failure before updating preferences.
    print(error)
} else {
    prefs.appearance = "dark"
    if let error = prefs.lastError {
        print(error)
    }
}
```

Run preferences operations on one serial queue or actor. `key` identifies the entire stored dictionary; `keys` lists the allowed names inside it. An explicit, stable storage key avoids collisions and changes caused by renaming a subclass. Safe casts and fallback values handle absent or older data; they do not persist those fallback values.

## Read, write, and remove

| Operation | Effect |
| --- | --- |
| `AppPreferences(key: "settings")` | Loads a collection. Missing storage is empty, without error. |
| `AppPreferences(key: "settings", values: ["appearance": "dark"])` | Merges supplied entries into existing storage; supplied values win. |
| Initial values of `nil` or `[:]` | Loads without writing or clearing. |
| `prefs.values = ["appearance": "dark"]` | Replaces the whole collection. |
| `prefs["appearance"] = "dark"` | Updates one entry, preserving the others. |
| `prefs["appearance"] = nil` | Removes one entry. |
| `prefs.clear()`, `prefs.deleteAll()`, or `prefs.values = [:]` | Removes this collection from the writable defaults domain. |
| `prefs.flush()` | Reloads and updates `lastError`; does not force a disk write. |

Each read reloads from `UserDefaults`, including its search domains. Removal preserves unrelated defaults and can expose registered fallback values again. Each write validates the whole collection before saving it. Allowed values are property-list strings, numbers, booleans, dates, data, and arrays or string-keyed dictionaries of those types. Encode custom `Codable` types to `Data` first; conformance alone is insufficient.

## Errors and observation

Inspect `lastError` immediately after an operation. A subsequent read of `values`, the subscript, or `count` starts a new operation and can clear the previous error.

- `incorrectKeys` reports entry names absent from `keys`.
- `valuesNotPlistCompatible` reports top-level entries containing unsupported values, including nested values.
- `userDefaultsUnavailable` reports an unavailable selected store.
- `invalidStoredValue` reports a storage key containing something other than a string-keyed dictionary.

Rejected writes preserve storage. Initializer merges, subscript writes, and in-place Swift dictionary mutations also abort after a failed read. To repair malformed storage deliberately, migrate it, assign a complete replacement to `values`, or call `clear()`.

Observe `values` with `prefs.observe(\.values, options: [.old, .new])`. Retain the observation token. The library sends notifications explicitly for successful writes through that instance, including removals. Reads, rejected writes, `flush()`, and changes made elsewhere do not notify it. Typed subclass properties need their own observation design if callers also update the dictionary directly.

## Shared storage, persistence, and privacy

Set `RVS_PersistentPrefs.groupID` once before constructing instances to select an App Group suite. Configure matching entitlements in all participating targets. Suite creation does not validate those entitlements. `nil` or an empty identifier selects standard defaults; a nonempty suite that cannot be created fails without falling back to another store. The setting affects every subclass. Changing it or `key` redirects future operations without migrating data.

This wrapper is not thread-safe. Confine access to one serial execution context, and coordinate writers in other processes separately. A whole-dictionary update can overwrite another writer's changes. App Groups alone do not transfer data between an iPhone and Apple Watch.

`UserDefaults` persists to disk asynchronously; successful writes and KVO notifications do not guarantee disk durability. The library cannot report later disk-write failures. Preferences are unencrypted: use the Keychain for secrets. The library does not log preferences or perform networking. Its bundled privacy manifest covers app-local and App Group preference access.

## Documentation and testing

Option-click a public symbol in Xcode for Quick Help, or use Product > Build Documentation for the complete DocC guide and API reference. The guide includes encoding custom types, error recovery, KVO examples, and storage configuration. The [previously published reference](https://riftvalleysoftware.github.io/RVS_PersistentPrefs/) may describe an earlier release until regenerated.

Run `swift test` on macOS, or use the `RVS_PersistentPrefs` Xcode scheme for XCTest and documentation builds. Regression tests use isolated defaults suites. The [test harnesses](Tests) demonstrate iOS, macOS, tvOS, and watchOS integration. The iOS harness bridges flat Settings.bundle preferences to the nested dictionary, the macOS harness demonstrates KVO bindings, and the watchOS harness uses a single app target with Watch Connectivity to exchange values with the phone. Its existing WatchKit storyboard is retained; Xcode still reports that storyboard format as deprecated.

Distributed under the [MIT License](LICENSE).
