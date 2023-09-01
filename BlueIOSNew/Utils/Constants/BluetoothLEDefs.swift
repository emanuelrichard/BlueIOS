//
//  BluetoothLEDefs.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import CoreBluetooth

class BLEDefs {
    
    // Service UUID
    static let serviceUUID: CBUUID = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    
    // Characteristics UUID
    static let readCharUUID: CBUUID = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")
    static let writeCharUUID: CBUUID = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
    
    // Protocol characters
    static let CMD_START: String = ":"
    static let CMD_END: String = ";"
    static let CMD_SEPARATOR: String.Element = " "
    
    // Information mqtt
    //static let MQTT_HOST = "tcp://54.235.59.247"
    static let MQTT_HOST = "server.opportunitysys.com.br"
    static let MQTT_PORT: UInt16 = 1883
    static let MQTT_USER = "blue"
    static let MQTT_PSWD = "teste"
}
