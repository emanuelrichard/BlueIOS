//
//  BLEService.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import CoreBluetooth

class BLEService: NSObject {
    
    // Singleton instance
    static let it = BLEService()

    var centralManager: CBCentralManager?
    
    var state: Connection.State = Connection.State.DISCONNECTED
    var connectedTub: CBPeripheral?
    var readCharacteristic: CBCharacteristic?
    var writeCharacteristic: CBCharacteristic?
    var discoveredPeripherals: [CBPeripheral] = []
    
    var cmds: [Data] = []
    var bleTimer: Timer?
    var writing = false
    
    var ble_enabled = false
    var nearestRSSI: Int = -999
    var nearestBtid: String? = nil
    
    var bleDelegate: BluetoothLEProtocol?
    var connDelegate: ConnectingProtocol?
    var commDelegate: CommunicationProtocol?
    func delegates(ble: BluetoothLEProtocol?, conn: ConnectingProtocol?, comm: CommunicationProtocol?) -> BLEService {
        if(ble != nil) {
            bleDelegate = ble
        }
        if(conn != nil) {
            connDelegate = conn
        }
        if(comm != nil) {
            commDelegate = comm
        }
        return self
    }
    func ok() {
        if(self.centralManager == nil) {
            self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        }
    }

    override init () {}

    func startScan() {
        // Clear the discovered list
        discoveredPeripherals = []
        
        if(self.centralManager == nil) {
            self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        }
        if(self.centralManager!.isScanning){
            self.stopScan()
        }
        self.centralManager!.scanForPeripherals(withServices: nil)
        //print("SCANNING...")
        bleDelegate?.didStartScan()
    }
    
    func stopScan() {
        //print("NOT SCANNING.")
        self.centralManager?.stopScan()
    }
    
    func resetNearest() {
        //print("RESET NEAREST...")
        nearestRSSI = -999
        nearestBtid = nil
    }
    
    func connect(BTid: String){
        //print("WILL CONNECT...\(discoveredPeripherals.count)")
        if let peripheral = discoveredPeripherals.first(where: { $0.name! == BTid } ){
            self.centralManager?.connect(peripheral, options: nil)
            state = Connection.State.CONNECTING
            connDelegate?.didStartConnectingTub()
            bleTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false){ t in
                self.state = Connection.State.FAILED
                self.connDelegate?.didFail()
                self.disconnect()
            }
        }
    }
    
    func connectNearestTub() {
        guard nearestBtid != nil
        else { return }
        connect(BTid: nearestBtid!)
    }
    
    func disconnect(){
        //print("WILL DISCONNECT...")
        guard
            connectedTub != nil
            else { return }
        
        Settings.last_BTid = Settings.BTid
        Settings.BTid = ""
        state = Connection.State.DISCONNECTING
        if(readCharacteristic != nil) {
            self.connectedTub?.setNotifyValue(false, for: readCharacteristic!)
        }
        self.centralManager?.cancelPeripheralConnection(connectedTub!)
    }
    
    private func sendCommand(){
        guard
            !cmds.isEmpty &&
            connectedTub != nil
            else { return }
        
        let cmd = cmds.remove(at: 0)
        writing = true
        connectedTub!.writeValue(cmd, for: writeCharacteristic!, type: CBCharacteristicWriteType.withResponse)
        
        bleTimer = Timer.scheduledTimer(withTimeInterval: 0.26, repeats: false){ t in
            self.writing = false
            self.sendCommand()
        }
    }
    
    func enqueueCommand(command: String){
        guard
            connectedTub != nil
            else { return }
        
        if let cmdData = command.data(using: String.Encoding.utf8) {
            cmds.append(cmdData)
        }
        if(!writing && cmds.count == 1){
            Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false){ t in
                self.sendCommand()
            }
        }
    }

}

