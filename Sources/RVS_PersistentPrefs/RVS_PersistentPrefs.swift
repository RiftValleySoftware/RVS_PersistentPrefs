/**
 © Copyright 2019-2026, The Great Rift Valley Software Company
 
 LICENSE:
 
 MIT License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
 modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 
 Version 1.7.0
 */

import Foundation

/**
 Stores a small dictionary of property-list values under one `UserDefaults` key.

 Subclass and override ``keys`` to declare the allowed preference names. Use
 ``init(key:values:)`` to choose a stable storage key and optionally merge initial
 values. Assigning ``values`` replaces the collection; the subscript updates one entry.

 Each read reloads the collection from `UserDefaults`. Writes validate the entire
 dictionary before submitting it to `UserDefaults`, which writes to disk asynchronously.
 Inspect ``lastError`` immediately after an operation; a subsequent successful read
 or write clears it. A missing collection is empty and is not an error.

 - Important: Confine access to one serial queue or actor, including changes to
   ``groupID``, ``key``, and ``lastError``. This class is not thread-safe. Updates
   from separate instances or processes are not atomic read-modify-write transactions.
 - Warning: `UserDefaults` is unencrypted preference storage. Store passwords,
   tokens, and other secrets in the Keychain. This class does not log preferences.

 ## Topics

 ### Creating a Collection
 - ``init()``
 - ``init(key:values:)``

 ### Configuring Storage
 - ``keys``
 - ``key``
 - ``groupID``
 - ``userDefaults``

 ### Reading and Writing
 - ``values``
 - ``subscript(_:)``
 - ``count``

 ### Handling Errors
 - ``lastError``
 - ``PrefsError``

 ### Reloading and Removing
 - ``flush()``
 - ``clear()``
 - ``deleteAll()``
 */
open class RVS_PersistentPrefs: NSObject {
    // MARK: - Private State and Storage

    private var _values: [String: Any] = [:]

    private func _load() {
        lastError = nil
        do {
            guard let defaults = userDefaults else { throw PrefsError.userDefaultsUnavailable }
            guard let stored = defaults.object(forKey: key) else {
                _values = [:]
                return
            }
            guard let dictionary = stored as? [String: Any] else {
                throw PrefsError.invalidStoredValue(key: key)
            }
            _values = dictionary
        } catch {
            // Never expose a previous collection after changing the key or store.
            _values = [:]
            lastError = (error as? PrefsError) ?? .unknownError(error: error)
        }
    }

    private func _save(_ newValues: [String: Any]) {
        lastError = nil
        let allowedKeys = Set(keys)
        let illegalKeys = newValues.keys.filter { !allowedKeys.contains($0) }.sorted()
        guard illegalKeys.isEmpty else {
            lastError = .incorrectKeys(invalidElements: illegalKeys)
            return
        }
        guard PropertyListSerialization.propertyList(newValues, isValidFor: .xml) else {
            let invalidKeys = newValues.filter {
                !PropertyListSerialization.propertyList($0.value, isValidFor: .xml)
            }.map(\.key).sorted()
            lastError = .valuesNotPlistCompatible(invalidElements: invalidKeys)
            return
        }
        guard let defaults = userDefaults else {
            lastError = .userDefaultsUnavailable
            return
        }

        let storageKey = key
        // Notify only after validation. Automatic KVO would also notify for failed
        // writes, and its getter calls could clear lastError during notification.
        willChangeValue(forKey: "values")
        if newValues.isEmpty {
            defaults.removeObject(forKey: storageKey)
        } else {
            defaults.set(newValues, forKey: storageKey)
        }
        _values = newValues
        lastError = nil
        didChangeValue(forKey: "values")
    }

    // MARK: - Errors

    /// Describes a rejected write or a collection that could not be read.
    ///
    /// Operations report these errors through ``RVS_PersistentPrefs/lastError``;
    /// the public accessors and methods do not throw.
    public enum PrefsError: Error {
        /// A write contains names absent from ``RVS_PersistentPrefs/keys``.
        ///
        /// `invalidElements` lists the rejected names in sorted order. No entries
        /// from the attempted write are saved.
        case incorrectKeys(invalidElements: [String])

