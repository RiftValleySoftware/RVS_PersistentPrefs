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

import UIKit
import WatchConnectivity

/* ################################################################################################################################## */
// MARK: - Main Application Delegate Class
/* ################################################################################################################################## */
/**
 The main application delegate class. It simply give the window a place to hang its hat, and registers the app defaults.
 */
@UIApplicationMain
class RVS_PersistentPrefs_iOS_TestHarness_AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    /* ############################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ############################################################################################################################## */

    /* ############################################################################################################################## */
    // MARK: - Private Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private func _activateSession() {
        if  WCSession.isSupported(),
            .activated != session.activationState {
            session.delegate = self
            session.activate()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @objc private func _sendCurrentSettingsToWatch() {
        DispatchQueue.main.async {  // Must happen in the main thread, as we access the View Controller.
            if  .activated == self.session.activationState,
                let mainController = self.window?.rootViewController as? RVS_PersistentPrefs_iOS_TestHarness_ViewController {
                let values = mainController.prefs.values
                #if DEBUG
                    print("Sending Prefs to Watch: " + String(describing: values))
                #endif
                self.session.sendMessage(values, replyHandler: self._replyHandler, errorHandler: self._errorHandler)
            } else {
                
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _replyHandler(_ inReply: [String: Any]) {
        #if DEBUG
            print("Reply From Watch: " + String(describing: inReply))
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    private func _errorHandler(_ inError: Error) {
        #if DEBUG
            print("Error From Watch: " + String(describing: inError))
        #endif
    }

    /* ############################################################################################################################## */
    // MARK: - Static Constants
    /* ############################################################################################################################## */
    /// The main prefs key.
    static let prefsKey = "RVS_PersistentPrefs_iOS_TestHarness_Prefs"
    
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /// The app window.
    var window: UIWindow?

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var session: WCSession! {
        return WCSession.default
    }
    
    /* ############################################################################################################################## */
    // MARK: - UIApplicationDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _activateSession()
        return true
    }

    /* ############################################################################################################################## */
    // MARK: - WCSessionDelegate Protocol Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func session(_ inSession: WCSession, activationDidCompleteWith inActivationState: WCSessionActivationState, error inError: Error?) {
        if .activated == inActivationState {
            #if DEBUG
                print("Watch session is active.")
            #endif
            _sendCurrentSettingsToWatch()   // The first thing that we do, is send whatever we have to the watch, so it is in sync. We always trump the watch.
            // This will cause the send to watch method to be called whenever we update the defaults. Primitive, but it works.
            NotificationCenter.default.addObserver(self, selector: #selector(_sendCurrentSettingsToWatch), name: UserDefaults.didChangeNotification, object: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidBecomeInactive(_ inSession: WCSession) {
        #if DEBUG
            print("Watch session is inactive.")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidDeactivate(_ inSession: WCSession) {
        #if DEBUG
            print("Watch session deactivated.")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ inSession: WCSession, didReceiveMessage inMessage: [String: Any], replyHandler inReplyHandler: @escaping ([String: Any]) -> Void) {
        #if DEBUG
            print("\n###\nBEGIN Phone Received Message: " + String(describing: inMessage))
        #endif
        
        if let mainController = window?.rootViewController as? RVS_PersistentPrefs_iOS_TestHarness_ViewController {
            mainController.prefs.values = inMessage
            inReplyHandler([s_watchPhoneReplySuccessKey: true])
        } else {
            inReplyHandler([s_watchPhoneReplySuccessKey: false])
        }

        #if DEBUG
            print("###\nEND Phone Received Message\n")
        #endif
    }
}