extension BLEService: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        //"BLE STATE CHANGED.........")
        switch central.state {
            case .unknown:
              //print("central.state is .unknown")
              break
            case .resetting:
              //print("central.state is .resetting")
              break
            case .unsupported:
              //print("central.state is .unsupported")
              break
            case .unauthorized:
              //print("central.state is .unauthorized")
              break
            case .poweredOff:
              //print("central.state is .poweredOff")
              ble_enabled = false
              self.centralManager?.stopScan()
              connectedTub = nil
              Settings.BTid = ""
              state = Connection.State.DISCONNECTED
              connDelegate?.didDisconnectTub()
            case .poweredOn:
              //print("central.state is .poweredOn")
              ble_enabled = true
              self.centralManager?.scanForPeripherals(withServices: nil)
            @unknown default:
              //print("central.state is unknown")
            break
        }

    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        // Ignore non-tub peripherals
        if(peripheral.name == nil) { return }
        if (!peripheral.name!.starts(with: "Opp_") &&
            !peripheral.name!.starts(with: "OppCromo_") &&
            !peripheral.name!.starts(with: "OppOne_") &&
            !peripheral.name!.starts(with: "OppFlex_") &&
            !peripheral.name!.starts(with: "OppPlus_") &&
            !peripheral.name!.starts(with: "OppPro_") &&
            !peripheral.name!.starts(with: "OppSpa_")) {
            return
        }

        
        if(RSSI.intValue >= nearestRSSI || peripheral.name == nearestBtid) {
            nearestRSSI = RSSI.intValue
            nearestBtid = peripheral.name
            //print("Nearest: \(nearestBtid!) ~ \(nearestRSSI)")
        } else {
            //print("Found: \(peripheral.name!) ~ \(RSSI.intValue)")
        }
        
        // Add tub peripherals to discovered list
        if(!self.discoveredPeripherals.contains(peripheral)){
            self.discoveredPeripherals.append(peripheral)
            bleDelegate?.didFoundTub(BTid: peripheral.name!)
        }
        
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedTub = peripheral
        connectedTub!.delegate = self
        connectedTub!.discoverServices([BLEDefs.serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        state = Connection.State.FAILED
        connDelegate?.didFail()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //print("DISCONNECTED !!")
        connectedTub = nil
        state = Connection.State.DISCONNECTED
        connDelegate?.didDisconnectTub()

    }

}

extension BLEService: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        if let service: CBService = peripheral.services?.filter({ $0.uuid == BLEDefs.serviceUUID }).first {
            if(connectedTub == nil){
                connectedTub = peripheral
            }
            connectedTub!.discoverCharacteristics(nil, for: service)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        bleTimer?.invalidate()
        if(connectedTub == nil){
            connectedTub = peripheral
        }
        
        for c in service.characteristics ?? [] {
            if(c.uuid == BLEDefs.readCharUUID){
                readCharacteristic = c
                connectedTub!.setNotifyValue(true, for: readCharacteristic!)
                
            } else if(c.uuid == BLEDefs.writeCharUUID){
                writeCharacteristic = c
            }
        }
        
        //print("CONNECTED")
        Settings.BTid = connectedTub?.name ?? ""
        Settings.last_BTid = Settings.BTid
        state = Connection.State.CONNECTED
        connDelegate?.didConnectTub()
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        //Utils.sendCommand(cmd: TubCommands.STATUS, value: nil, word: nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        bleTimer?.invalidate()
        self.writing = false
        self.sendCommand()
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if let value: Data = characteristic.value {
            let feedback = String(data: value, encoding: String.Encoding.utf8) ?? ""
            if let parsed_fbk = Utils.getParsedFeedback(feedback: feedback) {
                let about = String(parsed_fbk[0])
                print("------------- FEEDBACK: \(parsed_fbk[0]): \(parsed_fbk[1])")
                if let value = Int(String(parsed_fbk[1])), !about.starts(with: "senha") {
                    Settings.updateIntSettings(about: about, value: value)
                    commDelegate?.didReceiveFeedback(about: about, value: value)
                    return
                }
                let text = String(parsed_fbk[1])
                Settings.updateStrSettings(about: about, text: text)
                commDelegate?.didReceiveFeedback(about: about, text: text)
            } //else {
//                print(" *** Poh Sérgio, tá vacilando no Chave-Valor !! :/ - \(feedback)")
//            }
        }
    }
    
//    private func analyseFeedback(){
//        while !feedback.isEmpty {
//            let cmd0 = feedback.firstIndex(of: ":")
//            let cmd1 = feedback.firstIndex(of: ";")
//            if(cmd0 != nil && cmd1 != nil) {
//                let fbk = String(feedback[cmd0!...cmd1!])
//                if let parsed_fbk = Utils.getParsedFeedback(feedback: fbk) {
//                    let about = String(parsed_fbk[0])
//                    print("\(parsed_fbk[0])::\(parsed_fbk[1])")
//                    if let value = Int(String(parsed_fbk[1])) {
//                        Settings.updateIntSettings(about: about, value: value)
//                        commDelegate!.didReceiveFeedback(about: about, value: value)
//                    } else {
//                        let text = String(parsed_fbk[1])
//                        Settings.updateStrSettings(about: about, text: text)
//                        commDelegate!.didReceiveFeedback(about: about, text: text)
//                    }
//                } else {
//                    return
//                }
//
//                feedback.removeSubrange(...cmd1!)
//            } else {
//                return
//            }
//        }
//    }
    
}


