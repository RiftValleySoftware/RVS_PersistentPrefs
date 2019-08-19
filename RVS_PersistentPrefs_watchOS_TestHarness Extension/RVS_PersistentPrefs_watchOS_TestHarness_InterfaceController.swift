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

import WatchKit
import Foundation

/* ################################################################################################################################## */
// MARK: - 
/* ################################################################################################################################## */
/**
 */
class RVS_PersistentPrefs_watchOS_TestHarness_InterfaceController: WKInterfaceController {
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var prefs: RVS_PersistentPrefs_TestSet! {
        return RVS_PersistentPrefs_watchOS_TestHarness_ExtensionDelegate.delegateObject?.prefs
    }
    
    /* ############################################################################################################################## */
    // MARK: - @IBOutlet Instance Properties
    /* ############################################################################################################################## */
    @IBOutlet weak var integerKeyLabel: WKInterfaceLabel!
    @IBOutlet weak var integerValueLabel: WKInterfaceLabel!
    @IBOutlet weak var stringKeyLabel: WKInterfaceLabel!
    @IBOutlet weak var stringValueLabel: WKInterfaceLabel!

    /* ############################################################################################################################## */
    // MARK: - Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func setUpLabels() {
        DispatchQueue.main.async {
            self.prefs?.keys.forEach { key in
                switch key {
                case "Integer Value":
                    if let value = self.prefs[key] as? Int {
                        self.integerKeyLabel?.setText(key.localizedVariant)
                        self.integerValueLabel?.setText(String(value))
                    } else {
                        self.integerKeyLabel?.setText("ERROR!")
                        self.integerValueLabel?.setText("ERROR!")
                    }
                case "String Value":
                    if let value = self.prefs[key] as? String {
                        self.stringKeyLabel?.setText(key.localizedVariant)
                        self.stringValueLabel?.setText(String(value))
                    } else {
                        self.stringKeyLabel?.setText("ERROR!")
                        self.stringValueLabel?.setText("ERROR!")
                    }
                default:
                    ()
                }
            }
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setUpLabels()
    }
    
    /* ################################################################## */
    /**
     */
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    /* ################################################################## */
    /**
     */
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
