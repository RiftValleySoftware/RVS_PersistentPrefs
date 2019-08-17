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
     Test a simple, one-after-the-other timer set in the run loop.
     */
    func testSimpleLinearRunLoopThreading() {
        let testKey = "testSimpleLinearRunLoopThreading-1"   // The prefs key that we'll be using for this test.
        
        // What we do here, is create a throwaway instance that exists only to make sure that some defaults are set.
        let initialSet: [String: Any] = ["Int": 10, "String": "Ten", "Double": Double(10.0), "Float": Float(10.0), "Bool": false, "CodableArray": [10], "CodableDictionary": ["Ten": 10]]
        _ = MixedSimpleTypeTestClass(key: testKey, values: initialSet)
        
        // Set up a new instance. It should have all the ones in the initial set.
        let testTarget0 = MixedSimpleTypeTestClass(key: testKey)
        XCTAssertNil(testTarget0.lastError)
        XCTAssertEqual(10, testTarget0.int)
        XCTAssertEqual("Ten", testTarget0.string)
        XCTAssertEqual(Double(10.0), testTarget0.double)
        XCTAssertEqual(Float(10.0), testTarget0.float)
        XCTAssertEqual(false, testTarget0.bool)
        XCTAssertEqual([10], testTarget0.codableArray)
        XCTAssertEqual(["Ten": 10], testTarget0.codableDictionary)
        
        let expectationsArePremeditatedResenments = XCTestExpectation(description: "Wait For All Threads to Complete")
        
        expectationsArePremeditatedResenments.expectedFulfillmentCount = 2

        /* ############################################################# */
        /**
         This will set the variables for the next iteration, then kick that off.
         */
        func timer1CallBack(_ inTimer: Timer) {
            print("Timer 1 Callback!")
            XCTAssertNil(testTarget0.lastError)
            XCTAssertEqual(10, testTarget0.int)
            XCTAssertEqual("Ten", testTarget0.string)
            XCTAssertEqual(Double(10.0), testTarget0.double)
            XCTAssertEqual(Float(10.0), testTarget0.float)
            XCTAssertEqual(false, testTarget0.bool)
            XCTAssertEqual([10], testTarget0.codableArray)
            XCTAssertEqual(["Ten": 10], testTarget0.codableDictionary)

            testTarget0.int = 1
            testTarget0.bool = true
            testTarget0.string = "One"
            testTarget0.double = Double(1.0)
            testTarget0.float = Float(1.0)
            testTarget0.codableArray = [1]
            testTarget0.codableDictionary = ["One": 1]
            expectationsArePremeditatedResenments.fulfill()
            _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: timer2CallBack)
        }
        
        /* ############################################################# */
        /**
         This will set the final state.
         */
        func timer2CallBack(_ inTimer: Timer) {
            print("Timer 2 Callback!")
            XCTAssertNil(testTarget0.lastError)
            XCTAssertEqual(1, testTarget0.int)
            XCTAssertEqual("One", testTarget0.string)
            XCTAssertEqual(Double(1.0), testTarget0.double)
            XCTAssertEqual(Float(1.0), testTarget0.float)
            XCTAssertEqual(true, testTarget0.bool)
            XCTAssertEqual([1], testTarget0.codableArray)
            XCTAssertEqual(["One": 1], testTarget0.codableDictionary)

            testTarget0.int = 2
            testTarget0.bool = false
            testTarget0.string = "Two"
            testTarget0.double = Double(2.0)
            testTarget0.float = Float(2.0)
            testTarget0.codableArray = [2]
            testTarget0.codableDictionary = ["Two": 2]
            expectationsArePremeditatedResenments.fulfill()
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: timer1CallBack)

        wait(for: [expectationsArePremeditatedResenments], timeout: 1)
        
        XCTAssertNil(testTarget0.lastError)
        XCTAssertEqual(2, testTarget0.int)
        XCTAssertEqual("Two", testTarget0.string)
        XCTAssertEqual(Double(2.0), testTarget0.double)
        XCTAssertEqual(Float(2.0), testTarget0.float)
        XCTAssertEqual(false, testTarget0.bool)
        XCTAssertEqual([2], testTarget0.codableArray)
        XCTAssertEqual(["Two": 2], testTarget0.codableDictionary)
    }

    /* ################################################################## */
    /**
     Test with a bunch of NSOperations. Bit hairier.
     
     THIS WILL FAIL. It may work for a few times, but it will eventually crash in a dealloc, as the dealloc happens in a different thread than the original allocation.
     
     This class IS NOT THREAD-SAFE.
     */
