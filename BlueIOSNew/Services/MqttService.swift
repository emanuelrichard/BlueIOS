//
//  MqttService.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation
import CocoaMQTT

class MqttService: NSObject {
    
    static let it = MqttService()
    
    var state: Connection.State = Connection.State.DISCONNECTED
    
    let clientID = "Ios_BLUE-" + String(ProcessInfo().processIdentifier)
    var tub_id = ""
    var mqtt_client: CocoaMQTT? = nil
    private var mqttTimer: Timer!
    
    var connectedBTid: String? = nil
    
    var cmd_topic = ""
    var fbk_topic = ""
    
    var connDelegate: ConnectingProtocol?
    var commDelegate: CommunicationProtocol?
    func delegates(conn: ConnectingProtocol, comm: CommunicationProtocol?) -> MqttService {
        connDelegate = conn
        if(comm != nil) {
            commDelegate = comm
        }
        return self
    }
    func ok() { /* Use with delegates() to avoid warnings */}
    
    func connect(BTid: String, tubid: String) {
        mqtt_client = CocoaMQTT(clientID: clientID, host: BLEDefs.MQTT_HOST, port: BLEDefs.MQTT_PORT)
        if let mqtt = mqtt_client {
            // Setting tub id
            tub_id = tubid
            connectedBTid = BTid
            
            // Setting up the credentials
            mqtt.username = BLEDefs.MQTT_USER
            mqtt.password = BLEDefs.MQTT_PSWD
            
            // Setting up the keep alive timer
            mqtt.keepAlive = 120
            
            // Setting up delegate
            mqtt.delegate = self
            
            // Connecting to MQTT Host
            _ = mqtt.connect()
            state = Connection.State.CONNECTING
            connDelegate?.didStartConnectingTub()
            
            mqttTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: false, block: { t in
                self.state = Connection.State.FAILED
                self.connDelegate?.didFail()
                self.disconnect()
            })
            
        } else {
            state = Connection.State.FAILED
            connDelegate?.didFail()
        }
    }
    
    func disconnect() {
        mqtt_client?.disconnect()
        state = Connection.State.DISCONNECTING
    }
    
    func sendCommand(command: String) {
        if let mqtt = mqtt_client {
            mqtt.publish("\(tub_id)_comando", withString: command)
        } else {
            state = Connection.State.DISCONNECTED
            connDelegate?.didFail()
        }
        
    }

}

extension MqttService: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        
        Settings.BTid = connectedBTid ?? ""
        Settings.last_BTid = Settings.BTid
        state = Connection.State.CONNECTED
        connDelegate?.didConnectTub()
        
    }
    
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("Connected !")
        
        // Subscribing to feedbacks topic
        mqtt.subscribe("\(tub_id)_status")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Publish message: \(message) !")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("Publish ACK !")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Received message: \(message.string!) !")
        
        mqttTimer?.invalidate()
        let payload = message.string!.trimmingCharacters(in: .whitespacesAndNewlines)
        let feedbacks = payload.split(separator: "\n")
        for feedback in feedbacks {
            if let parsed_fbk = Utils.getParsedFeedback(feedback: String(feedback)) {
                let about = String(parsed_fbk[0])
                if let value = Int(String(parsed_fbk[1])) {
                    Settings.updateIntSettings(about: about, value: value)
                    commDelegate!.didReceiveFeedback(about: about, value: value)
                } else {
                    let text = String(parsed_fbk[1])
                    Settings.updateStrSettings(about: about, text: text)
                    commDelegate!.didReceiveFeedback(about: about, text: text)
                }
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("Subscribed to \(topics[0]) !")
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("Unsubscribed from \(topic) !")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        //print("Did Ping !")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        //print("Received Pong !")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("Disconnected !")
        if let error = err {
          print("Got error: \(error.localizedDescription)")
        }
        mqttTimer?.invalidate()
        
        tub_id = ""
        Settings.last_BTid = Settings.BTid
        connectedBTid = nil
        Settings.BTid = ""
        
        state = Connection.State.DISCONNECTED
        connDelegate?.didDisconnectTub()
    }
}
