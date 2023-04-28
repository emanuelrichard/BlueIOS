//
//  AppDelegate.swift
//  BlueIOS
//
//  Created by Opportunity on 20/03/23.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    var window : UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Confirm Delegete and request for permission
        notificationCenter.delegate = self
        UIApplication.shared.delegate = self
        
        // Firebase notifications
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 Display notification (sent via APNs)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        Messaging.messaging().subscribe(toTopic: "BLUE_ALL") { error in
            print("Subscribed to BLUE_ALL")
        }
        
        IQKeyboardManager.shared.enable = true
        UIApplication.shared.applicationIconBadgeNumber = 0

        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        var target_tub = " Banheira"
        if let mac = userInfo["mac"] as? String, let db = RealmDB.it {
            let tubs = db.objects(Tub.self)
            target_tub = tubs.first(where: { Utils.getMqttId(pub: $0.mqtt_pub, sub: $0.mqtt_sub) == mac })?.tub_name ?? target_tub
            
            // If no tubname was found, we should unsubscribe from tub notifications
            if(target_tub == " Banheira") {
                print("Unsubscribing from \(mac)")
                Notifications.unsubscribeToRemoteNotifications(topic: mac)
                return
            }
            
            if let about = userInfo["about"] as? String {
                Settings.inititate()
                if(about == "LEVEL") {
                    Notifications.notify(title: "\(target_tub) em nível máximo", message: "A banheira já se encontra cheia", reason: BathTubFeedbacks.LEVEL_STATE, identifier: "\(mac)_LEVEL", remote: true)
                }
                if(about == "TEMP") {
                    Notifications.notify(title: "\(target_tub) na temperatura desejada", message: "A banheira já se encontra na temperatura desejada", reason: BathTubFeedbacks.TEMP_NOW, identifier: "\(mac)_TEMP", remote: true)
                }
            }
        }
        
        completionHandler(.newData)
    }
    
    // Handle Notification Center Delegate methods
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }
        completionHandler()
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //Bloqueio de rotacao de tela
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
}


