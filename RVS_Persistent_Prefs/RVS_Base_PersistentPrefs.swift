/**
 © Copyright 2019, The Great Rift Valley Software Company
 
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
 */

import Foundation

/* ################################################################################################################################## */
// MARK: - Main Preferences Base Class
/* ################################################################################################################################## */
/**
 This class is designed to act as an "abstract" base class, providing a simple Dictionary datastore.
 The Dictionary would be a String-keyed Dictionary of Any (flexible types). It s up to subclasses to specialize the typeless data.
 THIS IS NOT EFFICIENT OR ROBUST!
 It is meant as a simple "bucket" for things like application preferences.
 Subclasses could declare their accessors as KV observable, thus, providing a direct way to influence persistent state.
 */
public class RVS_Base_PersistentPrefs: NSObject {
    /* ############################################################################################################################## */
    // MARK: - Private Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is the Dictionary. It's private, and shouldn't need to be accessed outside this base class.
     */
    private var _values: [String: Any] = [:]
    
    /* ############################################################################################################################## */
    // MARK: - Private Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is a private method that saves the current contents of the _values Dictionary to persistent storage, keyed by the value of the "key" property.
     
     - throws: An error, if the values are not all codable.
     */
    private func _save() throws {
        #if DEBUG
            print("Saving Prefs: \(String(describing: _values))")
        #endif
        
        // What we do here, is "scrub" the values of anything that was added against what is expected.
        var temporaryDict: [String: Any] = [:]
        keys.forEach {
            temporaryDict[$0] = _values[$0]
        }
        _values = temporaryDict
        
        if PropertyListSerialization.propertyList(_values, isValidFor: .xml) {
            UserDefaults.standard.set(_values, forKey: key)
        } else {
            #if DEBUG
                print("Attempt to set non-codable values!")
            #endif
            
            // What we do here, is look through our values list, and record the keys of the elements that are not considered Codable. We return those in the error that we throw.
            var valueElementList: [String] = []
            _values.forEach {
                if PropertyListSerialization.propertyList($0.value, isValidFor: .xml) {
                    #if DEBUG
                        print("\($0.key) is OK")
                    #endif
                } else {
                    #if DEBUG
                        print("\($0.key) is not Codable")
                    #endif
                    valueElementList.append($0.key)
                }
            }
            throw PrefsError.valuesNotCodable(invalidElements: valueElementList)
        }
    }
    
    /* ################################################################## */
    /**
     This is a private method that reads in the data from persistent storage for this instance (using the "key" property), and loads the _values Dictionary property.
     
     - throws: An error, if there were no stored prefs for the given key.
     */
    private func _load() throws {
        let standardDefaultsObject = UserDefaults.standard
        
        if let loadedPrefs = standardDefaultsObject.object(forKey: key) as? [String: Any] {
            #if DEBUG
                print("Loaded Prefs: \(String(describing: loadedPrefs))")
            #endif
            _values = loadedPrefs
        } else {
            #if DEBUG
                print("Unable to Load Prefs for \(key)")
            #endif
            throw PrefsError.noStoredPrefsForKey(key: key)
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Enums
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Errors that Can be thrown from methods in this class
     */
    public enum PrefsError: Error {
        /// Not all of the elements in the _values Dictionary are Codable. The associated value is an Array of the failing keys.
        case valuesNotCodable(invalidElements: [String])
        /// We were not able to find a stored pref for the given key. The associated value is the key we are looking for.
        case noStoredPrefsForKey(key: String)
        /// Unknown thrown error.
        case unknownError(error: Error)
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is the key that is used to store and fetch the collection of data to be used to populate the _values Dictionary.
     */
    public var key: String = ""
    
    /* ################################################################## */
    /**
     This is any error that was thrown during a save or a load.
     */
    public var lastError: PrefsError!
    
    /* ############################################################################################################################## */
    // MARK: - Public Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This calculated property MUST be overridden by subclasses.
     It is an Array of String, containing the keys used to store and retrieve the values from persistent storage.
     */
    public var keys: [String] {
        preconditionFailure("YOU MUST OVERRIDE THIS METHOD")
    }
    
    /* ################################################################## */
    /**
     This is an accessor for the _values Dictionary. Before it returns the Dictionary, it loads data from persistent storage.
     After it sets the Dictionary, it saves the resulting Dictionary to persistent storage.
     This is meant to make persistent storage completely transparent.
     You simply read and write the Dictionary, using these accessors. The saving and retrieving happens in the background.
     */
    public var values: [String: Any] {
        get {
            lastError = nil
            do {
                try _load()
            } catch PrefsError.noStoredPrefsForKey(let unknownKey) {
                lastError = PrefsError.noStoredPrefsForKey(key: unknownKey)
            } catch {
                lastError = PrefsError.unknownError(error: error)
            }
            return _values
        }
        
        set {
            lastError = nil
            let oldValues = _values
            _values = newValue
            do {
                try _save()
            } catch PrefsError.valuesNotCodable(let unCodableKeys) {
                _values = oldValues
                lastError = PrefsError.valuesNotCodable(invalidElements: unCodableKeys)
            } catch {
                _values = oldValues
                lastError = PrefsError.unknownError(error: error)
            }
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Initializers
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     The default initializer uses the current subclass typename as the main key.
     */
    public override init() {
        super.init()
        key = String(describing: type(of: self).self)  // This gives us a simple classname as our key.
        do {
            try _load()
        } catch PrefsError.noStoredPrefsForKey(_) { // We ignore this error for initialization.
            lastError = nil
        } catch {
            lastError = PrefsError.unknownError(error: error)
        }
    }
    
    /* ################################################################## */
    /**
     You can initialize instances with a key and some initial data values.
     
     - parameter key: Optional (default is nil). A String, with a key to be used to associate the persistent state of this object to storage in the bundle.
        If not provided, the subclass classname is used as the key.
     - parameter values: Optional (default is nil). A Dictionary<String, Any>, with the values to be stored.
        If not provided, then the instance is populated by any persistent prefs.
        If provided, then the persistent prefs are updated with the new values.
     */
    public init(key inKey: String! = nil, values inValues: [String: Any]! = [:]) {
        super.init()
        key = inKey ?? String(describing: type(of: self).self)  // This gives us a simple classname as our key.
        
        // First, we load any currently stored prefs.
        do {
            try _load()
        } catch PrefsError.noStoredPrefsForKey(_) { // We ignore this error for initialization.
            lastError = nil
        } catch {
            lastError = PrefsError.unknownError(error: error)
        }
        
        #if DEBUG
            print("Initial Values \(_values)")
        #endif

        if nil == lastError {   // Make sure we didn't barf.
            let oldValues = _values
            // We do it this way, so that we can provide a partial Dictionary of values, and only affect certain ones, while leaving the others alone.
            _values.merge(inValues, uniquingKeysWith: { (_, new) in
                new
            })
            // Save our values.
            do {
                try _save()
            } catch PrefsError.valuesNotCodable(let unCodableKeys) {
                _values = oldValues
                lastError = PrefsError.valuesNotCodable(invalidElements: unCodableKeys)
            } catch {
                _values = oldValues
                lastError = PrefsError.unknownError(error: error)
            }
        }
    }
}
