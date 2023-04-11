//
//  TubListViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import DCKit
import CoreLocation

class TubListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ATubLayoutDelegate {
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var viwQRCode: DCBorderedView!
    @IBOutlet weak var viwQRScan: QRScannerView!
    @IBOutlet weak var txtAddedTitle: UILabel!
    @IBOutlet weak var lstTubs: UICollectionView!
    @IBOutlet weak var btnAccOptions: UIButton!
    @IBOutlet weak var btnAppSettings: UIButton!
    @IBOutlet weak var viwLoading: UIView!
    
    private var added_lst: [Tub] = []
    private var shouldShowConn: [Int] = []
    private var selected = -1
    private var autocon = true
    private let sectionInsets = UIEdgeInsets(
      top: 10.0,
      left: 10.0,
      bottom: 10.0,
      right: 10.0)
    
    private var mTimer: Timer?
    private var scanCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assume responses in QRCode scans
        viwQRScan.delegate = self
        
        // Init tubs list
        if let layout = lstTubs.collectionViewLayout as? ATubViewLayout {
          layout.delegate = self
        }
        //lstTubs.delegate = self
        //lstTubs.dataSource = self
        
        // Assume responses of Services
        BLEService.it.delegates(ble: self, conn: self, comm: nil).ok()
        WiFiService.it.delegates(conn: self, comm: nil).ok()
        MqttService.it.delegates(conn: self, comm: nil).ok()
        
        // Loading setup
        loading(show: !Settings.favorite.isEmpty && autocon)
        
        //
        if #available(iOS 13.0, *) {
            let status = CLLocationManager.authorizationStatus()
            if status != .authorizedWhenInUse {
                self.locationManager.delegate = self
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Cancel QoS
        CommandQoS.stopQoS()
        
        // Check user is logged in
        if(Settings.uemail.isEmpty) {
            navigationController?.popToRootViewController(animated: true)
        }
        
        // Assume responses of Services
        BLEService.it.delegates(ble: self, conn: self, comm: nil).ok()
        WiFiService.it.delegates(conn: self, comm: nil).ok()
        MqttService.it.delegates(conn: self, comm: nil).ok()
        
        // Database loading
        refreshTubList()
        
        // Server loading
        RequestManager.it.loadTubRequest(delegate: self)
        
        // Init update timer
        mTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] (timer) in
            scanCounter += 1
            //print("scanCounter: \(scanCounter)")
            if(scanCounter == 1) {
                BLEService.it.startScan()
            }
            if(scanCounter == 3) {
                BLEService.it.stopScan()
                lstTubs.reloadData()
            }
            if(scanCounter == 20) {
                RequestManager.it.loadTubRequest(delegate: self)
                shouldShowConn.removeAll()
                scanCounter = 0
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        saveTubs(tubs: nil)
        mTimer?.invalidate()
    }
    
    @IBAction func QRTubClick(_ sender: Any) {
        viwQRCode.isHidden = false
        viwQRCode.isUserInteractionEnabled = true
        viwQRScan.startScanning()
    }
    
    @IBAction func QRCancel(_ sender: Any) {
        viwQRScan.stopScanning()
    }
    
    @IBAction func AddTubClick(_ sender: Any) {
        if(BLEService.it.ble_enabled) {
            performSegue(withIdentifier: "TubAdd", sender: nil)
        } else {
            Utils.toast(vc: self, message: "Ligue o Bluetooth e tente novamente!")
        }
    }
    
    @IBAction func accountOptionsClick(_ sender: Any) {
        performSegue(withIdentifier: "AccOpt", sender: nil)
    }
    
    @IBAction func appSettingsClick(_ sender: Any) {
        performSegue(withIdentifier: "GenCfg", sender: nil)
    }
    
    func loading(show: Bool) {
        viwLoading.isHidden = !show
        viwLoading.isUserInteractionEnabled = show
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return added_lst.count
    }
    
    func collectionView(
          _ collectionView: UICollectionView,
          heightForCellAtIndexPath indexPath:IndexPath) -> CGFloat {
        let h = lstTubs.frame.width
        return estimateHeight(ref: h, for: indexPath.row)
      }
    
