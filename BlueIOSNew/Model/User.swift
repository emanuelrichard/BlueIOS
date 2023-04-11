//
//  User.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit

class User {
    
    var name: String = ""
    var email: String = ""
    var pswd: String = ""
    var os: String = "\(UIDevice.current.systemVersion)@iOS"
    
    func updateOS() {
        self.os = "\(UIDevice.current.systemVersion)@iOS"
    }
    
    func initFromDict(dict: Dictionary<String, AnyObject>) {
        for (key, value) in dict {
            switch key {
            case "name":
                self.name = "\(value)"
            case "email":
                self.email = "\(value)"
            case "pswd":
                self.pswd = "\(value)"
            case "os":
                self.os = "\(value)"
            default:
                break
            }
        }
    }
    
}
