//
//  Tub.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import RealmSwift

class Tub: Object {

    @objc dynamic var BTid: String = ""
    @objc dynamic var tub_pswd1: String = ""
    @objc dynamic var tub_pswd2: String = ""
    @objc dynamic var tub_pswd3: String = ""
    @objc dynamic var tub_pswd4: String = ""
    
    @objc dynamic var wifi_state: String = ""
    @objc dynamic var ip: String = ""
    @objc dynamic var ssid: String = ""
    
    @objc dynamic var mqtt_state: String = ""
    @objc dynamic var mqtt_pub: String = ""
    @objc dynamic var mqtt_sub: String = ""
    
    @objc dynamic var latitude: String = ""
    @objc dynamic var longitude: String = ""
    
    @objc dynamic var tub_name: String = ""
    @objc dynamic var pswd: String = ""
    
    @objc dynamic var date: String = "1970-01-01T00:00:00.000Z"
    @objc dynamic var online: Bool = false
    
    override var description: String {
        return
            "\(BTid)~~\(tub_pswd1)~~\(tub_pswd2)~~\(tub_pswd3)~~\(tub_pswd4)~~\(wifi_state)~~\(ip)~~\(ssid)~~\(mqtt_state)~~\(mqtt_pub)~~\(mqtt_sub)~~\(latitude)~~\(longitude)~~\(tub_name)~~\(pswd)"
    }
    
    override static func primaryKey() -> String? {
            return "BTid"
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        return (object as? Tub)?.BTid == self.BTid
    }
    
    static func initFromSettings() -> Tub? {
        if(Settings.last_BTid.isEmpty ||
            Settings.mqtt_pub.isEmpty ||
            Settings.mqtt_sub.isEmpty) {
            return nil
        }
        
        let tub = Tub()
        tub.BTid = Settings.last_BTid
        tub.tub_pswd1 = Settings.tub_pswd1
        tub.tub_pswd2 = Settings.tub_pswd2
        tub.tub_pswd3 = Settings.tub_pswd3
        tub.tub_pswd4 = Settings.tub_pswd4
        
        tub.wifi_state = String(Settings.wifi_state)
        tub.ip = Settings.ip
        tub.ssid = Settings.ssid
        
        tub.mqtt_state = String(Settings.mqtt_state)
        tub.mqtt_pub = Settings.mqtt_pub
        tub.mqtt_sub = Settings.mqtt_sub
        tub.online = Settings.online
        
        tub.latitude = Settings.loc_lat
        tub.longitude = Settings.loc_lng
        
        tub.tub_name = Settings.tubname
        tub.pswd = Settings.pswd
        let dFormatter = ISO8601DateFormatter()
        dFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        tub.date = dFormatter.string(from: Date())
        
        return tub
    }
    
    static func initFromString(tubstr: String) -> Tub? {
        let param = tubstr.components(separatedBy: "~~")
        if(param.count != 15) { return nil }
        
        let tub = Tub()
        tub.BTid = param[0]
        tub.tub_pswd1 = param[1]
        tub.tub_pswd2 = param[2]
        tub.tub_pswd3 = param[3]
        tub.tub_pswd4 = param[4]
        tub.wifi_state = param[5]
        tub.ip = param[6]
        tub.ssid = param[7]
        tub.mqtt_state = param[8]
        tub.mqtt_pub = param[9]
        tub.mqtt_sub = param[10]
        tub.latitude = param[11]
        tub.longitude = param[12]
        tub.tub_name = param[13]
        tub.pswd = param[14]
        
        return tub
    }
    
    func initFromDict(dict: Dictionary<String, AnyObject>) {
        for (key, value) in dict {
            switch key {
            case "BTid":
                self.BTid = "\(value)"
            case "tubname":
                self.tub_name = "\(value)"
            case "pswd1":
                self.tub_pswd1 = "\(value)"
            case "pswd2":
                self.tub_pswd2 = "\(value)"
            case "pswd3":
                self.tub_pswd3 = "\(value)"
            case "pswd4":
                self.tub_pswd4 = "\(value)"
            case "wifi_state":
                self.wifi_state = "\(value)"
            case "mqtt_state":
                self.mqtt_state = "\(value)"
            case "ip":
                self.ip = "\(value)"
            case "ssid":
                self.ssid = "\(value)"
            case "mqtt_pub":
                self.mqtt_pub = "\(value)"
            case "mqtt_sub":
                self.mqtt_sub = "\(value)"
            case "latitude":
                self.latitude = "\(value)"
            case "longitude":
                self.longitude = "\(value)"
            case "alive":
                self.online = Bool(truncating: value as! NSNumber)
            case "date":
                self.date = "\(value)"
            default:
                print("non-mapped key for -> \(key): \(value)")
                break
            }
        }
    }
    
}
