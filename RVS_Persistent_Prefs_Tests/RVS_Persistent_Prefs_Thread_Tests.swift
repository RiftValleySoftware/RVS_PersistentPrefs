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

import XCTest

/* ################################################################################################################################## */
// MARK: - Tests for the Persistent Prefs.
/* ################################################################################################################################## */
/**
 */
class RVS_Persistent_Prefs_Thread_Tests: XCTestCase {
    /* ############################################################################################################################## */
    // This is a non-Codable class.
    /* ############################################################################################################################## */
    /**
     */
    class NonCodableClass {
        let value = "Hello World"
    }
    
    /* ############################################################################################################################## */
    // This is a non-Codable struct.
    /* ############################################################################################################################## */
    /**
     */
    struct NonCodableStruct {
        let value = "Hello World"
    }
    
    /* ############################################################################################################################## */
    // This is a non-Codable enum.
    /* ############################################################################################################################## */
    /**
     */
    enum NonCodableEnum: String {
        case value = "Hello World"
    }
    
    /* ############################################################################################################################## */
    // MARK: - Embedded Class for Testing Several Simple Data Types
    /* ############################################################################################################################## */
    /**
     */
    class MixedSimpleTypeTestClass: RVS_PersistentPrefs {
        /* ################################################################## */
        /**
         These are the keys for our saved data.
         */
        override public var keys: [String] {
            // These are all the types that we will be testing against.
            return ["Int", "String", "Float", "Double", "Bool", "CodableArray", "CodableDictionary", "NonCodableClass", "NonCodableStruct", "NonCodableEnum", "IllegalBuriedHere"]
        }
        
        /* ################################################################## */
        /**
         This is an Int value
         */
        var int: Int {
            get {
                let ret = values["Int"] as? Int
                return ret ?? 0
            }
            
            set {
                values["Int"] = newValue
            }
        }
        
        /* ################################################################## */
        /**
         This is a String value
         */
        var string: String {
            get {
                let ret = values["String"] as? String
                return ret ?? ""
            }
            
            set {
                values["String"] = newValue
            }
        }
        
        /* ################################################################## */
        /**
         This is a Float value
         */
        var float: Float {
            get {
                print("Values for \"\(key)\": \(String(describing: values))")
                let ret = values["Float"] as? Float
                return ret ?? Float.nan
            }
            
            set {
                values["Float"] = newValue
            }
        }
        
        /* ################################################################## */
        /**
         This is a Double value
         */
        var double: Double {
            get {
                let ret = values["Double"] as? Double
                return ret ?? Double.nan
            }
            
            set {
                values["Double"] = newValue
            }
        }
        
        /* ################################################################## */
        /**
         This is a Bool value
         */
        var bool: Bool {
            get {
                let ret = values["Bool"] as? Bool
                return ret ?? false
            }
            
            set {
                values["Bool"] = newValue
            }
        }

        /* ################################################################## */
        /**
         This ia a Codable Array (of Int)
         */
        var codableArray: [Int] {
            get {
                let ret = values["CodableArray"] as? [Int]
                return ret ?? []
            }
            
            set {
                values["CodableArray"] = newValue
            }
        }
        
        /* ################################################################## */
        /**
         This is a Codable Dictionary (of String: Int).
         */
        var codableDictionary: [String: Int] {
            get {
                let ret = values["CodableDictionary"] as? [String: Int]
                return ret ?? [:]
            }
            
            set {
                values["CodableDictionary"] = newValue
            }
        }
        
        /* ################################################################## */
        /**
         The main initializer. This will initialize the superclass with our preset values.
         All parameters are optional.
         - parameter key: The storage key for this instance.
         - parameter int: An integer value.
         - parameter string: A String Value.
         - parameter float: A Float value.
         - parameter double: A Double value.
         - parameter bool: A Bool value.
         - parameter codableArray: An Array of Int.
         - parameter codableDictionary: A Dictionary of [String: Int].
         */
        init(key inKey: String! = nil, int inInt: Int! = nil, string inString: String! = nil, float inFloat: Float! = nil, double inDouble: Double! = nil, bool inBool: Bool! = nil, codableArray inCodableArray: [Int]! = nil, codableDictionary inCodableDictionary: [String: Int]! = nil) {
            // Set up an initial values Dictionary to initialize the instance.
            var values: [String: Any] = [:]
            
            if let inInt = inInt {
                values["Int"] = inInt
            }
            
            if let inString = inString {
                values["String"] = inString
            }
            
            if let inFloat = inFloat {
                values["Float"] = inFloat
            }
            
            if let inDouble = inDouble {
                values["Double"] = inDouble
            }
            
            if let inBool = inBool {
                values["Bool"] = inBool
            }
            
            if let inCodableArray = inCodableArray {
                values["CodableArray"] = inCodableArray
            }
            
            if let inCodableDictionary = inCodableDictionary {
                values["CodableDictionary"] = inCodableDictionary
            }

            super.init(key: inKey, values: values)
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
        override public init(key inKey: String! = nil, values inValues: [String: Any]! = [:]) {
            super.init(key: inKey, values: inValues)
        }
    }

    /* ################################################################## */
    /**
     */
    func testThreading() {
        let testKey = "testThreading-1"   // The prefs key that we'll be using for this test.
        
        // What we do here, is create a throwaway instance that exists only to make sure that some defaults are set.
        let initialSet: [String: Any] = ["Int": 1, "String": "One", "Double": Double(2.0), "Float": Float(10.0), "Bool": false, "CodableArray": [3, 4, 5], "CodableDictionary": ["One": 1, "Two": 2, "3": 3]]
        _ = MixedSimpleTypeTestClass(key: testKey, values: initialSet)
        
        // Set up a new instance. It should have all the ones in the initial set.
        let testTarget0 = MixedSimpleTypeTestClass(key: testKey)
        XCTAssertNil(testTarget0.lastError)
        XCTAssertEqual(1, testTarget0.int)
        XCTAssertEqual("One", testTarget0.string)
        XCTAssertEqual(Double(2.0), testTarget0.double)
        XCTAssertEqual(Float(10.0), testTarget0.float)
        XCTAssertEqual(false, testTarget0.bool)
        XCTAssertEqual([3, 4, 5], testTarget0.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "3": 3], testTarget0.codableDictionary)
    }
}
