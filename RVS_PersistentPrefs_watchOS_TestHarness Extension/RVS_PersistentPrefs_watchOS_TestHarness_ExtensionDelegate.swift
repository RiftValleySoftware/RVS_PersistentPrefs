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
import WatchConnectivity

/* ################################################################################################################################## */
// MARK: -
/* ################################################################################################################################## */
/**
 */
class RVS_PersistentPrefs_watchOS_TestHarness_ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    /* ############################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ############################################################################################################################## */
    /// This is a semaphore (ick) that indicates we are currently sending an update to the Watch.
    private var _sendingUpdateToPhone = false

    /* ############################################################################################################################## */
    // MARK: - Private Methods
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
    @objc private func _sendCurrentSettingsToPhone() {
        if  !_sendingUpdateToPhone,
            .activated == session.activationState {
            let values = prefs.values
            #if DEBUG
                print("Sending Prefs to Phone: " + String(describing: values))
            #endif
            _sendingUpdateToPhone = true
            self.session.sendMessage(values, replyHandler: _replyHandler, errorHandler: _errorHandler)
        } else {
            
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _replyHandler(_ inReply: [String: Any]) {
        #if DEBUG
            print("Reply From Phone: " + String(describing: inReply))
        #endif
        _sendingUpdateToPhone = false
    }
    
    /* ################################################################## */
    /**
     */
    private func _errorHandler(_ inError: Error) {
        #if DEBUG
            print("Error From Phone: " + String(describing: inError))
        #endif
        _sendingUpdateToPhone = false
    }

    /* ############################################################################################################################## */
    // MARK: - Static Constants
    /* ############################################################################################################################## */
    /// The main prefs key.
    static let prefsKey = "RVS_PersistentPrefs_iOS_TestHarness_Prefs"
    
    /* ############################################################################################################################## */
    // MARK: - Class Variables
    /* ############################################################################################################################## */
    /// The delegate object (quick accessor).
    class var delegateObject: RVS_PersistentPrefs_watchOS_TestHarness_ExtensionDelegate! {
        return WKExtension.shared().delegate as? RVS_PersistentPrefs_watchOS_TestHarness_ExtensionDelegate
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /// This is the preferences object.
    var prefs = RVS_PersistentPrefs_TestSet(key: prefsKey)

    /* ############################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Accessor for our session (the default).
     */
    var session: WCSession {
        return WCSession.default
    }

    /* ############################################################################################################################## */
    // MARK: - WKExtensionDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func applicationDidFinishLaunching() {
        _activateSession()
    }

    /* ################################################################## */
    /**
     */
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    /* ################################################################## */
    /**
     */
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    /* ################################################################## */
    /**
     */
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - WCSessionDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func session(_ inSession: WCSession, activationDidCompleteWith inActivationState: WCSessionActivationState, error inError: Error?) {
        #if DEBUG
            print("Watch Activation Complete: " + String(describing: inActivationState))
        #endif
        _sendCurrentSettingsToPhone()
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ inSession: WCSession, didReceiveMessage inMessage: [String: Any], replyHandler inReplyHandler: @escaping ([String: Any]) -> Void) {
        #if DEBUG
            print("\n###\nBEGIN Watch Received Message: " + String(describing: inMessage))
        #endif
        prefs.values = inMessage
        inReplyHandler([s_watchPhoneReplySuccessKey: true])
        if let controller = WKExtension.shared().rootInterfaceController as? RVS_PersistentPrefs_watchOS_TestHarness_InterfaceController {
            controller.setUpLabels()
        }
        #if DEBUG
            print("###\nEND Watch Received Message\n")
        #endif
    }
}
