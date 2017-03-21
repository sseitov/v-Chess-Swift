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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Register_for_notifications
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            UNUserNotificationCenter.current().delegate = self
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // Use Firebase library to configure APIs
        FIRApp.configure()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        
        FIRAuth.auth()?.addStateDidChangeListener({ auth, user in
            if let token = FIRInstanceID.instanceID().token(), let currUser = auth.currentUser {
                Model.shared.publishToken(currUser, token:token)
            }
        })
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.mainColor())
        SVProgressHUD.setForegroundColor(UIColor.white)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : UIFont.condensedFont()], for: .normal)
        SVProgressHUD.setFont(UIFont.condensedFont())
        
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        StorageManager.shared().initUserPackages()
        
        return true
    }
    
    // MARK: - Refresh FCM token
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            connectToFcm()
            if let user = FIRAuth.auth()?.currentUser {
                Model.shared.publishToken(user, token: refreshedToken)
            } else {
                UserDefaults.standard.set(refreshedToken, forKey: "fcmToken")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            }
        }
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
            FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
        #else
            FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.prod)
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
/*
            switch push {
            case .invite:
                NotificationCenter.default.post(name: inviteGameNotification, object: push, userInfo: userInfo)
            case .accept:
                NotificationCenter.default.post(name: acceptGameNotification, object: push, userInfo: userInfo)
            case .reject:
                NotificationCenter.default.post(name: deleteGameNotification, object: push, userInfo: userInfo)
            case .turn:
                NotificationCenter.default.post(name: updateGameNotification, object: push, userInfo: userInfo)
            case .surrender:
                NotificationCenter.default.post(name: deleteGameNotification, object: push, userInfo: userInfo)
            }
 */
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

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
    }
}

