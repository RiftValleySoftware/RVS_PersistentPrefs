# ``RVS_PersistentPrefs``

Store small collections of app preferences with validated writes and typed accessors.

## Overview

``RVS_PersistentPrefs/RVS_PersistentPrefs`` stores a string-keyed dictionary inside one `UserDefaults` entry. Subclass it to declare the allowed entry names. Each read reloads from `UserDefaults`; each write validates and replaces the entire collection.

Use it for small, nonsensitive settings. It does not provide encrypted storage, database transactions, or coordination between concurrent writers. Confine your preferences access to one serial queue or actor.

### Define your preferences

The collection's storage key identifies the whole dictionary. The subclass's ``RVS_PersistentPrefs/keys`` identifies the entries allowed inside that dictionary. Choose an explicit, stable storage key: the default is the unqualified subclass name, which can change during refactoring or collide across modules.

```swift
import RVS_PersistentPrefs

final class AppPreferences: RVS_PersistentPrefs {
    override var keys: [String] { ["launchCount", "appearance", "layout"] }

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
    // Handle a read failure before making updates.
    print(error)
} else {
    prefs.launchCount += 1
    if let error = prefs.lastError {
        print(error)
    }
}
```

Keep these operations on the same serial execution context. Typed accessors should use safe casts because stored data can come from older app versions or other members of an App Group. Their fallback values do not create stored entries. Declaring a property `@objc dynamic` in a subclass can provide KVO for writes through that property; writes through the dictionary do not automatically notify those separate typed properties.

### Merge, replace, and remove

| Operation | Behavior |
| --- | --- |
| `AppPreferences(key: "settings")` | Loads the existing collection. A missing collection is empty. |
| `AppPreferences(key: "settings", values: ["appearance": "dark"])` | Merges into stored preferences; supplied entries win. |
| `AppPreferences(key: "settings", values: nil)` | Loads without writing, just like omitted or empty initial values. |
| `prefs.values = ["appearance": "dark"]` | Replaces the complete collection, removing omitted entries. |
| `prefs["appearance"] = "dark"` | Reads and updates one entry, preserving the others. |
| `prefs["appearance"] = nil` | Removes one entry. |
| `prefs.clear()` or `prefs.deleteAll()` | Removes the collection's key from the writable defaults domain. |
| `prefs.flush()` | Reloads and updates `lastError`; does not force a disk write or notify KVO. |

Assigning `[:]` has the same effect as `clear()`. These operations preserve unrelated defaults. After removal, values registered with `UserDefaults.register(defaults:)`, or supplied by other search domains, may become visible again. Neither removal method erases those fallback domains.

The library validates writes against ``RVS_PersistentPrefs/keys``. Reads retain unrecognized names, so you can migrate data from an older schema. To remove an obsolete name before updating, edit a dictionary snapshot and assign the revised collection. Check for a read error before doing so.

### Use supported value types

Values must be compatible with XML property lists: `String`, numeric and Boolean values, `Date`, `Data`, and arrays or string-keyed dictionaries containing only supported values. An invalid nested value rejects the whole write and reports its top-level entry name. This validation does not imply that `UserDefaults` stores its files in XML format.

`Codable` conformance alone does not make a custom struct or class suitable for direct storage. Encode it to `Data`, and decode it when reading:

```swift
import Foundation

struct Layout: Codable {
    var columns: Int
}

let encoded = try JSONEncoder().encode(Layout(columns: 2))
prefs["layout"] = encoded
if let error = prefs.lastError {
    print(error)
}

if let data = prefs["layout"] as? Data {
    let layout = try JSONDecoder().decode(Layout.self, from: data)
    // Use layout.columns.
}
```

Encoding and decoding throw independently of the preferences API. Define an app-specific migration or fallback for decoding failures.

### Handle failures immediately

Public operations do not throw. Inspect ``RVS_PersistentPrefs/lastError`` immediately after initialization, reading, writing, or calling a utility method. Reading ``RVS_PersistentPrefs/values``, ``RVS_PersistentPrefs/count``, or the subscript starts another operation and may clear a previous error.

| Error | Meaning and recovery |
| --- | --- |
| `incorrectKeys(invalidElements:)` | The write includes names absent from `keys`. Correct the names or migrate the schema. |
| `valuesNotPlistCompatible(invalidElements:)` | One or more top-level entries contain unsupported values. Encode custom types or remove invalid nested values. |
| `userDefaultsUnavailable` | The configured suite could not be created, or an overridden `userDefaults` returned `nil`. Correct the store configuration. |
| `invalidStoredValue(key:)` | The storage key contains something other than a string-keyed dictionary. Inspect or migrate that object using `UserDefaults`, explicitly replace `values`, or clear this collection. |

