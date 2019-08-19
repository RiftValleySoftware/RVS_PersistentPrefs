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
    /// This is the Watch connectivity session.
    private var _mySession: WCSession! = nil

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
        if nil == self._mySession {
            self._mySession = WCSession.default
        }
        
        return self._mySession
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func activateSession() {
        if WCSession.isSupported() && (self.session.activationState != .activated) {
            self._mySession.delegate = self
            self.session.activate()
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - UIApplicationDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.activateSession()
        return true
    }

    /* ############################################################################################################################## */
    // MARK: - WCSession Sender Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func sendCurrentProfileToWatch() {
        let appContext: [String: Any] = [:]
        
        do {
            try self.session.updateApplicationContext(appContext)
        } catch {
            #if DEBUG
                print("Communication Error With Watch: \(error)")
            #endif
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - WCSessionDelegate Protocol Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if .activated == activationState {
            #if DEBUG
                print("Watch session is active.")
            #endif
            self.sendCurrentProfileToWatch()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidBecomeInactive(_ session: WCSession) {
        #if DEBUG
            print("Watch session is inactive.")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidDeactivate(_ session: WCSession) {
        #if DEBUG
            print("Watch session deactivated.")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Phone Received Message: " + String(describing: message))
            #endif
        }
    }
}
