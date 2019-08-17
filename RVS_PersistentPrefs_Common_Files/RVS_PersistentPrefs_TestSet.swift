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
// MARK: - Shared Prefs Subclass
/* ################################################################################################################################## */
/**
 This class is the concrete subclass of RVS_PersistentPrefs that implements a few simple data types.
 It is designed to be KVO, so it can be accessed without coding.
 */
public class RVS_PersistentPrefs_TestSet: RVS_PersistentPrefs {
    /* ############################################################################################################################## */
    // MARK: - Private Static Variables
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is an Array of String, containing the keys used to store and retrieve the values from persistent storage.
     */
    private static let _myKeys: [String] = ["Integer Value", "String Value", "Array Value", "Dictionary Value", "Date Value"]
    
    /* ################################################################## */
    /**
     This Dictionary contains our default (initial) values for the contained data.
     */
    private static let _myValues: [String: Any] = ["Integer Value": 12345, "String Value": "Any String", "Array Value": ["One", "Two", "Three", "Four", "Five"], "Dictionary Value": ["One": "1", "Two": "2", "Three": "3", "Four": "4", "Five": "5"], "Date Value": Date()]
    
    /* ############################################################################################################################## */
    // MARK: - Private Enums
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     These are indexes, into the main keys Array. They represent different types of stored properties.
     */
    private enum _Indexes: Int {
        /// Simple arbitrary Integer value
        case int
        /// Simple arbitrary String value
        case string
        /// An Array of String
        case array
        /// A Dictionary of String, keyed by String
        case dictionary
        /// A Date object
        case date
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Calculated Properties (Override)
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is an Array of String, containing the keys used to store and retrieve the values from persistent storage. READ-ONLY
     */
    override public var keys: [String] {
        return type(of: self)._myKeys
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     The Integer Value. READ-WRITE
     */
    @objc dynamic var int: Int {
        get {
            return values[keys[_Indexes.int.rawValue]] as? Int ?? 0
        }
        
        set {
            return values[keys[_Indexes.int.rawValue]] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The Key (the Label) for the Integer Value. READ-ONLY
     */
    @objc dynamic var intKey: String {
        return keys[_Indexes.int.rawValue]
    }
    
    /* ################################################################## */
    /**
     The String Value. READ-WRITE
     */
    @objc dynamic var string: String {
        get {
            return values[keys[_Indexes.string.rawValue]] as? String ?? ""
        }
        
        set {
            return values[keys[_Indexes.string.rawValue]] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The Key (the Label) for the String Value. READ-ONLY
     */
    @objc dynamic var stringKey: String {
        return keys[_Indexes.string.rawValue]
    }

    /* ################################################################## */
    /**
     The Array<String> Value. READ-WRITE
     */
    @objc dynamic var array: [String] {
        get {
            return values[keys[_Indexes.array.rawValue]] as? [String] ?? []
        }
        
        set {
            return values[keys[_Indexes.array.rawValue]] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The Key (the Label) for the Array Value. READ-ONLY
     */
    @objc dynamic var arrayKey: String {
        return keys[_Indexes.array.rawValue]
    }

    /* ################################################################## */
    /**
     The Dictionary<String, String> Value. READ-WRITE
     */
    @objc dynamic var dictionary: [String: String] {
        get {
            return values[keys[_Indexes.dictionary.rawValue]] as? [String: String] ?? [:]
        }
        
        set {
            return values[keys[_Indexes.dictionary.rawValue]] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The Key (the Label) for the Dictionary Value. READ-ONLY
     */
    @objc dynamic var dictionaryKey: String {
        return keys[_Indexes.dictionary.rawValue]
    }

    /* ################################################################## */
    /**
     The Date Value. READ-WRITE
     */
    @objc dynamic var date: Date {
        get {
            return values[keys[_Indexes.date.rawValue]] as? Date ?? Date()
        }
        
        set {
            return values[keys[_Indexes.date.rawValue]] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The Key (the Label) for the Date Value. READ-ONLY
     */
    @objc dynamic var dateKey: String {
        return keys[_Indexes.date.rawValue]
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     The keyed initializer. It sends in our default values, if there were no previous ones. Bit primitive, but this is for test harnesses.
     */
    init(key inKey: String) {
        super.init(key: inKey)  // Start by initializing with the key. This will load any asved values.
        if values.isEmpty { // If we didn't already have something, we send in our defaults.
            values = type(of: self)._myValues
        }
    }
}