//    func testOperationThreading() {
//        let taskCount = 7
//        let testKey = "testOperationThreading-1"   // The prefs key that we'll be using for this test.
//
//        // What we do here, is create a throwaway instance that exists only to make sure that some defaults are set.
//        let initialSet: [String: Any] = ["Int": 10, "String": "Ten", "Double": Double(10.0), "Float": Float(10.0), "Bool": false, "CodableArray": [10], "CodableDictionary": ["Ten": 10]]
//        _ = MixedSimpleTypeTestClass(key: testKey, values: initialSet)
//
//        // Set up a new instance. It should have all the ones in the initial set.
//        let testTarget0 = MixedSimpleTypeTestClass(key: testKey)
//        XCTAssertNil(testTarget0.lastError)
//        XCTAssertEqual(10, testTarget0.int)
//        XCTAssertEqual("Ten", testTarget0.string)
//        XCTAssertEqual(Double(10.0), testTarget0.double)
//        XCTAssertEqual(Float(10.0), testTarget0.float)
//        XCTAssertEqual(false, testTarget0.bool)
//        XCTAssertEqual([10], testTarget0.codableArray)
//        XCTAssertEqual(["Ten": 10], testTarget0.codableDictionary)
//
//        let expectationsArePremeditatedResenments = XCTestExpectation(description: "Wait For All Threads to Complete")
//
//        expectationsArePremeditatedResenments.expectedFulfillmentCount = taskCount * 4
//
//        class SetIntegers: Operation {
//            let threadName: String
//            let index: Int
//            let list: [Int]
//            let target: MixedSimpleTypeTestClass
//            let expectation: XCTestExpectation
//
//            init(_ inList: [Int], index inIndex: Int = 0, target inTarget: MixedSimpleTypeTestClass, expectation inExpectation: XCTestExpectation, threadName inName: String) {
//                list = inList
//                index = inIndex
//                target = inTarget
//                expectation = inExpectation
//                threadName = inName
//            }
//
//            override func main() {
//                guard 0 < list.count else {
//                    XCTFail("No Data!")
//                    return
//                }
//                guard !isCancelled else { return }
//                let indexVal = index % list.count
//                guard !isCancelled else { return }
//                let value = list[indexVal]
//                expectation.fulfill()
//                target["Int"] = value
//                expectation.fulfill()
//            }
//        }
//
//        class SetStrings: Operation {
//            let threadName: String
//            let index: Int
//            let list: [String]
//            let target: MixedSimpleTypeTestClass
//            let expectation: XCTestExpectation
//
//            init(_ inList: [String], index inIndex: Int = 0, target inTarget: MixedSimpleTypeTestClass, expectation inExpectation: XCTestExpectation, threadName inName: String) {
//                list = inList
//                index = inIndex
//                target = inTarget
//                expectation = inExpectation
//                threadName = inName
//            }
//
//            override func main() {
//                guard 0 < list.count else {
//                    XCTFail("No Data!")
//                    return
//                }
//                guard !isCancelled else { return }
//                let indexVal = index % list.count
//                let value = "My name is \(list[indexVal])"
//                target["String"] = value
//                expectation.fulfill()
//                guard !isCancelled else { return }
//            }
//        }
//
//        // Set up a couple of NSOperations for the testing.
//        class RunningOperations {
//            lazy var currentOperations: [IndexPath: Operation] = [:]
//            lazy var testSet0Queue: OperationQueue = {
//                var queue = OperationQueue()
//                return queue
//            }()
//
//            lazy var testSet1Queue: OperationQueue = {
//                var queue = OperationQueue()
//                return queue
//            }()
//        }
//
//        let runningOperations = RunningOperations()
//
//        for index in 0..<taskCount {
//            runningOperations.testSet0Queue.addOperation(SetIntegers([0, 1, 2, 3, 4], index: index, target: testTarget0, expectation: expectationsArePremeditatedResenments, threadName: "Int 0"))
//            runningOperations.testSet0Queue.addOperation(SetStrings(["Fred", "Marsha", "Inigo Montaya", "Bilbo", "Bond, James Bond"], index: index, target: testTarget0, expectation: expectationsArePremeditatedResenments, threadName: "String 0"))
//            runningOperations.testSet1Queue.addOperation(SetIntegers([5, 6, 7, 8, 9], index: index, target: testTarget0, expectation: expectationsArePremeditatedResenments, threadName: "Int 1"))
//            runningOperations.testSet1Queue.addOperation(SetStrings(["Barbra", "Helen", "Starr", "Annie", "Debbie"], index: index, target: testTarget0, expectation: expectationsArePremeditatedResenments, threadName: "String 1"))
//        }
//
//        wait(for: [expectationsArePremeditatedResenments], timeout: 10)
//
//        runningOperations.testSet0Queue.cancelAllOperations()
//    }
}
