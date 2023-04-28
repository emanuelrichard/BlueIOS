//
//  HomeViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import DCKit
import MSCircularSlider

class HomeViewController: UIViewController {
    
    // UI Controls vars
    @IBOutlet weak var viwLoading: UIView!
    
    @IBOutlet weak var power_btn: UIButton!
    @IBOutlet weak var logo_img: UIImageView!
    
    @IBOutlet weak var temp_sld: MSCircularSlider!
    @IBOutlet weak var desr_sld: MSCircularSlider!
    
    @IBOutlet weak var desr_viw: UIView!
    @IBOutlet weak var desrHeight_ctr: NSLayoutConstraint!
    @IBOutlet weak var desrTitle_txt: UILabel!
    @IBOutlet weak var desr_txt: UILabel!
    @IBOutlet weak var desrUnity_txt: UILabel!
    
    @IBOutlet weak var temp_viw: UIView!
    @IBOutlet weak var tempTitle_txt: UILabel!
    @IBOutlet weak var temp_txt: UILabel!
    @IBOutlet weak var tempUnity_txt: UILabel!
    
    @IBOutlet weak var lvl_ico: UIImageView!
    @IBOutlet weak var heater_ico: UIImageView!
    @IBOutlet weak var bomb_ico: UIImageView!
    @IBOutlet weak var spot_ico: UIImageView!
    @IBOutlet weak var strip_ico: UIImageView!
    @IBOutlet weak var waterEntry_ico: UIImageView!
    @IBOutlet weak var autoOn_ico: UIImageView!
    @IBOutlet weak var keepWarm_ico: UIImageView!
    @IBOutlet weak var bubbles_ico: UIImageView!
    
    @IBOutlet weak var bomb1_act: UIButton!
    @IBOutlet weak var bomb2_act: UIButton!
    @IBOutlet weak var bomb3_act: UIButton!
    @IBOutlet weak var bomb4_act: UIButton!
    @IBOutlet weak var waterEntry_act: UIButton!
    @IBOutlet weak var autoOn_act: UIButton!
    @IBOutlet weak var keepWarm_act: UIButton!
    @IBOutlet weak var bubbles_act: UIButton!
    
    @IBOutlet weak var bleConn_ico: UIImageView!
    @IBOutlet weak var bleConn_txt: UILabel!
    @IBOutlet weak var bleDisconn_ico: UIButton!
    
    @IBOutlet weak var wifiConn_ico: UIImageView!
    @IBOutlet weak var wifiConn_txt: UILabel!
    @IBOutlet weak var wifiDisconn_ico: UIButton!
    
    @IBOutlet weak var mqttConn_ico: UIImageView!
    @IBOutlet weak var mqttConn_txt: UILabel!
    @IBOutlet weak var mqttDisconn_ico: UIButton!
    
    @IBOutlet weak var version_txt: UILabel!
    
    // Standart vars
    private var tempsetTimer: Timer?
    private var updateTimer: Timer?
    
    override func viewDidLoad() {
        
        // Assumes BLE service responses
        BLEService.it.delegates(ble: nil, conn: self, comm: self).ok()
        
        // Assume responses in Wifi
        WiFiService.it.delegates(conn: self, comm: self).ok()
        
        // Assume responses in MQTT
        MqttService.it.delegates(conn: self, comm: self).ok()
        
        // Request the status of the tub
        Utils.sendCommand(cmd: TubCommands.STATUS, value: nil, word: nil)
        
        // Setup Loading
        loading(show: true)
        
        // Setup controls
        setupViews()
        
        // Keep the tub updated in the database
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (timer) in
            self.saveTubLocally()
        }
        
        // Ensure tub connection succeded and updated tub info
        Timer.scheduledTimer(withTimeInterval: 4.35, repeats: false) { (timer) in
            if(!Settings.initialized) {
                let nc = self.navigationController
                nc?.popViewController(animated: true)
                let vc = nc?.viewControllers[(nc?.viewControllers.count ?? 2) - 1]
                if let vvc = vc {
                    let msg = Settings.pswd_err ?
                        "Conexão não autorizada, recadastre a banheira se possível" :
                        "Banheira inacessível, verifique a conexão da mesma"
                    Utils.toast(vc: vvc, message: msg, type: 2)
                    self.updateTimer?.invalidate()
                }
            } else {
                RequestManager.it.saveTubInfoRequest()
                Utils.sendDate()
            }
        }
        
