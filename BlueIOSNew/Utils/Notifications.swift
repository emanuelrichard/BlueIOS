//
//  Notifications.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UserNotifications
import AVFoundation
import MediaPlayer
import FirebaseCore // Importa o módulo do Firebase Core
import FirebaseFirestore // Importa o módulo do Firebase Firestore
import FirebaseMessaging

class Notifications {
    
    private static var firstTimeTemp = true
    private static var canNotifyTemp = true
    
    private static var firstTimeLevel = true
    private static var canNotifyLevel = true
    
    private static var player: AVAudioPlayer?
    private static var currentVolValue: Float = 1.0
    
    static func subscribeToRemoteNotifications(topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            print("Subscribed to \(topic)")
        }
    }
    
    static func unsubscribeToRemoteNotifications(topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            print("Unsubscribed to \(topic)")
        }
    }
    
    static func notify(title: String, message: String, reason: String, identifier: String, remote: Bool = false) {
        
        guard
            shouldNotifyFor(reason: reason, remote: remote)
        else {
            ShouldNotNotifyFor(reason: reason)
            return
        }
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getDeliveredNotifications { (notifications) in
            for n in notifications {
                if(n.request.identifier == identifier) {
                    print(n.request.identifier+" already shown !")
                    return
                }
            }
            
            // Compose New Notification
            let content = UNMutableNotificationContent()
            let categoryIdentifier = "CtrlBanheira"
            content.title = title
            content.body = message
            //content.badge = 1
            content.categoryIdentifier = categoryIdentifier

            // Add a time interval to the notification
            //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

            // Add Action button the Notification
            //let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
            //let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
            let category = UNNotificationCategory(identifier: "Alertas da banheira",
                                                  actions: [],
                                                  intentIdentifiers: [],
                                                  options: [.customDismissAction])
            notificationCenter.setNotificationCategories([category])
            
            playSound()
            notificationCenter.add(request) { (error) in
                if let err = error {
                    print("Error \(err.localizedDescription)")
                }
            }
            
            didFinishNotifyingFor(reason: reason, remote: remote)
        }
    }
 
    private static func playSound() {
        let url = Bundle.main.url(forResource: "water_message", withExtension: "mp3")!
        do {
            let songData = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(data: songData, fileTypeHint: AVFileType.mp3.rawValue)
            guard player != nil else {
                print("PLAYER:: Error on initializing Player")
                return
            }
            
            try AVAudioSession.sharedInstance().setActive(true, options: [])
            
            currentVolValue = AVAudioSession.sharedInstance().outputVolume // save current volume
            ctrlVolume(reset: false)
            
            _ = Timer.scheduledTimer(withTimeInterval: 3.2, repeats: false) { timer in
                stopSound()
            }

        } catch let error as NSError {
            print("DEU RUIM PRA TOCAR !  - " + error.description)
        }
    }
    
    private static func stopSound() {
        if let player = player {
            player.stop()
        } else {
            return
        }
        
        ctrlVolume(reset: true)
    }
    
    private static func ctrlVolume(reset: Bool) {
        if(!reset) {
            
            if let slider = (MPVolumeView().subviews.filter { //[AGT006 - EDT]
                NSStringFromClass($0.classForCoder) == "MPVolumeSlider"
                }.first as? UISlider){
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) { //below 0.5 doesn't work
                    if(Settings.vol_notif >= 0) {
                        slider.setValue(Float(Settings.vol_notif)/10, animated: false) // increase volume to maximum
                    }
                    player?.prepareToPlay()
                    player?.play()
                }
            }
            
        } else {
            
            if currentVolValue == 0.0 {
                currentVolValue = 0.01 // workaround for mute
            }

            // reduce volume back to the previous value:
            if let slider = (MPVolumeView().subviews.filter { //[AGT006 - EDT]
                NSStringFromClass($0.classForCoder) == "MPVolumeSlider"
                }.first as? UISlider){
                if(Settings.vol_notif >= 0) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8){
                        slider.setValue(self.currentVolValue, animated: false) // increase volume to maximum
                    }
                }
            }
            
        }
    }
}

extension Notifications {
    
    private static func shouldNotifyFor(reason: String, remote: Bool) -> Bool {
        let state = UIApplication.shared.applicationState
        if Settings.power == 0 && !remote {
            return false
        }
        if state == .active && !Settings.inApp_notif {
            return false
        }
        
        switch reason {
            case BathTubFeedbacks.TEMP_NOW:
                return (Notifications.canNotifyTemp && (Settings.curr_temp == Settings.desr_temp)) || remote
                
            case BathTubFeedbacks.TEMP_DESIRED:
                Notifications.canNotifyTemp = true
                return false
                
            case BathTubFeedbacks.LEVEL_STATE:
                return (Notifications.canNotifyLevel && (Settings.level == 2)) || remote
                
            default:
                return false
        }
    }
    
    private static func didFinishNotifyingFor(reason: String, remote: Bool) {
        guard !remote else {
            return
        }
        
        switch reason {
            case BathTubFeedbacks.TEMP_NOW:
                Notifications.canNotifyTemp = false
                
            case BathTubFeedbacks.LEVEL_STATE:
                Notifications.canNotifyLevel = false
                
            default:
                return
        }
    }
    
    private static func ShouldNotNotifyFor(reason: String) {
        switch reason {
            case BathTubFeedbacks.TEMP_NOW:
                let delta_temp = abs(Settings.desr_temp - Settings.curr_temp)
                Notifications.canNotifyTemp = delta_temp > 2 ? true : Notifications.canNotifyTemp
                
            case BathTubFeedbacks.TEMP_DESIRED:
                Notifications.canNotifyTemp = true
                
            case BathTubFeedbacks.LEVEL_STATE:
                break
            default:
                break
        }
        
        return
    }
    
}
