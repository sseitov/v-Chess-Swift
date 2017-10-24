//
//  AppDelegate.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 12.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import SVProgressHUD
import IQKeyboardManager
import GoogleSignIn
import FBSDKLoginKit

func IS_PAD() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

func navBarHeight() -> CGFloat {
    if IS_PAD() {
        return  64
    } else {
        return UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) ? 30 : 64
    }
}

var mainController:MainController?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // Register_for_notifications
        // Register_for_notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                
                guard error == nil else {
                    print("============ Display Error.. Handle Error.. etc..")
                    return
                }
                
                if granted {
                    DispatchQueue.main.async {
                        //Register for RemoteNotifications. Your Remote Notifications can display alerts now :)
                        application.registerForRemoteNotifications()
                    }
                }
                else {
                    print("======== user denying permissions..")
                }
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }

        Messaging.messaging().delegate = self
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(MainColor)
        SVProgressHUD.setForegroundColor(UIColor.white)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font : UIFont.condensedFont()], for: .normal)
        SVProgressHUD.setFont(UIFont.condensedFont())
        
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        StorageManager.shared().initUserPackages()
        
        mainController = window?.rootViewController as? MainController
        
        return true
    }
    
    // MARK: - Application delegate
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme! == FACEBOOK_SCHEME {
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        } else {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication: options[.sourceApplication] as! String!,
                                                     annotation: options[.annotation])
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
            Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
        #else
            Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
        #endif
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}

// MARK: - NotificationCenter delegate

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    private func sendNotificationFor(_ userInfo:[AnyHashable : Any]) {
        if let pushTypeStr = userInfo["pushType"] as? String, let pushType = Int(pushTypeStr), let push = GamePush(rawValue: pushType)  {
            NotificationCenter.default.post(name: gameNotification, object: push, userInfo: userInfo)
        }
    }
    
    // in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        sendNotificationFor(notification.request.content.userInfo)
    }

    // from background
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        sendNotificationFor(response.notification.request.content.userInfo)
    }
}

extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        Messaging.messaging().shouldEstablishDirectChannel = true
        if let currUser = currentUser() {
            Model.shared.publishToken(currUser, token: fcmToken)
        }
    }
}