        CommandQoS.startQoS()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(BLEService.it.state == Connection.State.CONNECTED ||
            WiFiService.it.state == Connection.State.CONNECTED ||
            MqttService.it.state == Connection.State.CONNECTED) {
        
            // Assumes BLE service responses
            BLEService.it.delegates(ble: nil, conn: self, comm: self).ok()
            
            // Assume responses in Wifi
            WiFiService.it.delegates(conn: self, comm: self).ok()
            
            // Assume responses in MQTT
            MqttService.it.delegates(conn: self, comm: self).ok()
            
            // Update the conns state
            updatePower()
            updateHeater()
            updateAllBombs()
            updateSpot()
            updateStrip()
            updateWaterEntry()
            updateAutoOn()
            updateKeepWarm()
            updateBubbles()
            updateBomb1()
            updateBomb2()
            updateBomb3()
            updateBomb4()
            setupConns()
            
            saveTubLocally()

        } else {
            if let pvc = self.navigationController?.viewControllers[1] {
                self.navigationController?.popToViewController(pvc, animated: true)
            }
        }
    }
    
    func loading(show: Bool) {
        viwLoading.isHidden = !show
        viwLoading.isUserInteractionEnabled = show
        tabBarController?.tabBar.isHidden = show
    }
    
    private func saveTubLocally(){
        if let tub = Tub.initFromSettings() {
            
            if let db = RealmDB.it {
                do {
                    try db.write {
                        db.add(tub, update: .modified)
                    }
                } catch {
                    print("Tub auto-update failed !")
                }
            }
        }
    }
    
    func setupViews() {
        
        desr_sld.delegate = self
        
        // Initializing indicators icons
        lvl_ico.image = #imageLiteral(resourceName: "level_0")
        lvl_ico.tintColor = UIColor.init(named: "iconOff_color")
        heater_ico.tintColor = UIColor.init(named: "iconOff_color")
        bomb_ico.tintColor = UIColor.init(named: "iconOff_color")
        spot_ico.tintColor = UIColor.init(named: "iconOff_color")
        strip_ico.tintColor = UIColor.init(named: "iconOff_color")
        waterEntry_ico.tintColor = UIColor.init(named: "iconOff_color")
        autoOn_ico.tintColor = UIColor.init(named: "iconOff_color")
        keepWarm_ico.tintColor = UIColor.init(named: "iconOff_color")
        bubbles_ico.tintColor = UIColor.init(named: "iconOff_color")
        
        // Initializing bomb indicators
        bomb1_act.tintColor = UIColor.init(named: "iconOff_color")
        bomb2_act.tintColor = UIColor.init(named: "iconOff_color")
        bomb3_act.tintColor = UIColor.init(named: "iconOff_color")
        bomb4_act.tintColor = UIColor.init(named: "iconOff_color")
        waterEntry_act.tintColor = UIColor.init(named: "iconOff_color")
        autoOn_act.tintColor = UIColor.init(named: "iconOff_color")
        keepWarm_act.tintColor = UIColor.init(named: "iconOff_color")
        bubbles_act.tintColor = UIColor.init(named: "iconOff_color")
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(logoTap))
        logo_img.isUserInteractionEnabled = true
        logo_img.addGestureRecognizer(tgr)
    }
    
    @objc func logoTap(tgr: UITapGestureRecognizer) {
        performSegue(withIdentifier: "Install", sender: nil)
    }
    
    // Actions
    @IBAction func powerAction(_ sender: Any) {
        if(Settings.power <= 0) {
            Utils.sendCommand(cmd: TubCommands.POWER, value: 1, word: nil)
            Settings.power = 1
        } else {
            var p = 0;
            if(Settings.has_drain > 0) {
                switch(Settings.off_action) {
                    case 0: p = 2
                    case 1: p = 0
                    case 2: p = -1
                    default: break
                }
            }
            if(p >= 0) {
                Utils.sendCommand(cmd: TubCommands.POWER, value: p, word: nil)
            } else {
                Utils.askOffAction(vc: self)
            }
            Settings.power = 0
        }
        updatePower()
    }
    
    @IBAction func bomb1Action(_ sender: Any) {
        if(Settings.qt_bombs < 1) {
            Utils.toast(vc: self, message: "Controle indisponível")
            return //Controle indisponível
        }
        
        if(Settings.level < 1) {
            Utils.toast(vc: self, message: "Nível insuficiente")
            return //Nível máximo atingido
        }
        
        if(Settings.bomb_1 > 0) {
            if(Settings.keep_warm > 0) {
                Utils.sendCommand(cmd: TubCommands.KEEP_WARM, value: 0, word: nil)
                Settings.keep_warm = 0
            }
            Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false) { _ in
                Utils.sendCommand(cmd: TubCommands.B1, value: 0, word: nil)
                Settings.bomb_1 = 0
            }
        } else {
            Utils.sendCommand(cmd: TubCommands.B1, value: 1, word: nil)
            Settings.bomb_1 = 1
        }
        updateBomb1()
    }
    
    @IBAction func bomb2Action(_ sender: Any) {
        if(Settings.qt_bombs < 2) {
            Utils.toast(vc: self, message: "Controle indisponível")
            return //Controle indisponível
        }
        
        if(Settings.level < 1) {
            Utils.toast(vc: self, message: "Nível insuficiente")
            return //Nível máximo atingido
        }
        
        if(Settings.bomb_2 > 0) {
            Utils.sendCommand(cmd: TubCommands.B2, value: 0, word: nil)
            Settings.bomb_2 = 0
        } else {
            Utils.sendCommand(cmd: TubCommands.B2, value: 1, word: nil)
            Settings.bomb_2 = 1
        }
        updateBomb2()
    }
    
    @IBAction func bomb3Action(_ sender: Any) {
        if(Settings.qt_bombs < 3) {
            Utils.toast(vc: self, message: "Controle indisponível")
            return //Controle indisponível
        }
        
        if(Settings.level < 1) {
            Utils.toast(vc: self, message: "Nível insuficiente")
            return //Nível máximo atingido
        }
        
        if(Settings.bomb_3 > 0) {
            Utils.sendCommand(cmd: TubCommands.B3, value: 0, word: nil)
            Settings.bomb_3 = 0
        } else {
            Utils.sendCommand(cmd: TubCommands.B3, value: 1, word: nil)
            Settings.bomb_3 = 1
        }
        updateBomb3()
    }
    
    @IBAction func bomb4Action(_ sender: Any) {
        if(Settings.qt_bombs < 4) {
            Utils.toast(vc: self, message: "Controle indisponível")
            return //Controle indisponível
        }
        
        if(Settings.level < 1) {
            Utils.toast(vc: self, message: "Nível insuficiente")
            return //Nível máximo atingido
        }
        
        if(Settings.bomb_4 > 0) {
            Utils.sendCommand(cmd: TubCommands.B4, value: 0, word: nil)
            Settings.bomb_4 = 0
        } else {
            Utils.sendCommand(cmd: TubCommands.B4, value: 1, word: nil)
            Settings.bomb_4 = 1
        }
        updateBomb4()
    }
    
    @IBAction func waterEntryAction(_ sender: Any) {
        if(Settings.has_waterctrl < 1) {
            Utils.toast(vc: self, message: "Controle indisponível")
            return //Controle indisponível
        }
        
        if(Settings.level > 1) {
            Utils.toast(vc: self, message: "Nível máximo atingido")
            return //Nível máximo atingido
        }
        
        if(Settings.waterctrl > 0) {
            Utils.sendCommand(cmd: TubCommands.WATER, value: 0, word: nil)
            Settings.waterctrl = 0
        } else {
            Utils.sendCommand(cmd: TubCommands.WATER, value: 1, word: nil)
            Settings.waterctrl = 1
        }
        updateWaterEntry()
    }
    
    @IBAction func autoOnAction(_ sender: Any) {
//        if(Settings.has_waterctrl < 1) {
//            Utils.toast(vc: self, message: "Controle indisponível")
//            return //Controle indisponível
//        }
        
        if(Settings.auto_on > 0) {
            Utils.sendCommand(cmd: TubCommands.SET_AUTOON, value: 0, word: nil)
            Settings.auto_on = 0
        } else {
            Utils.sendCommand(cmd: TubCommands.SET_AUTOON, value: 1, word: nil)
            Settings.auto_on = 1
        }
        updateAutoOn()
    }
    
    @IBAction func keepWarmAction(_ sender: Any) {
        if(Settings.has_heater < 1) {
            Utils.toast(vc: self, message: "Controle indisponível")
            return //Controle indisponível
        }
        
        if(Settings.keep_warm > 0) {
            Utils.sendCommand(cmd: TubCommands.KEEP_WARM, value: 0, word: nil)
        } else {
            Utils.sendCommand(cmd: TubCommands.KEEP_WARM, value: 1, word: nil)
        }
    }
    
    @IBAction func bubblesAction(_ sender: Any) {
        if(Settings.bubbles < 0) {
            Utils.toast(vc: self, message: "Controle indisponível")
            return //Controle indisponível
        }
        
//        if(Settings.bubbles > 0) {
//            Utils.sendCommand(cmd: TubCommands.B1, value: nil, word: nil)
//        } else {
//            Utils.sendCommand(cmd: TubCommands.B1, value: nil, word: nil)
//        }
    }
    
    @IBAction func bleDisconn(_ sender: Any) {
        if(Settings.BTid.isEmpty) {
            setupConns()
        } else {
            BLEService.it.disconnect()
        }
    }
    @IBAction func wifiDisconn(_ sender: Any) {
        if(Settings.BTid.isEmpty) {
            setupConns()
        } else {
            WiFiService.it.disconnect()
        }
        
    }
    @IBAction func mqttDisconn(_ sender: Any) {
        if(Settings.BTid.isEmpty) {
            setupConns()
        } else {
            MqttService.it.disconnect()
        }
    }
    
    private func setVersion() {
        var app_v = ""
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            app_v = "Versão do aplicativo: v\(appVersion)"
        }

        version_txt.text = "Firmware da banheira : v\(Settings.version)\n\(app_v)"
    }
    
    private func updatePower() {
        // Power indicator
        let power_img = Settings.power <= 0 ? #imageLiteral(resourceName: "ic_power_off") : #imageLiteral(resourceName: "ic_power_on")
        power_btn.setImage(power_img, for: .normal)
        
        // Control access to chromo
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray,
           let tabBarItem = arrayOfTabBarItems[Settings.has_cromo != 2 ? 1 : 0] as? UITabBarItem {
            tabBarItem.isEnabled = Settings.power != 0
        }
        
        // Lock the slider
        desr_sld.isEnabled = Settings.power > 0
        
        // Level indicator
        updateTubLevels()
        
        // Temperature indicators
        updateTemp()
        updateDesr()
        
        // Bomb indicators
        updateBomb1()
        updateBomb2()
        updateBomb3()
        updateBomb4()
        
        // Other indicators
        updateWaterEntry()
        updateAutoOn()
        updateKeepWarm()
        updateBubbles()
    }
    
    private func updateTemp() {
        temp_sld.currentValue = Settings.power != 0 ? Double(Settings.curr_temp - 15) : 0
        temp_txt.text = Settings.power != 0 ? String(Settings.curr_temp) : "--"
        
        if(Settings.power != 0) { warnTemp() }
        else {
            tempTitle_txt.textColor = UIColor.init(named: "iconOff_color")
            temp_txt.textColor = UIColor.init(named: "iconOff_color")
            tempUnity_txt.textColor =  UIColor.init(named: "iconOff_color")
        }
        
        updateHeaterConfig()
    }
    
    private func updateDesr() {
        desr_sld.currentValue = Settings.power != 0 ? Double(Settings.desr_temp - 15) : 0
        desr_txt.text = Settings.power != 0 ? String(Settings.desr_temp) : "--"
        
        if(Settings.power != 0) { warnDesr() }
        else {
            desrTitle_txt.textColor = UIColor.init(named: "iconOff_color")
            desr_txt.textColor = UIColor.init(named: "iconOff_color")
            desrUnity_txt.textColor = UIColor.init(named: "iconOff_color")
        }
        updateHeaterConfig()
    }
    
    private func updateHeaterConfig() {
        desrHeight_ctr.constant = Settings.has_heater == 0 ? -65 : 0
        desr_viw.isHidden = Settings.has_heater == 0
        desr_sld.isEnabled = Settings.has_heater != 0
        if(Settings.has_heater == 0) { warnDesr(temp: Settings.curr_temp) }
    }
    
    private func updateHeater() {
        heater_ico.tintColor = Settings.heater != 0 ? UIColor.init(named: "iconHot_color") : UIColor.init(named: "iconOff_color")
    }
    
    private func updateTubLevels() {
        if(Settings.power != 0) {
            lvl_ico.tintColor = UIColor.init(named: "iconOn_color")

            switch Settings.level {
            case 1:
                lvl_ico.image = #imageLiteral(resourceName: "level_1")
            case 2:
                lvl_ico.image = #imageLiteral(resourceName: "level_2")
            default:
                lvl_ico.image = #imageLiteral(resourceName: "level_0")
            }
            
        } else {
            lvl_ico.tintColor = UIColor.init(named: "iconOff_color")
            lvl_ico.image = #imageLiteral(resourceName: "level_0")
        }
    }
    private func updateAllBombs() {
        if(Settings.bomb_1 == 0 &&
            Settings.bomb_2 == 0 &&
            Settings.bomb_3 == 0 &&
            Settings.bomb_4 == 0 &&
            Settings.bomb_5 == 0) {
                bomb_ico.tintColor = UIColor.init(named: "iconOff_color")
        } else {
            bomb_ico.tintColor = UIColor.init(named: "iconOn_color")
        }
    }
    
    private func updateBomb1() {
        if(Settings.cooling > 0) {
            bomb_ico.tintColor = UIColor.init(named: "iconIce_color")
            bomb1_act.tintColor = UIColor.init(named: "iconIce_color")
            return
        }
        
        if(Settings.power <= 0 || Settings.qt_bombs < 1) {
            bomb1_act.tintColor = UIColor.init(named: "iconOff_color")
            return
        }
        
        bomb1_act.tintColor = Settings.bomb_1 != 0 ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")
    }
    
    private func updateBomb2() {
        if(Settings.power <= 0 || Settings.qt_bombs < 2) {
            bomb2_act.tintColor = UIColor.init(named: "iconOff_color")
            return
        }
        
        bomb2_act.tintColor = Settings.bomb_2 != 0 ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")
    }
    
    private func updateBomb3() {
        if(Settings.power <= 0 || Settings.qt_bombs < 3) {
            bomb3_act.tintColor = UIColor.init(named: "iconOff_color")
            return
        }
        
        bomb3_act.tintColor = Settings.bomb_3 != 0 ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")
    }
    
    private func updateBomb4() {
        if(Settings.power <= 0 || Settings.qt_bombs < 4) {
            bomb4_act.tintColor = UIColor.init(named: "iconOff_color")
            return
        }
        
        bomb4_act.tintColor = Settings.bomb_4 != 0 ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")
    }
    
    private func updateSpot() {
        if(Settings.spot_state <= 0){
            spot_ico.tintColor = UIColor.init(named: "iconOff_color")
        } else if(Settings.spot_state == 1) {
            switch Settings.spot_static {
            case 0:
                spot_ico.tintColor = UIColor.init(named: "white_color")
            case 1:
                spot_ico.tintColor = UIColor.init(named: "cyan_color")
            case 2:
                spot_ico.tintColor = UIColor.init(named: "blue_color")
            case 3:
                spot_ico.tintColor = UIColor.init(named: "pink_color")
            case 4:
                spot_ico.tintColor = UIColor.init(named: "magenta_color")
            case 5:
                spot_ico.tintColor = UIColor.init(named: "red_color")
            case 6:
                spot_ico.tintColor = UIColor.init(named: "orange_color")
            case 7:
                spot_ico.tintColor = UIColor.init(named: "yellow_color")
            case 8:
                spot_ico.tintColor = UIColor.init(named: "green_color")
            default:
                spot_ico.tintColor = UIColor.init(named: "iconOn_color")
            }
        } else {
            spot_ico.tintColor = UIColor.init(named: "iconOn_color")
        }
    }
    
    private func updateStrip() {
        if(Settings.strip_state <= 0) {
            strip_ico.tintColor = UIColor.init(named: "iconOff_color")
        } else if(Settings.strip_state == 1) {
            switch Settings.strip_static {
            case 0:
                strip_ico.tintColor = UIColor.init(named: "white_color")
            case 1:
                strip_ico.tintColor = UIColor.init(named: "cyan_color")
            case 2:
                strip_ico.tintColor = UIColor.init(named: "blue_color")
            case 3:
                strip_ico.tintColor = UIColor.init(named: "pink_color")
            case 4:
                strip_ico.tintColor = UIColor.init(named: "magenta_color")
            case 5:
                strip_ico.tintColor = UIColor.init(named: "red_color")
            case 6:
                strip_ico.tintColor = UIColor.init(named: "orange_color")
            case 7:
                strip_ico.tintColor = UIColor.init(named: "yellow_color")
            case 8:
                strip_ico.tintColor = UIColor.init(named: "green_color")
            default:
                strip_ico.tintColor = UIColor.init(named: "iconOn_color")
            }
        } else {
            strip_ico.tintColor = UIColor.init(named: "iconOn_color")
        }
    }
    
    private func updateWaterEntry() {
        if(Settings.power <= 0 || Settings.has_waterctrl <= 0) {
            waterEntry_act.tintColor = UIColor.init(named: "iconOff_color")
            return
        }
        
        waterEntry_ico.tintColor = Settings.waterctrl != 0 ? UIColor.init(named: "iconOn_color") : UIColor.init(named: "iconOff_color")
        waterEntry_act.tintColor = Settings.waterctrl != 0 ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")
    }
    
    private func updateAutoOn() {
        if(Settings.power <= 0) {
            autoOn_act.tintColor = UIColor.init(named: "iconOff_color")
            autoOn_ico.tintColor = UIColor.init(named: "iconOff_color")
            return
        }
        
        autoOn_ico.tintColor = Settings.auto_on != 0 ? UIColor.init(named: "iconOn_color") : UIColor.init(named: "iconOff_color")
        autoOn_act.tintColor = Settings.auto_on != 0 ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")
    }
    
    private func updateKeepWarm() {
        if(Settings.power <= 0 || Settings.has_temp <= 0) {
            keepWarm_act.tintColor = UIColor.init(named: "iconOff_color")
            keepWarm_ico.tintColor = UIColor.init(named: "iconOff_color")
            return
        }
        
        keepWarm_ico.tintColor = Settings.keep_warm != 0 ? UIColor.init(named: "iconOn_color") : UIColor.init(named: "iconOff_color")
        keepWarm_act.tintColor = Settings.keep_warm != 0 ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")
    }
    
    private func updateBubbles() {
        if(Settings.power <= 0 || true) {
            bubbles_act.tintColor = UIColor.init(named: "iconOff_color")
            return
        }
        
        bubbles_ico.tintColor = Settings.bubbles != 0 ? UIColor.init(named: "iconOn_color") : UIColor.init(named: "iconOff_color")
        bubbles_act.tintColor = Settings.bubbles != 0 ? UIColor.init(named: "iconAct_color") : UIColor.init(named: "iconOn_color")
    }
    
    private func setupConns() {
        var up = BLEService.it.state == Connection.State.CONNECTED
        var color = up ? UIColor.init(named: "iconOn_color") : UIColor.init(named: "iconOff_color")
        print("BLE UP: \(up)")
        bleConn_ico.tintColor = color
        bleDisconn_ico.tintColor = color
        print("\(bleConn_ico.tintColor == color ? "EQUALS :)": "NOT EQUALS :(")")
        bleConn_txt.text = up ? "Conectado à \(Settings.tubname)" : "Não conectado via Bluetooth"
        bleConn_txt.textColor = color
        
        up = WiFiService.it.state == Connection.State.CONNECTED
        color = up ? UIColor.init(named: "iconOn_color") : UIColor.init(named: "iconOff_color")
        print("WIFI UP: \(up)")
        wifiConn_ico.tintColor = color
        wifiDisconn_ico.tintColor = color
        wifiConn_txt.text = up ? "Conectado à \(Settings.tubname)" : "Não conectado via Wi-Fi"
        wifiConn_txt.textColor = color

        up = MqttService.it.state == Connection.State.CONNECTED
        color = up ? UIColor.init(named: "iconOn_color") : UIColor.init(named: "iconOff_color")
        print("MQTT UP: \(up)")
        mqttConn_ico.tintColor = color
        mqttDisconn_ico.tintColor = color
        mqttConn_txt.text = up ? "Conectado à \(Settings.tubname)" : "Não conectado remotamente"
        mqttConn_txt.textColor = color
    }
    
    private func warnTemp(temp: Int = Settings.curr_temp) {
        tempTitle_txt.textColor = UIColor.init(named: "title2_color")
        if(temp >= 36) {
            temp_txt.textColor = UIColor.init(named: "seekbarWarnTemp_color")
            tempUnity_txt.textColor = UIColor.init(named: "seekbarWarnTemp_color")
            temp_sld.filledColor = UIColor.init(named: "seekbarWarnTemp_color") ?? UIColor.systemRed
        } else {
            temp_txt.textColor = UIColor.init(named: "title2_color")
            tempUnity_txt.textColor = UIColor.init(named: "title2_color")
            temp_sld.filledColor = UIColor.init(named: "seekbarTemp_color") ?? UIColor.systemBlue
        }
    }
    
    private func warnDesr(temp: Int = Settings.desr_temp) {
        desrTitle_txt.textColor = UIColor.init(named: "title_color")
        if(temp >= 36) {
            desr_txt.textColor = UIColor.init(named: "seekbarWarnDesr_color")
            desrUnity_txt.textColor = UIColor.init(named: "seekbarWarnDesr_color")
            desr_sld.filledColor = UIColor.init(named: "seekbarWarnDesr_color") ?? UIColor.systemRed
        } else {
            desr_txt.textColor = UIColor.init(named: "title_color")
            desrUnity_txt.textColor = UIColor.init(named: "title_color")
            desr_sld.filledColor = UIColor.init(named: "seekbarDesr_color") ?? UIColor.systemBlue
        }
    }
    
}

