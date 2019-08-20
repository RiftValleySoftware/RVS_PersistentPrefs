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

import Cocoa

/* ################################################################################################################################## */
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
/**
 */
class RVS_PersistentPrefs_macOS_TestHarness_ViewController: NSViewController {
    /* ############################################################################################################################## */
    // MARK: - Static Constants
    /* ############################################################################################################################## */
    /// The main prefs key.
    static let prefsKey = "RVS_PersistentPrefs_macOS_TestHarness_Prefs"
    
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /// This is the preferences object. It is instantiated at runtime, and left on its own.
    private var _prefs: RVS_PersistentPrefs_TestSet!
    
    /* ################################################################## */
    /**
     This is a direct accessor to the prefs object for this controller.
     */
    @objc dynamic var prefs: RVS_PersistentPrefs_TestSet {
        return nil == _prefs ? RVS_PersistentPrefs_TestSet(key: RVS_PersistentPrefs_macOS_TestHarness_ViewController.prefsKey) : _prefs
    }

    /* ############################################################################################################################## */
    // MARK: - Instance @IBOutlet Properties
    /* ############################################################################################################################## */
    /// The label for the Integer Value.
    @IBOutlet weak var integerValueLabel: NSTextField!

    /* ############################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     The keys for the Dictionary, as a sorted Array of String
     */
    var dictionaryKeys: [String] {
        return prefs.dictionary.keys.compactMap { $0 }.sorted {
            let desiredOrder = ["One".localizedVariant, "Two".localizedVariant, "Three".localizedVariant, "Four".localizedVariant, "Five".localizedVariant]
            let indexofA = desiredOrder.firstIndex(of: $0.localizedVariant) ?? 0
            let indexofB = desiredOrder.firstIndex(of: $1.localizedVariant) ?? 0
            
            return indexofA < indexofB
        }
    }

    /* ############################################################################################################################## */
    // MARK: -
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        integerValueLabel.stringValue = prefs.keys[0].localizedVariant
    }
}
