////
////  ViewController.swift
////  Controle de Banheira
////
////  Created by AGTechnologies Ltda on 12/11/20.
////  Copyright © 2020 AGTechnologies Ltda. All rights reserved.
////
//
//import UIKit
//import DCKit
//
//class ConnViewController: UIViewController {
//
//
//    @IBOutlet weak var btnBle: DCRoundedButton!
//    @IBOutlet weak var btnWifi: DCRoundedButton!
//    @IBOutlet weak var btnRemote: DCRoundedButton!
//
//    @IBOutlet weak var viwBLE: UIView!
//    @IBOutlet weak var pckTubs: UIPickerView!
//    @IBOutlet weak var btnFindTubs: DCBorderedButton!
//
//    @IBOutlet weak var viwWifi: UIView!
//    @IBOutlet weak var pckSavedTubs: UIPickerView!
//    @IBOutlet weak var btnDeleteOnline: UIButton!
//
//    @IBOutlet weak var viwMqtt: UIView!
//    @IBOutlet weak var pckRemoteTubs: UIPickerView!
//    @IBOutlet weak var btnDeleteRemote: UIButton!
//    @IBOutlet weak var viwQRCode: DCBorderedView!
//    @IBOutlet weak var viwQRScan: QRScannerView!
//
//    @IBOutlet weak var btnConnect: DCBorderedButton!
//    @IBOutlet weak var swtAutoConn: UISwitch!
//
//    var conn_type: Int = 0
//
//    var tubs: [String] = []
//
//    var saved_tubnames: [String] = []
//    var saved_tubips: [String] = []
//
//    var remote_tubnames: [String] = []
//    var remote_tubids: [String] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Load Settings
//        Settings.inititate()
//        swtAutoConn.isOn = Settings.auto_conn
//
//        // UIPickerView setup
//        self.pckTubs.delegate = self
//        self.pckTubs.dataSource = self
//
//        self.pckSavedTubs.delegate = self
//        self.pckSavedTubs.dataSource = self
//
//        self.pckRemoteTubs.delegate = self
//        self.pckRemoteTubs.dataSource = self
//
//        // Setup the mode
//        swapConnViews()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        // Load tubs
//        self.loadOnlineTubs()
//        self.loadRemoteTubs()
//
//        // Setup the mode
//        swapConnViews()
//
//        // Assume responses and scan for tubs in ble
//        BluetoothLEService.it.delegates(ble: self, conn: self, comm: nil).startScan()
//
//        // Assume responses in Wifi
//        WiFiService.it.delegates(conn: self, comm: nil).ok()
//
//        // Assume responses in MQTT
//        MqttService.it.delegates(conn: self, comm: nil).ok()
//
//        // Assume responses in QRCode scans
//        viwQRScan.delegate = self
//
//        if(Settings.auto_conn && !Settings.tubname.isEmpty) {
//            mqttSelected(nil)
//            connect(Settings.tubname)
//        }
//
//        // Setup views
//        if(BluetoothLEService.it.state == Connection.State.CONNECTED){
//            pckTubs.reloadAllComponents()
//            btnConnect.setTitle("Voltar", for: UIControl.State.normal)
//            return
//        }
//
//        if(WiFiService.it.state == Connection.State.CONNECTED){
//            pckSavedTubs.reloadAllComponents()
//            btnConnect.setTitle("Voltar", for: UIControl.State.normal)
//            return
//        }
//
//        btnConnect.setTitle("Conectar", for: UIControl.State.normal)
//    }
//
//    @IBAction func bleSelected(_ sender: Any?) {
//        if(conn_type != 0) {
//            conn_type = 0
//            swapConnViews()
//        }
//    }
//
//    @IBAction func wifiSelected(_ sender: Any?) {
//        if(conn_type != 1) {
//            conn_type = 1
//            swapConnViews()
//        }
//    }
//
//    @IBAction func mqttSelected(_ sender: Any?) {
//        if(conn_type != 2) {
//            conn_type = 2
//            swapConnViews()
//        }
//    }
//
//    @IBAction func onAutoConnChange(_ sender: UISwitch) {
//        Settings.savePreferredAutoConn(auto: sender.isOn)
//    }
//
//    private func swapConnViews() {
//        viwBLE.isHidden = conn_type != 0
//        viwWifi.isHidden = conn_type != 1
//        viwMqtt.isHidden = conn_type != 2
//
//        btnBle.isSelected = conn_type == 0
//        btnWifi.isSelected = conn_type == 1
//        btnRemote.isSelected = conn_type == 2
//
//        btnConnect.isEnabled = conn_type == 0 ?
//            !tubs.isEmpty :
//            conn_type == 1 ?
//                !saved_tubnames.isEmpty :
//                !remote_tubnames.isEmpty
//
//        swtAutoConn.isEnabled = conn_type == 2
//        if(conn_type == 2) { swtAutoConn.isOn = Settings.auto_conn }
//        else { swtAutoConn.isOn = false }
//
////        if(BluetoothLEService.it.state == Connection.State.CONNECTED ||
////            WiFiService.it.state == Connection.State.CONNECTED ||
////            MqttService.it.state == Connection.State.CONNECTED) {
////            if let pck = conn_type == 0 ? pckTubs : conn_type == 1 ? pckSavedTubs : pckRemoteTubs {
////                pickerView(pck, didSelectRow: pck.selectedRow(inComponent: 0), inComponent: 0)
////            }
////        }
//    }
//
//    @IBAction func deleteOnline(_ sender: Any) {
//        if(saved_tubnames.count > 0) {
//            let tubname = saved_tubnames.remove(at: pckSavedTubs.selectedRow(inComponent: 0))
//            saved_tubips.remove(at: pckSavedTubs.selectedRow(inComponent: 0))
//            Settings.deleteOnlineTub(tubname: tubname)
//            pckSavedTubs.reloadAllComponents()
//            btnDeleteOnline.isHidden = saved_tubnames.isEmpty
//            btnConnect.isEnabled = !saved_tubnames.isEmpty
//        }
//    }
//
//    @IBAction func deleteRemote(_ sender: Any) {
//        if(remote_tubnames.count > 0) {
//            let tubname = remote_tubnames.remove(at: pckRemoteTubs.selectedRow(inComponent: 0))
//            remote_tubids.remove(at: pckRemoteTubs.selectedRow(inComponent: 0))
//            Settings.deleteRemoteTub(tubname: tubname)
//            pckRemoteTubs.reloadAllComponents()
//            btnDeleteRemote.isHidden = remote_tubnames.isEmpty
//            btnConnect.isEnabled = !remote_tubnames.isEmpty
//        }
//    }
//
//    @IBAction func scanQRCode(_ sender: Any) {
//        btnConnect.isEnabled = false
//        viwQRCode.isHidden = false
//        viwQRScan.startScanning()
//    }
//
//    @IBAction func cancelQRCode(_ sender: Any) {
//        viwQRScan.stopScanning()
//    }
//
//    @IBAction func findTubs(_ sender: Any) {
//        BluetoothLEService.it.startScan()
//    }
//
//    @IBAction func connect(_ sender: Any) {
//        var tubname = ""
//
//        switch conn_type {
//        case 0:
//            tubname = tubs[pckTubs.selectedRow(inComponent: 0)]
//
//            if(BluetoothLEService.it.state == Connection.State.CONNECTED) {
//                if let connName = BluetoothLEService.it.connectedTub?.name {
//                    if(tubname == connName) {
//                        performSegue(withIdentifier: "Connected", sender: nil)
//                        return
//                    }
//                }
//                BluetoothLEService.it.disconnect()
//            }
//
//            if(WiFiService.it.state == Connection.State.CONNECTED) {
//                WiFiService.it.disconnect()
//            }
//
//            if(MqttService.it.state == Connection.State.CONNECTED){
//                MqttService.it.disconnect()
//            }
//
//            BluetoothLEService.it.stopScan()
//
//            if(sender is String) {
//                tubname = sender as! String
//            }
//
//            BluetoothLEService.it.connect(BTid: tubname)
//        case 1:
//            var row = pckSavedTubs.selectedRow(inComponent: 0)
//            var ip = saved_tubips[row]
//            tubname = saved_tubnames[row]
//
//            if(WiFiService.it.state == Connection.State.CONNECTED){
//                WiFiService.it.disconnect()
//            }
//
//            if(BluetoothLEService.it.state == Connection.State.CONNECTED){
//                BluetoothLEService.it.disconnect()
//            }
//
//            if(MqttService.it.state == Connection.State.CONNECTED){
//                MqttService.it.disconnect()
//            }
//
//            if(sender is String) {
//                tubname = sender as! String
//                row = saved_tubnames.firstIndex(where: { $0 == tubname }) ?? -1
//                if(row >= 0) {
//                    ip = saved_tubips[row]
//                } else { return }
//            }
//
//            WiFiService.it.setNetwork(BTid: tubname, ip: ip).connect()
//        default:
//            var row = pckRemoteTubs.selectedRow(inComponent: 0)
//            var id = remote_tubids[row]
//            tubname = remote_tubnames[row]
//
//            if(MqttService.it.state == Connection.State.CONNECTED){
//                MqttService.it.disconnect()
//            }
//
//            if(WiFiService.it.state == Connection.State.CONNECTED){
//                WiFiService.it.disconnect()
//            }
//
//            if(BluetoothLEService.it.state == Connection.State.CONNECTED){
//                BluetoothLEService.it.disconnect()
//            }
//
//            if(sender is String) {
//                tubname = sender as! String
//                row = remote_tubnames.firstIndex(where: { $0 == tubname }) ?? -1
//                if(row >= 0) {
//                    id = remote_tubids[row]
//                } else { return }
//            }
//
//            MqttService.it.connect(BTid: tubname ,tubid: id)
//        }
//
//        // Setup the tubname
//        if(Settings.auto_conn){
//            Settings.savePreferredTub(name: tubname)
//        } else {
//            //Settings.removePreferredTub()
//            Settings.tubname = tubname
//        }
//    }
//
//    private func loadOnlineTubs(){
//        saved_tubnames = []
//        saved_tubips = []
//
//        let n_setups = Settings.loadOnlineTubs()
//        if(n_setups.count > 0){
//            for ns in n_setups {
//                let infos = ns.components(separatedBy: "§")
//                let name = infos[0]
//                let ip = infos[1]
//                saved_tubnames.append(name)
//                saved_tubips.append(ip)
//                if(Settings.tubname == name) {
//                    conn_type = 1
//                }
//            }
//            btnDeleteOnline.isHidden = false
//            pckSavedTubs.reloadComponent(0)
//            return
//        }
//        btnDeleteOnline.isHidden = true
//    }
//
//    private func loadRemoteTubs(){
//        remote_tubnames = []
//        remote_tubids = []
//
//        let m_setups = Settings.loadRemoteTubs()
//        if(m_setups.count > 0){
//            for ms in m_setups {
//                let infos = ms.components(separatedBy: "§")
//                let name = infos[0]
//                let id = infos[1]
//                remote_tubnames.append(name)
//                remote_tubids.append(id)
//                if(Settings.tubname == name) {
//                    conn_type = 2
//                }
//            }
//            btnDeleteRemote.isHidden = false
//            pckRemoteTubs.reloadComponent(0)
//            return
//        }
//        btnDeleteRemote.isHidden = true
//    }
//
//}
//
//// MARK: UIPickerView Setups
//extension ConnViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if(pickerView.tag == 1) {
//            return tubs.count
//        } else if(pickerView.tag == 2) {
//            return saved_tubnames.count
//        } else  if(pickerView.tag == 3) {
//            return remote_tubnames.count
//        }
//        return 0
//    }
//
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        var item: NSAttributedString? = nil
//        if(pickerView.tag == 1){
//            item = NSAttributedString(string: tubs[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(named: "title_color") ?? UIColor.systemGray])
//            if(BluetoothLEService.it.state == Connection.State.CONNECTED) {
//                if let connName = BluetoothLEService.it.connectedTub?.name {
//                    if(tubs[row] == connName){
//                        item = NSAttributedString(string: "● "+tubs[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.green])
//                    }
//                }
//            }
//        } else if(pickerView.tag == 2){
//            item = NSAttributedString(string: saved_tubnames[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(named: "title_color") ?? UIColor.systemGray])
//            if(WiFiService.it.state == Connection.State.CONNECTED) {
//                if let connName = WiFiService.it.connectedBTid {
//                    if(saved_tubnames[row] == connName){
//                        item = NSAttributedString(string: "● "+saved_tubnames[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.green])
//                    }
//                }
//            }
//        } else if(pickerView.tag == 3){
//            item = NSAttributedString(string: remote_tubnames[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(named: "title_color") ?? UIColor.systemGray])
//            if(MqttService.it.state == Connection.State.CONNECTED) {
//                if let connName = MqttService.it.connectedBTid {
//                    if(remote_tubnames[row] == connName){
//                        item = NSAttributedString(string: "● "+remote_tubnames[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.green])
//                    }
//                }
//            }
//        }
//        return item
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if(pickerView.tag == 1){
//            if(BluetoothLEService.it.state == Connection.State.CONNECTED) {
//                if let connName = BluetoothLEService.it.connectedTub?.name {
//                    if(tubs[pckTubs.selectedRow(inComponent: 0)] == connName){
//                        btnConnect.setTitle("Voltar", for: UIControl.State.normal)
//                        return
//                    }
//                }
//            }
//            btnConnect.setTitle("Conectar", for: UIControl.State.normal)
//        } else if(pickerView.tag == 2){
//            if(WiFiService.it.state == Connection.State.CONNECTED) {
//                if let connName = WiFiService.it.connectedBTid {
//                    if(saved_tubnames[pckSavedTubs.selectedRow(inComponent: 0)] == connName){
//                        btnConnect.setTitle("Voltar", for: UIControl.State.normal)
//                        return
//                    }
//                }
//            }
//            btnConnect.setTitle("Conectar", for: UIControl.State.normal)
//        }else if(pickerView.tag == 3){
//            if(MqttService.it.state == Connection.State.CONNECTED) {
//                if let connName = MqttService.it.connectedBTid {
//                    if(remote_tubnames[pckRemoteTubs.selectedRow(inComponent: 0)] == connName){
//                        btnConnect.setTitle("Voltar", for: UIControl.State.normal)
//                        return
//                    }
//                }
//            }
//            btnConnect.setTitle("Conectar", for: UIControl.State.normal)
//        }
//    }
//
//}
//
//// MARK: BluetoothLE Callbacks
//extension ConnViewController: BluetoothLEProtocol {
//    func didStartScan() {
//        tubs = []
//        if(BluetoothLEService.it.state == Connection.State.CONNECTED) {
//            if let connName = BluetoothLEService.it.connectedTub?.name {
//                tubs.append(connName)
//            }
//        }
//        btnConnect.isEnabled = conn_type == 0 ? !tubs.isEmpty : !saved_tubnames.isEmpty
//    }
//
//    func didFoundTub(BTid: String) {
//        if(BluetoothLEService.it.discoveredPeripherals.count > 0){
//            if(!tubs.contains(BTid)) {
//                tubs.append(BTid)
//            }
//            if(Settings.auto_conn && Settings.tubname == BTid){
//                self.connect(BTid)
//            }
//        }
//        pckTubs.reloadAllComponents()
//        btnConnect.isEnabled = conn_type == 0 ? !tubs.isEmpty : !saved_tubnames.isEmpty
//    }
//
//}
//
//// MARK: Connecting Callbacks
//extension ConnViewController: ConnectingProtocol {
//
//    func didStartConnectingTub() {
//        btnConnect.isEnabled = false
//        btnConnect.setTitle("Conectando...", for: UIControl.State.normal)
//    }
//
//    func didConnectTub() {
//        btnConnect.isEnabled = conn_type == 0 ? !tubs.isEmpty : !saved_tubnames.isEmpty
//        btnConnect.setTitle("Conectado", for: UIControl.State.normal)
//        performSegue(withIdentifier: "Connected", sender: nil)
//    }
//
//    func didDisconnectTub() {
//        btnConnect.isEnabled = conn_type == 0 ? !tubs.isEmpty : !saved_tubnames.isEmpty
//        btnConnect.setTitle("Conectar", for: UIControl.State.normal)
//    }
//
//    func didFail() {
//        btnConnect.isEnabled = conn_type == 0 ? !tubs.isEmpty : !saved_tubnames.isEmpty
//        btnConnect.setTitle("Conectar", for: UIControl.State.normal)
//    }
//
//}
//
//extension ConnViewController: QRCodeProtocol {
//    func qrScanningDidFail() {
//        Utils.toast(vc: self, message: "Falha ao ler QRCode de banheira CAS", type: 2)
//    }
//
//    func qrScanningSucceededWithCode(_ str: String?) {
//        guard str != nil else {
//            return
//        }
//
//        let qr_result = str!.components(separatedBy: "::")
//
//        // QR checks
//        guard qr_result.count >= 2
//        else {
//            Utils.toast(vc: self, message: "QRCode lido não é um código de banheira CAS válido", type: 2)
//            return
//        }
//
//        guard qr_result[0].contains("CAS_") ||
//                qr_result[1].count > 10
//        else {
//            Utils.toast(vc: self, message: "QRCode lido não é um código de banheira CAS válido", type: 2)
//            return
//        }
//
//        Settings.saveRemoteTub(tubname: qr_result[0], qrid: qr_result[1])
//        remote_tubnames.append(String(qr_result[0]))
//        remote_tubids.append(String(qr_result[1]))
//
//        btnDeleteRemote.isHidden = false
//
//        pckRemoteTubs.reloadAllComponents()
//        Utils.toast(vc: self, message: "Banheira remota adicionada com sucesso", type: 1)
//    }
//
//    func qrScanningDidStop() {
//        btnConnect.isEnabled = true
//        viwQRCode.isHidden = true
//    }
//
//}