    private func estimateHeight(ref: CGFloat, for row: Int) -> CGFloat {
        var total: CGFloat = 0
        let tubname = added_lst[row].tub_name
        let w_cell = (ref/2) - 32
        let sz_text = tubname.size(withAttributes:[.font: UIFont.systemFont(ofSize: 17.0, weight: .bold)])
        total += 120
        total += w_cell <= sz_text.width ? (sz_text.height+8) * 2 : (sz_text.height+8)
        total += 40
        total += shouldShowConn.contains(row) ? 40 : 0
        return total
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ATub", for: indexPath) as! ATubViewCell
            
        let tub = added_lst[indexPath.row]
        cell.tubname_txt.text = tub.tub_name

        let ble_up = BLEService.it.ble_enabled &&
        BLEService.it.discoveredPeripherals.contains(where: { $0.name == tub.BTid })
        cell.ble_ico.tintColor = ble_up == true ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")

        let wifi_up = tub.wifi_state == "2" &&
            Utils.getWiFiNetworkName() != nil &&
            Utils.getWiFiNetworkName() == tub.ssid
        cell.wifi_ico.tintColor = wifi_up == true ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")

        let mqtt_up = tub.mqtt_state == "1" &&
            tub.online &&
            Utils.isNetworkReachable()
        cell.mqtt_ico.tintColor = mqtt_up == true ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")
        
        cell.conn_btn.tintColor = ble_up || wifi_up || mqtt_up ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")
        
        cell.conn_hgt.constant = shouldShowConn.contains(indexPath.row) ? 32 : 0

        cell.conn_btn.tag = indexPath.row
        cell.conn_btn.addTarget(self, action: #selector(showTubConn), for: .touchUpInside)
        
        let is_fav = Settings.favorite == tub.BTid
        let fav_ico = is_fav ? #imageLiteral(resourceName: "star_on") : #imageLiteral(resourceName: "star_off")
        if(is_fav && autocon) {
            autocon = false
            selected = indexPath.row
            _ = connect(sel_tub: tub)
        }
        cell.fav_btn.setImage(fav_ico, for: .normal)
        cell.fav_btn.tag = indexPath.row
        cell.fav_btn.addTarget(self, action: #selector(favoriteTub), for: .touchUpInside)
        
        cell.del_btn.tag = indexPath.row
        cell.del_btn.addTarget(self, action: #selector(deleteTub), for: .touchUpInside)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(lstAddedLongPress))
        cell.del_btn.addGestureRecognizer(longPressGesture)
        
        cell.ble_ico.tag = (indexPath.row+1) * 17
        cell.ble_ico.addTarget(self, action: #selector(forceConnect), for: .touchUpInside)
        cell.wifi_ico.tag = (indexPath.row+1) * 19
        cell.wifi_ico.addTarget(self, action: #selector(forceConnect), for: .touchUpInside)
        cell.mqtt_ico.tag = (indexPath.row+1) * 23
        cell.mqtt_ico.addTarget(self, action: #selector(forceConnect), for: .touchUpInside)
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        selected = indexPath.row
        let sel_tub = added_lst[selected]
        
        Utils.disconnect()

        return connect(sel_tub: sel_tub)
    }
    
    private func connect(sel_tub: Tub, force: Int = -1) -> Bool {
        Settings.tubname = sel_tub.tub_name
        Settings.tub_pswd1 = sel_tub.tub_pswd1
        Settings.BTid = sel_tub.BTid
        
        let ble_up = BLEService.it.ble_enabled &&
        BLEService.it.discoveredPeripherals.contains(where: { $0.name == sel_tub.BTid })
        if(force < 0 || force == 0) {
            if(ble_up) {
                BLEService.it.connect(BTid: sel_tub.BTid)
                //viwLoading.backgroundColor = UIColor.red
                autocon = false
                return true
            }
        }
        
        let wifi_up = sel_tub.wifi_state == "2" &&
            Utils.getWiFiNetworkName() != nil &&
            Utils.getWiFiNetworkName() == sel_tub.ssid
        if(force < 0 || force == 1) {
            if(wifi_up) {
                //viwLoading.backgroundColor = UIColor.green
                WiFiService.it.setNetwork(BTid: sel_tub.BTid, ip: sel_tub.ip).connect()
                autocon = false
                return true
            }
        }
        
        let mqtt_up = sel_tub.mqtt_state == "1" &&
            sel_tub.online &&
            Utils.isNetworkReachable()
        if(force < 0 || force == 2){
            if(mqtt_up) {
                if let tubid = Utils.getMqttId(pub: sel_tub.mqtt_pub, sub: sel_tub.mqtt_sub) {
                    MqttService.it.connect(BTid: sel_tub.BTid, tubid: tubid)
                    //viwLoading.backgroundColor = UIColor.cyan
                    autocon = false
                    return true
                }
            }
        }
        
        selected = -1
        Settings.resetAll()
        Utils.toast(vc: self, message: "A banheira \(sel_tub.tub_name) parece estar fora de alcance no momento")
        return false
    }

    @objc func lstAddedLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: lstTubs)
        let indexPath = lstTubs.indexPathForItem(at: p)
        if indexPath == nil {
            return
        } else if longPressGesture.state == UIGestureRecognizer.State.ended {
            RequestManager.it.deleteTubRequest(tub_id: added_lst[indexPath!.row].BTid, delegate: self)
            
            if let db = RealmDB.it {
                do {
                    try db.write {
                        let mac = added_lst[indexPath!.row].mqtt_sub
                        db.delete(added_lst[indexPath!.row])
                        
                        added_lst.remove(at: indexPath!.row)
                        
                        Notifications.unsubscribeToRemoteNotifications(topic: Utils.getMqttId(pub: mac, sub: mac) ?? "")
                        
                        Utils.toast(vc: self, message: "Banheira deletada com sucesso!", type: 1)
                        
                        refreshTubList()
                    }
                } catch { }
            } else {
                Utils.toast(vc: self, message: "Erro ao deletar banheira", type: 2)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "TubAdd") {
            if let nextVC = segue.destination as? TubAddViewController {
                nextVC.delegate = self
            }
            return
        }
        if(segue.identifier == "AccOpt") {
            return
        }
    }
    
    @objc func favoriteTub(sender: UIButton) {
        autocon = false
        let BTid = added_lst[sender.tag].BTid
        let fav = Settings.favorite != BTid ? BTid : ""
        Settings.saveFavTub(BT_id: fav)
        refreshTubList(reloadTubs: false)
    }
    
    @objc func showTubConn(sender: UIButton) {
        if(!shouldShowConn.contains(sender.tag)) {
            shouldShowConn.append(sender.tag)
        } else {
            shouldShowConn.removeAll(where: { $0 == sender.tag })
        }
        refreshTubList(reloadTubs: false)
    }
    
    @objc func forceConnect(sender: UIButton) {
        let tag = sender.tag
        if(tag % 17 == 0) {
            selected = (tag/17) - 1
            _ = connect(sel_tub: added_lst[selected], force: 0)
            return
        }
        if(tag % 19 == 0) {
            selected = (tag/19) - 1
            _ = connect(sel_tub: added_lst[selected], force: 1)
            return
        }
        if(tag % 23 == 0) {
            selected = (tag/23) - 1
            _ = connect(sel_tub: added_lst[selected], force: 2)
        }
    }
    
    @objc func deleteTub(sender: UIButton) {
        Utils.toast(vc: self, message: "Segure o botão para confirmar a exclusão")
    }
    
    private func saveTubs(tubs: [Tub]?) {
        if let db = RealmDB.it {
            do {
                try db.write {
                    if let t = tubs {
                        db.add(t, update: .modified)
                    } else {
                        db.add(added_lst, update: .modified)
                    }
                }
            } catch { }
        }
    }
    
    private func refreshTubList(reloadTubs: Bool = true) {
        if(reloadTubs) {
            added_lst.removeAll()
            if let db = RealmDB.it {
                let tubs = db.objects(Tub.self)
                added_lst.append(contentsOf: tubs)
            }
            
            if(added_lst.isEmpty) {
                txtAddedTitle.text = "Nenhuma banheira adicionada. Utilize os botões acima para adicionar uma banheira."
            } else {
                txtAddedTitle.text = "Selecione a banheira que deseja conectar-se"
            }
        }
        
        lstTubs.reloadData()
    }
    
}

extension TubListViewController: BluetoothLEProtocol, ConnectingProtocol, DataBackProtocol {
    func retrieveData(data: Any) {
        let tub = data as! Tub
        
        RequestManager.it.addTubRequest(tub: tub, delegate: self)
        
        saveTubs(tubs: [tub])
        refreshTubList()
        
        Settings.resetAll()
    }
    
    func didStartScan() {
        
    }
    
    func didFoundTub(BTid: String) {
        
    }
    
    func didStartConnectingTub() {
        if(selected == -1) { return }
        loading(show: true)
    }
    
    func didConnectTub() {
        if(selected == -1) {
            if(BLEService.it.state == Connection.State.CONNECTED) {
                BLEService.it.disconnect()
            }
        } else {
            performSegue(withIdentifier: "Connected", sender: nil)
            loading(show: false)
        }
        txtAddedTitle.text = "Selecione a banheira que deseja conectar-se"
        selected = -1
        
    }
    
    func didDisconnectTub() {
        loading(show: false)
        selected = -1
    }
    
    func didFail() {
        Utils.toast(vc: self, message: "A banheira parece estar fora de alcance no momento")
        loading(show: false)
        selected = -1
    }
}

extension TubListViewController: RequestProtocol {
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) {
        DispatchQueue.main.async {
            if(code < 400) {
                switch source {
                case "GET_TUB":
                    var updated: [Tub] = []
                    if(self.added_lst.isEmpty) {
                        for resp in response {
                            let tub = Tub()
                            tub.initFromDict(dict: resp)
                            updated.append(tub)
                        }
                    } else {
                        for resp in response {
                            for atub in self.added_lst {
                                if(resp["BTid"] as! String == atub.BTid) {
                                    let tub = Tub()
                                    tub.initFromDict(dict: resp)
                                    let dFormatter = ISO8601DateFormatter()
                                    dFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                                    let wtDate = dFormatter.date(from: tub.date) ?? Date()
                                    let ltDate = dFormatter.date(from: atub.date) ?? Date()
                                    //print("--- name: \(tub.tub_name)/ \(atub.date)~\(tub.date) - atual: \(ltDate) < nova: \(wtDate) = \(ltDate < wtDate)")
                                    if(ltDate < wtDate) {
                                        tub.tub_name = atub.tub_name
                                        updated.append(tub)
                                    } else {
                                        if let db = RealmDB.it {
                                            do {
                                                try db.write {
                                                    atub.online = tub.online
                                                }
                                            } catch { }
                                        }
                                        updated.append(atub)
                                    }
                                }
                            }
                        }
                    }
                    
                    self.saveTubs(tubs: updated)
                    self.refreshTubList()
                    
                    RequestManager.it.sendPendingRequest()
                case "POST_TUB":
                    break
                case "DELETE_TUB":
                    break
                default:
                    return
                }
            } else if(code < 500) {
                if(code == 401) {
                    Settings.logout()
                    
                    Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { (timer) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                Utils.handleHTTPError(vc: nil, code: code)
            }
        }
    }
    
    func onError(code: Int, error: Error, source: String) {
        DispatchQueue.main.async {
            //print(error)
            Utils.handleHTTPError(vc: nil, code: code)
        }
    }
    
}

extension TubListViewController: QRCodeProtocol {
    func qrScanningDidFail() {
        Utils.toast(vc: self, message: "Falha ao ler QRCode de banheira CAS", type: 2)
    }
    
    func qrScanningSucceededWithCode(_ str: String?) {
        guard str != nil else {
            return
        }
        
        if let tub = Tub.initFromString(tubstr: str!) {
            RequestManager.it.addTubRequest(tub: tub, delegate: self)
            
            saveTubs(tubs: [tub])
            refreshTubList()
            
            Utils.toast(vc: self, message: "Banheira remota adicionada com sucesso", type: 1)
            return
        }
        Utils.toast(vc: self, message: "QRCode lido não é um código de banheira CAS válido", type: 2)
    }
    
    func qrScanningDidStop() {
        viwQRCode.isHidden = true
        viwQRCode.isUserInteractionEnabled = false
    }
}

extension TubListViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("SSID: \(Utils.getWiFiNetworkName() ?? "SSID error")")
        } else {
            Utils.toast(vc: self, message: "Sem a permissão de localização, a conexão Wi-Fi não será detectada", type: 0)
        }
    }
}