extension HomeViewController: MSCircularSliderDelegate {
    
    func circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool) {
        self.desr_txt.text = Settings.power != 0 ? "\(Int(value)+15)" : "--"
        warnDesr(temp: Int(value)+15)
        if(fromUser) {
            self.tempsetTimer?.invalidate()
            self.tempsetTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false){ t in
                Utils.sendCommand(cmd: TubCommands.TEMP_SET, value: Int(value)+15, word: nil)
            }
        }
    }
    
}

extension HomeViewController: ConnectingProtocol, CommunicationProtocol {
    
    func didStartConnectingTub() {
        // Do anything
    }
    
    func didConnectTub() {
        // Do anything
    }
    
    func didDisconnectTub() {
        RequestManager.it.saveTubInfoRequest()
        
        Settings.resetAll()
        if let pvc = self.navigationController?.viewControllers[1] {
            self.navigationController?.popToViewController(pvc, animated: true)
        }
    }
    
    func didFail() {
        RequestManager.it.saveTubInfoRequest()
        
        Settings.resetAll()
    }
    
    func didReceiveFeedback(about: String, value: Int) {
        switch about {
        case BathTubFeedbacks.POWER:
            updatePower()
            loading(show: false)
        case BathTubFeedbacks.TEMP_NOW:
            //Notifications.notify(title: "Temperatura desejada atingida", message: "A água já se encontra na temperatura desejada", reason: about)
            updateTemp()
        case BathTubFeedbacks.TEMP_DESIRED:
            updateDesr()
        case BathTubFeedbacks.BOMB1_STATE:
            updateBomb1()
            updateAllBombs()
        case BathTubFeedbacks.BOMB2_STATE:
            updateBomb2()
            updateAllBombs()
        case BathTubFeedbacks.BOMB3_STATE:
            updateBomb3()
            updateAllBombs()
        case BathTubFeedbacks.BOMB4_STATE:
            updateBomb4()
            updateAllBombs()
        case BathTubFeedbacks.HEATER_STATE:
            updateHeater()
        case BathTubFeedbacks.SPOTS_STATE:
            updateSpot()
        case BathTubFeedbacks.SPOTS_COLOR:
            updateSpot()
        case BathTubFeedbacks.STRIP_STATE:
            updateStrip()
        case BathTubFeedbacks.STRIP_COLOR:
            updateStrip()
        case BathTubFeedbacks.WATER_CTRL:
            updateWaterEntry()
        case BathTubFeedbacks.AUTO_ON:
            updateAutoOn()
        case BathTubFeedbacks.LEVEL_STATE:
            //Notifications.notify(title: "Banheira em nível máximo", message: "Tudo pronto para seu banho", reason: about)
            updateTubLevels()
        case BathTubFeedbacks.COOLING:
            updateBomb1()
        case BathTubFeedbacks.KEEP_WARM:
            updateKeepWarm()
        default:
            return
        }
    }
    
    func didReceiveFeedback(about: String, text: String) {
        switch about {
        case BathTubFeedbacks.VERSION:
            setupConns()
            setVersion()
        default:
            return
        }
    }
}

extension HomeViewController: RequestProtocol {
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) { }
    
    func onError(code: Int, error: Error, source: String) { }
    
}
