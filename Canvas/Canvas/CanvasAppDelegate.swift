//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit
import TooLegit
import TechDebt
import PSPDFKit
import SoPretty
import SoLazy
import SoPersistent
import SoEdventurous
import CanvasKeymaster

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if unitTesting {
            return true
        }

        makeAWindow()
        postLaunchSetup()
        prepareTheKeymaster()
        
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        if url.scheme == "file" {
            do {
                try ReceivedFilesViewController.addToReceivedFiles(url)
                return true
            } catch let e as NSError {
                handleError(e)
            }
        } else if url.scheme == "canvas-courses" {
            return openCanvasURL(url)
        } else if handleDropboxOpenURL(url) {
            return true
        }
        
        return false
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return self.application(application, handleOpenURL: url)
    }
}

// MARK: Push notifications
extension AppDelegate {

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        #if !arch(i386) && !arch(x86_64)
            application.registerForRemoteNotifications()
        #endif
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        didRegisterForRemoteNotifications(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        didFailToRegisterForRemoteNotifications(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        app(application, didReceiveRemoteNotification: userInfo)
    }
    
}

// MARK: Local notifications
extension AppDelegate {
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if let assignmentURL = (notification.userInfo?[CBILocalNotificationAssignmentURLKey] as? String).flatMap({ NSURL(string: $0) }) {
            openCanvasURL(assignmentURL)
        }
    }
}

// MARK: Post launch setup
extension AppDelegate {
    func makeAWindow() {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.makeKeyAndVisible()
    }
    
    func postLaunchSetup() {
        PSPDFKit.license()
        Crashlytics.prepare()
        Analytics.prepare()
        NetworkMonitor.engage()
        CBILogger.install(LoginConfiguration.sharedConfiguration.logFileManager)
        Brand.current().apply(self.window!)
        UINavigationBar.appearance().barStyle = .Black
        Router.sharedRouter().addCanvasRoutes(handleError)
        setupDefaultErrorHandling()
    }
}

// MARK: Logging in/out
extension AppDelegate {
    
    func prepareTheKeymaster() {
        TheKeymaster.delegate = LoginConfiguration.sharedConfiguration

        Session.logoutSignalProducer
            .on(failed: handleError)
            .startWithNext(didLogout)
        
        Session.loginSignalProducer
            .on(failed: handleError)
            .startWithNext(didLogin)
    }
    
    func didLogin(session: Session) {

        LegacyModuleProgressShim.observeProgress(session)
        ModuleItem.beginObservingProgress(session)
        Crashlytics.setDebugInformation()
        ConversationUpdater.sharedConversationUpdater().updateUnreadConversationCount()
        CKCanvasAPI.updateCurrentAPI() // set's currenAPI from CKIClient.currentClient()
        
        let root = rootViewController(session)
        addClearCacheGesture(root.view)

        window?.rootViewController = root
    }
    
    func didLogout(domainPicker: UIViewController) {
        window?.rootViewController = domainPicker
    }
    
    func addClearCacheGesture(view: UIView) {
        let clearCacheGesture = UITapGestureRecognizer(target: self, action: #selector(clearCache))
        clearCacheGesture.numberOfTapsRequired = 3
        clearCacheGesture.numberOfTouchesRequired = 4
        view.addGestureRecognizer(clearCacheGesture)
    }
    
    func clearCache() {
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        let alert = UIAlertController(title: NSLocalizedString("Cache cleared", comment: ""), message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .Default, handler: nil))
        window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: SoErroneous
extension AppDelegate {
    
    func presentErrorAlert(presentingViewController: UIViewController, error: NSError) {
        error.presentAlertFromViewController(presentingViewController, reportError: {
            let support = SupportTicketViewController.presentFromViewController(presentingViewController, supportTicketType: SupportTicketTypeProblem)
            support.initialTicketBody = error.reportDescription
        })
    }
    
    func setupDefaultErrorHandling() {
        TableViewController.defaultErrorHandler = presentErrorAlert
        CollectionViewController.defaultErrorHandler = presentErrorAlert
        
        SoLazy.ErrorReporter.setErrorHandler({ error, userInfo in 
            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: userInfo)
        })
    }
    
    var visibleController: UIViewController {
        guard var vc = window?.rootViewController else { ❨╯°□°❩╯⌢"No root view controller?!" }
        
        while vc.presentedViewController != nil {
            vc = vc.presentedViewController!
        }
        return vc
    }
    
    func handleError(error: NSError) {
        if let vc = window?.rootViewController  {
            presentErrorAlert(vc, error: error)
        }
    }
}


// MARK: Launching URLS
extension AppDelegate {
    func openCanvasURL(url: NSURL) -> Bool {
    
        if url.scheme == "canvas-courses" {
            Router.sharedRouter().openCanvasURL(url)
            return true
        }
        
        if url.scheme == "file" {
            do {
                try ReceivedFilesViewController.addToReceivedFiles(url)
                return true
            } catch let e as NSError {
                handleError(e)
                return false
            }
        }
        
        if handleDropboxOpenURL(url) {
            return true
        }
        
        Router.sharedRouter().openCanvasURL(url)
        return true
    }
}