        /// A write contains values that cannot be represented in an XML property list.
        ///
        /// `invalidElements` lists the offending top-level names in sorted order,
        /// including names whose nested arrays or dictionaries contain invalid values.
        /// No entries from the attempted write are saved.
        case valuesNotPlistCompatible(invalidElements: [String])

        /// The selected `UserDefaults` store is unavailable.
        ///
        /// A configured suite could not be created, or an override of
        /// ``RVS_PersistentPrefs/userDefaults`` returned `nil`. Nothing is saved.
        case userDefaultsUnavailable

        /// The object at the collection's storage key is not a string-keyed dictionary.
        ///
        /// `key` is the collection's storage key. Reads return an empty dictionary
        /// and report this error. Initialization and in-place mutations preserve
        /// the stored object; explicitly replace ``RVS_PersistentPrefs/values``
        /// or call ``RVS_PersistentPrefs/clear()`` to repair or remove it.
        case invalidStoredValue(key: String)

        /// A legacy error retained for source compatibility; missing collections are empty.
        ///
        /// Current operations do not produce this case. `key` identifies the
        /// storage key associated with the legacy error.
        case noStoredPrefsForKey(key: String)

        /// An otherwise unclassified error, optionally carrying its underlying cause.
        case unknownError(error: Error?)
    }

    // MARK: - Configuration

    /// Selects a shared `UserDefaults` suite for all instances and subclasses.
    ///
    /// `nil` or an empty string selects `UserDefaults.standard`. A nonempty value
    /// is passed to `UserDefaults(suiteName:)`; failure does not fall back to the
    /// standard store. Configure this once before creating preferences instances.
    /// Changing it redirects subsequent operations without migrating existing data.
    ///
    /// To share preferences between apps and extensions, use an App Group identifier
    /// and configure the matching entitlement in each target. Creating a suite does
    /// not verify those entitlements. Members of the group can access its preferences.
    public static var groupID: String?

    /// The `UserDefaults` key containing this instance's entire dictionary.
    ///
    /// This is separate from the entry names in ``keys``. Use a stable, unique key
    /// to avoid collisions with other stored objects. Changing it redirects the
    /// next operation; it does not rename or migrate the previous collection.
    open var key: String = ""

    /// The failure from the most recent operation, or `nil` after success.
    ///
    /// Check this immediately after initialization, a read, a write, or a utility
    /// method. Reading ``values``, the subscript, or ``count`` starts a new operation
    /// and can clear a previous error. This does not report asynchronous disk-write
    /// failures, which `UserDefaults` does not expose through its setter.
    open var lastError: PrefsError?

    /// The defaults store selected by ``groupID``, or `nil` if it is unavailable.
    ///
    /// Override to inject a particular store, for example an isolated suite for
    /// testing. Keep that selection stable during an operation. An override may be
    /// called during superclass initialization, so initialize any backing state first.
    open var userDefaults: UserDefaults? {
        guard let groupID = Self.groupID, !groupID.isEmpty else { return .standard }
        return UserDefaults(suiteName: groupID)
    }

    /// The number of entries returned by a fresh read of ``values``.
    ///
    /// Returns zero for an absent collection or a failed read. Inspect ``lastError``
    /// to distinguish them. This read can clear an earlier error.
    open var count: Int { values.count }

    /// The preference names this subclass permits when writing the dictionary.
    ///
    /// Override with a stable list. The base implementation allows no entries, so
    /// an unmodified base instance accepts only an empty dictionary. Validation
    /// applies to writes; reads preserve older or externally written names, allowing
    /// a subclass to migrate or remove them explicitly. Values are not type-checked
    /// against a schema; provide typed accessors with safe casts and fallback values.
    open var keys: [String] { [] }

    // MARK: - Reading and Writing

    // Native Swift dispatch preserves _modify's failed-read check. KVO is handled
    // explicitly in _save; @objc still exposes the property to Objective-C observers.