Rejected writes leave storage unchanged. A missing object is normal and returns an empty dictionary without error. Failed reads also return an empty dictionary, but set `lastError`. Initializer merges, subscript updates, and in-place Swift dictionary mutations abort after a failed read to avoid overwriting unrecognized stored data. An explicit assignment to `values` can replace malformed data, because it intentionally replaces the whole collection.

`noStoredPrefsForKey(key:)` and `unknownError(error:)` remain available for compatibility. Current missing-collection reads do not produce `noStoredPrefsForKey`.

### Observe local writes

```swift
let observation = prefs.observe(\.values, options: [.old, .new]) { _, change in
    let previous = change.oldValue?["appearance"] as? String
    let current = change.newValue?["appearance"] as? String
    if previous != current {
        // Update the interface on its required execution context.
    }
}
// Retain observation for as long as you need notifications.
```

The library sends KVO notifications explicitly for successful writes through the observed instance. Rejected writes, reads, `flush()`, and changes through other instances, apps, or extensions do not notify that object. Equal-value assignments can still notify. A notification means that a write was submitted to `UserDefaults`, not that it reached disk. Avoid mutating preferences or their configuration from the observation callback.

### Share preferences and coordinate writers

Set ``RVS_PersistentPrefs/groupID`` before creating instances:

```swift
RVS_PersistentPrefs.groupID = "group.com.example.app"
let sharedPrefs = AppPreferences(key: "com.example.app.preferences")
```

Use the same App Group identifier and entitlement in each participating app and extension. A successfully created `UserDefaults` suite does not prove that the targets have the correct entitlements. `nil` or an empty group ID selects the standard store. A nonempty suite that cannot be created reports an error and does not fall back to standard storage.

`groupID` is shared by all subclasses. Changing it, or an instance's `key`, redirects future operations without migrating data. You can override ``RVS_PersistentPrefs/userDefaults`` to inject a stable store per instance; initialize any backing state before calling `super.init`, because initialization reads through that override.

Although `UserDefaults` is thread-safe, this wrapper and its read-modify-write operations are not. Use a single serial execution context for access within your process. Separate processes can still overwrite each other's updates to the same dictionary; coordinate ownership externally or choose storage designed for concurrent transactions. Re-reading defaults does not provide immediate cross-process delivery or conflict resolution. App Groups do not transfer preferences between an iPhone and Apple Watch; the harness uses Watch Connectivity for that transfer.

### Persistence and privacy

`UserDefaults` updates its in-memory state during a write and persists to disk asynchronously. A successful operation cannot guarantee disk durability or report later disk failures. `flush()` does not call `synchronize()`, and applications should not use it as a durability barrier.

Preferences are unencrypted. Store secrets such as passwords and authentication tokens in the Keychain. This library does not log preference contents, collect analytics, or send data over the network. App Group members can access the shared preferences.

The Swift package resource bundle and the Xcode framework include `PrivacyInfo.xcprivacy`, declaring app-local and App Group preference access. If you copy the Swift source directly into an app, also include the manifest in the app's resources or incorporate the applicable declarations into its existing manifest.

### Requirements and installation

The Swift package requires Swift tools 5.5 or later and supports iOS/iPadOS 15, tvOS 11, macOS 10.14, and watchOS 5 or later. Add [the repository](https://github.com/RiftValleySoftware/RVS_PersistentPrefs) as a Swift package dependency and import `RVS_PersistentPrefs`.

The repository also provides an Xcode macOS framework target (macOS 12 or later) and [test harnesses](https://github.com/RiftValleySoftware/RVS_PersistentPrefs/tree/master/Tests) for iOS, macOS, tvOS, and watchOS. Harness deployment requirements can be higher than the library's. The iOS harness demonstrates bridging flat Settings.bundle keys to the nested preferences collection; Settings.bundle does not directly edit entries inside this dictionary.

For Xcode's Quick Help, Option-click a symbol or select it with the Quick Help inspector open. Build the documentation with Product > Build Documentation to browse this guide and the symbol reference.

## Topics

### Preferences

- ``RVS_PersistentPrefs/RVS_PersistentPrefs``
