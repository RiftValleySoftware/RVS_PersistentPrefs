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
open class RVS_Base_PersistentPrefs: NSObject {
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
     */
    private func _save() {
        #if DEBUG
            print("Saving Prefs: \(String(describing: _values))")
        #endif
        
        UserDefaults.standard.set(_values, forKey: key)
    }
    
    /* ################################################################## */
    /**
     This is a private method that reads in the data from persistent storage for this instance (using the "key" property), and loads the _values Dictionary property.
     */
    private func _load() {
        let standardDefaultsObject = UserDefaults.standard
        
        if let loadedPrefs = standardDefaultsObject.object(forKey: key) as? [String: Any] {
            #if DEBUG
                print("Loaded Prefs: \(String(describing: loadedPrefs))")
            #endif
            
            _values = loadedPrefs
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is the key that is used to store and fetch the collection of data to be used to populate the _values Dictionary.
     */
    public var key: String = ""
    
    /* ############################################################################################################################## */
    // MARK: - Public Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This calculated property MUST be overridden by subclasses. It is an Array of String, containing the keys used to store and retrieve the values from persistent storage.
     */
    public var keys: [String] {
        preconditionFailure("YOU MUST OVERRIDE THIS METHOD")
    }
    
    /* ################################################################## */
    /**
     This is an accessor for the _values Dictionary. Before it returns the Dictionary, it loads data from persistent storage. After it sets the Dictionary, it saves the resulting Dictionary to persistent storage.
     This is meant to make persistent storage completely transparent. You simple read and write the Dictionary, using these accessors. The saving and retrieving happens in the background.
     */
    public var values: [String: Any] {
        get {
            _load()
            return _values
        }
        
        set {
            _values = newValue
            _save()
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
        key = type(of: self).className()
        _load()
    }
    
    /* ################################################################## */
    /**
     You can also initialize it with a key and some initial data values.
     
     - parameter key: Optional (default is nil). A String, with a key to be used to associate the persistent state of this object to storage in the bundle.
        If not provided, the subclass classname is used as the key.
     - parameter values: Optional (default is nil). A Dictionary<String, Any>, with the values to be stored.
        If not provided, then the instance is populated by any persistent prefs.
        If provided, then the persistent prefs are updated with the new values.
     */
    public init(key inKey: String! = nil, values inValues: [String: Any]! = nil) {
        super.init()
        key = inKey ?? type(of: self).className()
        if nil != inValues {
            values = inValues
        } else {
            _load()
        }
    }
}