    /// Reads the stored collection, or replaces it after validating every entry.
    ///
    /// Reads reload from `UserDefaults`, including its registration and other search
    /// domains. A missing object returns `[:]` without error. An unavailable store
    /// or malformed object returns `[:]` and sets ``lastError``.
    ///
    /// Assign a complete dictionary to replace the collection. All entry names must
    /// appear in ``keys`` and all values must be property-list compatible: strings,
    /// numbers, booleans, dates, data, or arrays and string-keyed dictionaries of
    /// those types. `Codable` conformance alone is insufficient; encode custom types
    /// into `Data` first. A rejected write leaves storage unchanged.
    ///
    /// In-place mutations, such as `prefs.values["name"] = value`, first read the
    /// collection and abort if that read fails. Assigning `[:]` removes this storage
    /// key from the writable domain, so registered defaults may become visible again.
    ///
    /// KVO observes successful writes through this instance, including removals.
    /// Rejected writes, reads, ``flush()``, and changes through other instances or
    /// processes do not generate notifications on this object. Retain the observation
    /// token for as long as observation is required.
    @objc public var values: [String: Any] {
        get {
            _load()
            return _values
        }
        set { _save(newValue) }
        _modify {
            var current = values
            let canSave = lastError == nil
            defer {
                if canSave { values = current }
            }
            yield &current
        }
    }

    /// Uses explicit notifications for successful ``values`` writes.
    ///
    /// Other properties retain `NSObject`'s automatic KVO behavior. Subclasses
    /// overriding this method should delegate unhandled keys to `super`.
    open override class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        key == "values" ? false : super.automaticallyNotifiesObservers(forKey: key)
    }

    /// Reads or updates one preference, preserving the other entries.
    ///
    /// Assign `nil` to remove the entry. An absent entry returns `nil`; a failed
    /// read also returns `nil` and sets ``lastError``. Updates abort after a failed
    /// read, and otherwise use the same validation and KVO behavior as ``values``.
    ///
    /// - Parameter inKey: An entry name from ``keys``, not the collection's ``key``.
    /// - Returns: The stored value, or `nil` when the entry is absent or cannot be read.
    public subscript(_ inKey: String) -> Any? {
        get { values[inKey] }
        set {
            var current = values
            guard lastError == nil else { return }
            current[inKey] = newValue
            values = current
        }
    }

    // MARK: - Initialization

    /// Loads preferences using the subclass's unqualified type name as the storage key.
    ///
    /// A missing collection is empty. Inspect ``lastError`` for read failures. Type
    /// names can collide across modules or change during refactoring; prefer
    /// ``init(key:values:)`` with an explicit key for a stable storage format.
    public override init() {
        super.init()
        key = String(describing: Self.self).split(separator: ".").last.map(String.init) ?? "Prefs"
        _load()
    }

    /// Loads a collection and optionally merges initial values, with supplied values winning.
    ///
    /// Unlike assigning ``values``, this initializer preserves existing entries not
    /// included in `inValues`. Nonempty initial values are validated and saved as
    /// one merged dictionary. Failed reads or validation leave storage unchanged.
    /// Inspect ``lastError`` immediately after construction.
    ///
    /// - Parameters:
    ///   - inKey: The collection's storage key. `nil` (the default) uses the subclass's
    ///     unqualified type name. An empty string is used literally.
    ///   - inValues: Entries to merge. `nil`, `[:]`, or omission only loads existing
    ///     preferences; none of these clears the collection.
    public init(key inKey: String! = nil, values inValues: [String: Any]! = [:]) {
        super.init()
        key = inKey ?? String(describing: Self.self).split(separator: ".").last.map(String.init) ?? "Prefs"
        _load()
        if lastError == nil, let initialValues = inValues, !initialValues.isEmpty {
            values = _values.merging(initialValues, uniquingKeysWith: { _, new in new })
        }
    }

    // MARK: - Utilities

    /// Reloads the collection and updates ``lastError`` without writing or notifying KVO.
    ///
    /// This historical name does not mean a disk flush: the method does not force
    /// `UserDefaults` to synchronize. Ordinary ``values`` reads already reload.
    public func flush() {
        _load()
    }

    /// Removes this collection from the selected store's writable domain.
    ///
    /// Equivalent to assigning `[:]` to ``values``. Unrelated defaults are preserved.
    /// Values registered with `UserDefaults.register(defaults:)` or supplied by other
    /// search domains may become visible on the next read. Inspect ``lastError``
    /// immediately for an unavailable store.
    public func clear() {
        values = [:]
    }

    /// Removes this collection; an alias for ``clear()`` retained for compatibility.
    ///
    /// This does not erase the entire defaults domain, other collections, or other
    /// suites. Registered fallback values may reappear on the next read.
    public func deleteAll() {
        clear()
    }
}
