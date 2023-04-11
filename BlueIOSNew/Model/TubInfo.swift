//
//  TubInfo.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import RealmSwift

class TubInfo: Object {

    @objc dynamic var BTid: String = ""
    @objc dynamic var tub_pswd1: String = ""
    @objc dynamic var tub_pswd2: String = ""
    @objc dynamic var tub_pswd3: String = ""
    @objc dynamic var tub_pswd4: String = ""
    @objc dynamic var firmware: String = ""
    @objc dynamic var version: String = ""
    @objc dynamic var n_bombs: Int = 0
    @objc dynamic var has_waterEntry: Int = 0
    @objc dynamic var has_temp: Int = 0
    @objc dynamic var autoOn: Int = 0
    @objc dynamic var has_warmer: Int = 0
    @objc dynamic var has_cromo: Int = 0
    @objc dynamic var temp_off: Int = 0
    @objc dynamic var delay_n1: Int = 0
    @objc dynamic var delay_n2: Int = 0
    @objc dynamic var ag_days: Int = 0
    @objc dynamic var ag_hour: Int = 0
    @objc dynamic var ag_min: Int = 0
    @objc dynamic var ag_time: Int = 0
    @objc dynamic var wifi_state: Int = 0
    @objc dynamic var pswd: String = ""
    @objc dynamic var ssid: String = ""
    @objc dynamic var ip: String = ""
    @objc dynamic var mqtt_state: Int = 0
    @objc dynamic var mqtt_pub: String = ""
    @objc dynamic var mqtt_sub: String = ""
    @objc dynamic var backlight: Int = 0
    @objc dynamic var power: Int = 0
    @objc dynamic var temp: Int = 0
    @objc dynamic var desr_temp: Int = 0
    @objc dynamic var warmer: Int = 0
    @objc dynamic var bomb1: Int = 0
    @objc dynamic var bomb2: Int = 0
    @objc dynamic var bomb3: Int = 0
    @objc dynamic var bomb4: Int = 0
    @objc dynamic var level: Int = 0
    @objc dynamic var n_spot: Int = 0
    @objc dynamic var n_strip: Int = 0
    @objc dynamic var spot_state: Int = 0
    @objc dynamic var spot_static: Int = 0
    @objc dynamic var spot_speed: Int = 0
    @objc dynamic var spot_bright: Int = 0
    @objc dynamic var spots_cmode: Int = 0
    @objc dynamic var strip_state: Int = 0
    @objc dynamic var strip_static: Int = 0
    @objc dynamic var strip_speed: Int = 0
    @objc dynamic var strip_bright: Int = 0
    @objc dynamic var strip_cmode: Int = 0
    
    override static func primaryKey() -> String? {
            return "BTid"
    }
    
    static func initFromSettings() -> TubInfo? {
        if(Settings.last_BTid.isEmpty ||
            Settings.mqtt_pub.isEmpty ||
            Settings.mqtt_sub.isEmpty) {
            return nil
        }
        
        let tubinfo = TubInfo()
        tubinfo.BTid = Settings.BTid
        tubinfo.tub_pswd1 = Settings.tub_pswd1
        tubinfo.tub_pswd2 = Settings.tub_pswd2
        tubinfo.tub_pswd3 = Settings.tub_pswd3
        tubinfo.tub_pswd4 = Settings.tub_pswd4
        tubinfo.firmware = Settings.firmware
        tubinfo.version = Settings.version
        tubinfo.n_bombs = Settings.qt_bombs
        tubinfo.has_waterEntry = Settings.has_waterctrl
        tubinfo.has_temp = Settings.has_temp
        tubinfo.autoOn = Settings.auto_on
        tubinfo.has_warmer = Settings.has_heater
        tubinfo.has_cromo = Settings.has_cromo
        tubinfo.temp_off = Settings.temp_off
        tubinfo.delay_n1 = Settings.delay_n1
        tubinfo.delay_n2 = Settings.delay_n2
        tubinfo.ag_days = Settings.ft_days
        tubinfo.ag_hour = Settings.ft_hour
        tubinfo.ag_min = Settings.ft_min
        tubinfo.ag_time = Settings.ft_time
        tubinfo.wifi_state = Settings.wifi_state
        tubinfo.pswd = Settings.pswd
        tubinfo.ssid = Settings.ssid
        tubinfo.ip = Settings.ip
        tubinfo.mqtt_state = Settings.mqtt_state
        tubinfo.mqtt_pub = Settings.mqtt_pub
        tubinfo.mqtt_sub = Settings.mqtt_sub
        tubinfo.backlight = Settings.backlight
        tubinfo.power = Settings.power
        tubinfo.temp = Settings.curr_temp
        tubinfo.desr_temp = Settings.desr_temp
        tubinfo.warmer = Settings.heater
        tubinfo.bomb1 = Settings.bomb_1
        tubinfo.bomb2 = Settings.bomb_2
        tubinfo.bomb3 = Settings.bomb_3
        tubinfo.bomb4 = Settings.bomb_4
        tubinfo.level = Settings.level
        tubinfo.n_spot = Settings.n_spotleds
        tubinfo.n_strip = Settings.n_stripleds
        tubinfo.spot_state = Settings.spot_state
        tubinfo.spot_static = Settings.spot_static
        tubinfo.spot_speed = Settings.spot_speed
        tubinfo.spot_bright = Settings.spot_bright
        tubinfo.spots_cmode = Settings.spot_cmode
        tubinfo.strip_state = Settings.strip_state
        tubinfo.strip_static = Settings.strip_static
        tubinfo.strip_speed = Settings.strip_speed
        tubinfo.strip_bright = Settings.strip_bright
        tubinfo.strip_cmode = Settings.strip_cmode
        
        return tubinfo
    }
    
}
