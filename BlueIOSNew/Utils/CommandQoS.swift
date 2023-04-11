//
//  CommandQoS.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation

class CommandQoS {
    
    private static var cmd_str = Dictionary<String, String>()
    private static var cmd_time = Dictionary<String, Double>()
    private static var timer: Timer?
    
    private static var BASE_TIME: Double = 1000
    
    static func addPendingCommand(code: String, command: String) {
        guard !code.isEmpty
        else { return }
        
        //print("Keeping command '\(command)'...")
        cmd_str[code] = command
        cmd_time[code] = Date.timeIntervalBetween1970AndReferenceDate
    }
    
    static func removePendingCommand(code: String) {
        guard !code.isEmpty
        else { return }
        
        //print("Releasing command '\(cmd_str[code] ?? "<nil>")'..")
    }
    
    static func startQoS() {
        guard !(timer?.isValid ?? false)
        else { return }
        
        cmd_str.removeAll()
        cmd_time.removeAll()
        
        if BLEService.it.state == Connection.State.CONNECTED { BASE_TIME = 500 }
        if WiFiService.it.state == Connection.State.CONNECTED { BASE_TIME = 800 }
        if MqttService.it.state == Connection.State.CONNECTED { BASE_TIME = 950 }
        
        timer = Timer.scheduledTimer(withTimeInterval: (BASE_TIME/1000), repeats: true) { (timer) in
            let now = Date.timeIntervalBetween1970AndReferenceDate
            for (k, v) in cmd_time {
                let t = now - v
                if(t >= BASE_TIME) {
                    //print("Resending command '\(cmd_str[k] ?? "<nil>")' sent '\(t)' miliseconds ago..")
                    Utils.sendRawCommand(command: cmd_str[k])
                }
                if(t > (BASE_TIME*4.5)) {
                    //print("Command '\(cmd_str[k] ?? "<nil>")' deadtime reached !")
                    removePendingCommand(code: k)
                }
            }
        }
    }
    
    static func stopQoS(){
        timer?.invalidate()
        timer = nil
        
        cmd_str.removeAll()
        cmd_time.removeAll()
    }
    
}
