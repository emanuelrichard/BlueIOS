//
//  ChromoViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import DCKit
import FlexColorPicker

class ChromoViewController: UIViewController {
    
    // UI Controls vars
    @IBOutlet weak var power_btn: UIButton!
    
    @IBOutlet weak var targetChromo_sbt: UISegmentedControl!
    
    @IBOutlet weak var white_btn: DCBorderedButton!
    @IBOutlet weak var cyan_btn: DCBorderedButton!
    @IBOutlet weak var blue_btn: DCBorderedButton!
    @IBOutlet weak var pink_btn: DCBorderedButton!
    @IBOutlet weak var magenta_btn: DCBorderedButton!
    @IBOutlet weak var red_btn: DCBorderedButton!
    @IBOutlet weak var orange_btn: DCBorderedButton!
    @IBOutlet weak var yellow_btn: DCBorderedButton!
    @IBOutlet weak var green_btn: DCBorderedButton!
    
    @IBOutlet weak var allColor_btn: UIButton!
    
    @IBOutlet weak var rand1_btn: DCBorderedButton!
    @IBOutlet weak var rand2_btn: DCBorderedButton!
    @IBOutlet weak var seq1_btn: DCBorderedButton!
    @IBOutlet weak var seq2_btn: DCBorderedButton!
    @IBOutlet weak var bum1_btn: DCBorderedButton!
    @IBOutlet weak var bum2_btn: DCBorderedButton!
    @IBOutlet weak var caleid_btn: DCBorderedButton!
    @IBOutlet weak var strobe_btn: DCBorderedButton!
    
    @IBOutlet weak var speed_sld: SliderView!
    @IBOutlet weak var bright_sld: SliderView!
    
    @IBOutlet weak var chromoOff_btn: UIButton!
    
    // Standart vars
    private var target = 0
    
    private var sel_effect = -1
    private var sel_color = -1
    
    private var sldTimer: Timer = Timer.scheduledTimer(withTimeInterval:  0.1, repeats: false) { t in }
    
    override func viewDidLoad() {
        
        // Assumes BLE service responses
        BLEService.it.delegates(ble: nil, conn: self, comm: self).ok()
        
        // Assume responses in Wifi
        WiFiService.it.delegates(conn: self, comm: self).ok()
        
        // Assume responses in MQTT
        MqttService.it.delegates(conn: self, comm: self).ok()
        
        // Setup controls
        setupViews()
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
            
            // Initialize selected controls
            if(Settings.n_spotleds <= 0) { target = 1 }
            if(Settings.n_stripleds <= 0) { target = 0 }
            if(target != targetChromo_sbt.selectedSegmentIndex) {
                targetChromo_sbt.selectedSegmentIndex = target
            } else {
                if(target == 0) {
                    setCtrlSelected(state: Settings.spot_state, color: Settings.spot_static, select: true)
                } else {
                    setCtrlSelected(state: Settings.strip_state, color: Settings.strip_static, select: true)
                }
            }
            
            // Update power indicator
            updatePower()

        } else {
            if let pvc = self.navigationController?.viewControllers[1] {
                self.navigationController?.popToViewController(pvc, animated: true)
            }
        }
    }
    
    private func setupViews() {
        white_btn.addTarget(self, action: #selector(colorPressed), for: .touchUpInside)
        cyan_btn.addTarget(self, action: #selector(colorPressed), for: .touchUpInside)
        blue_btn.addTarget(self, action: #selector(colorPressed), for: .touchUpInside)
        pink_btn.addTarget(self, action: #selector(colorPressed), for: .touchUpInside)
        magenta_btn.addTarget(self, action: #selector(colorPressed), for: .touchUpInside)
        red_btn.addTarget(self, action: #selector(colorPressed), for: .touchUpInside)
        orange_btn.addTarget(self, action: #selector(colorPressed), for: .touchUpInside)
        yellow_btn.addTarget(self, action: #selector(colorPressed), for: .touchUpInside)
        green_btn.addTarget(self, action: #selector(colorPressed), for: .touchUpInside)
        
        rand1_btn.addTarget(self, action: #selector(effectPressed), for: .touchUpInside)
        rand2_btn.addTarget(self, action: #selector(effectPressed), for: .touchUpInside)
        seq1_btn.addTarget(self, action: #selector(effectPressed), for: .touchUpInside)
        seq2_btn.addTarget(self, action: #selector(effectPressed), for: .touchUpInside)
        bum1_btn.addTarget(self, action: #selector(effectPressed), for: .touchUpInside)
        bum2_btn.addTarget(self, action: #selector(effectPressed), for: .touchUpInside)
        caleid_btn.addTarget(self, action: #selector(effectPressed), for: .touchUpInside)
        strobe_btn.addTarget(self, action: #selector(effectPressed), for: .touchUpInside)
    }
    
    private func updatePower() {
        // Power indicator
        let power_img = Settings.power <= 0 ? #imageLiteral(resourceName: "ic_power_off") : #imageLiteral(resourceName: "ic_power_on")
        power_btn.setImage(power_img, for: .normal)
        if(Settings.power <= 0) {
            // Go to home
            self.tabBarController?.selectedIndex = Settings.has_cromo != 2 ? 0 : 1
            
            // Control access to chromo
            if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray,
               let tabBarItem = arrayOfTabBarItems[Settings.has_cromo != 2 ? 1 : 0] as? UITabBarItem {
                tabBarItem.isEnabled = false
            }
        }
    }
    
    @IBAction func onTargetChange(_ ctrl: UISegmentedControl) {
        setViewsFor(tgt: ctrl.selectedSegmentIndex)
    }
    
    private func setViewsFor(tgt: Int){
        target = tgt
        if(Settings.n_spotleds <= 0 && target == 0) { target = 1 }
        if(Settings.n_stripleds <= 0 && target == 1) { target = 0 }
        targetChromo_sbt.selectedSegmentIndex = target
        
        if(tgt == 0) {
            setCtrlSelected(state: Settings.spot_state, color: Settings.spot_static, select: true)
            speed_sld.value = Float(Settings.spot_speed)
            bright_sld.value = Float(Settings.spot_bright)
        } else {
            setCtrlSelected(state: Settings.strip_state, color: Settings.strip_static, select: true)
            speed_sld.value = Float(Settings.strip_speed)
            bright_sld.value = Float(Settings.strip_bright)
        }
    }
    
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
    
    @objc private func colorPressed(button: UIButton) {
        let tag = button.tag - 10       // Tags from 10 to 18, Colors from 0 to 8
        
        if(target == 0) {
            Utils.sendCommand(cmd: TubCommands.SPOT_STATIC_CROMO, value: tag, word: nil)
            Settings.spot_state = 1
            Settings.spot_static = tag
        } else {
            Utils.sendCommand(cmd: TubCommands.STRIP_STATIC_CROMO, value: tag, word: nil)
            Settings.strip_state = 1
            Settings.strip_state = tag
        }
        setCtrlSelected(state: 1, color: tag, select: true)
    }
    
    @objc private func effectPressed(button: UIButton) {
        let tag = button.tag - 20       // Tags from 22 to 29, Effects from 2 to 9
        
        switch tag {
        case 2:
            if(target == 0) {
                Utils.sendCommand(cmd: TubCommands.SPOT_RND_1, value: nil, word: nil)
            } else {
                Utils.sendCommand(cmd: TubCommands.STRIP_RND_1, value: nil, word: nil)
            }
        case 3:
            if(target == 0) {
                Utils.sendCommand(cmd: TubCommands.SPOT_RND_2, value: nil, word: nil)
            } else {
                Utils.sendCommand(cmd: TubCommands.STRIP_RND_2, value: nil, word: nil)
            }
        case 4:
            if(target == 0) {
                Utils.sendCommand(cmd: TubCommands.SPOT_SEQ_1, value: nil, word: nil)
            } else {
                Utils.sendCommand(cmd: TubCommands.STRIP_SEQ_1, value: nil, word: nil)
            }
        case 5:
            if(target == 0) {
                Utils.sendCommand(cmd: TubCommands.SPOT_SEQ_2, value: nil, word: nil)
            } else {
                Utils.sendCommand(cmd: TubCommands.STRIP_SEQ_2, value: nil, word: nil)
            }
        case 6:
            if(target == 0) {
                Utils.sendCommand(cmd: TubCommands.SPOT_BMR_1, value: nil, word: nil)
            } else {
                Utils.sendCommand(cmd: TubCommands.STRIP_BMR_1, value: nil, word: nil)
            }
        case 7:
            if(target == 0) {
                Utils.sendCommand(cmd: TubCommands.SPOT_BMR_2, value: nil, word: nil)
            } else {
                Utils.sendCommand(cmd: TubCommands.STRIP_BMR_2, value: nil, word: nil)
            }
        case 8:
            if(target == 0) {
                Utils.sendCommand(cmd: TubCommands.SPOT_CLD, value: nil, word: nil)
            } else {
                Utils.sendCommand(cmd: TubCommands.STRIP_CLD, value: nil, word: nil)
            }
        case 9:
            if(target == 0) {
                Utils.sendCommand(cmd: TubCommands.SPOT_STROBE, value: nil, word: nil)
            } else {
                Utils.sendCommand(cmd: TubCommands.STRIP_STROBE, value: nil, word: nil)
            }
        default:
            return
        }
        
        if(target == 0) {
            Settings.spot_state = tag
        } else {
            Settings.strip_state = tag
        }
        setCtrlSelected(state: tag, color: 0, select: true)
        
    }
    
    private func setCtrlSelected(state: Int, color: Int = 10, select: Bool) {
        
        if(select) { setCtrlSelected(state: sel_effect, color: sel_color, select: false) }
        let textColor = select ?
            UIColor.init(named: "iconAct_color") ?? UIColor.systemGreen :
            UIColor.init(named: "title_color") ?? UIColor.systemGreen
        
        switch state {
        case 0:
            return
        case 1:
            switch color {
            case 0:
                white_btn.normalTextColor = textColor
            case 1:
                cyan_btn.normalTextColor = textColor
            case 2:
                blue_btn.normalTextColor = textColor
            case 3:
                pink_btn.normalTextColor = textColor
            case 4:
                magenta_btn.normalTextColor = textColor
            case 5:
                red_btn.normalTextColor = textColor
            case 6:
                orange_btn.normalTextColor = textColor
            case 7:
                yellow_btn.normalTextColor = textColor
            case 8:
                green_btn.normalTextColor = textColor
            default:
                let cardTxtColor = select ? textColor : UIColor.init(named: "cardtitle_color") ?? UIColor.white
                allColor_btn.setTitleColor(cardTxtColor, for: .normal)
            }
        case 2:
            rand1_btn.normalTextColor = textColor
        case 3:
            rand2_btn.normalTextColor = textColor
        case 4:
            seq1_btn.normalTextColor = textColor
        case 5:
            seq2_btn.normalTextColor = textColor
        case 6:
            bum1_btn.normalTextColor = textColor
        case 7:
            bum2_btn.normalTextColor = textColor
        case 8:
            caleid_btn.normalTextColor = textColor
        case 9:
            strobe_btn.normalTextColor = textColor
        default:
            return
        }
        
        sel_effect = state
        sel_color = color
        
        //if(color < 9) { // TODO: ALL COLOR = 0  }
        
    }
    
    @IBAction func onSpeedChange(_ sender: Any) {
        let value = Int(self.speed_sld.value)
        self.sldTimer.invalidate()
        self.sldTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false){ t in
            // Bright Slider
            let cmd = self.target == 0 ? TubCommands.SPOT_SPEED : TubCommands.STRIP_SPEED
            Utils.sendCommand(cmd: cmd, value: value, word: nil)
        }
    }
    
    @IBAction func onBrightChange(_ sender: Any) {
        let value = Int(self.bright_sld.value)
        self.sldTimer.invalidate()
        self.sldTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false){ t in
            // Bright Slider
            let cmd = self.target == 0 ? TubCommands.SPOT_BRIGHT : TubCommands.STRIP_BRIGHT
            Utils.sendCommand(cmd: cmd, value: value, word: nil)
        }
    }
    
    @IBAction func powerOffDown(_ sender: Any) {
        self.sldTimer = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: false){ t in
            Utils.sendCommand(cmd: TubCommands.SPOT_OFF, value: nil, word: nil)
            usleep(200)
            Utils.sendCommand(cmd: TubCommands.STRIP_OFF, value: nil, word: nil)
        }
    }
    
    @IBAction func powerOffUp(_ sender: Any) {
        if(self.sldTimer.isValid) {
            self.sldTimer.invalidate()
            let cmd = target == 0 ? TubCommands.SPOT_OFF : TubCommands.STRIP_OFF
            Utils.sendCommand(cmd: cmd, value: nil, word: nil)
        }
    }
    
}

// Connection e Communication delegates
extension ChromoViewController: ConnectingProtocol, CommunicationProtocol {

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
        case BathTubFeedbacks.SPOTS_STATE:
            setViewsFor(tgt: 0)
        case BathTubFeedbacks.SPOTS_COLOR:
            setViewsFor(tgt: 0)
        case BathTubFeedbacks.SPOTS_SPEED:
            setViewsFor(tgt: 0)
        case BathTubFeedbacks.SPOTS_BRIGHT:
            setViewsFor(tgt: 0)
        case BathTubFeedbacks.STRIP_STATE:
            setViewsFor(tgt: 1)
        case BathTubFeedbacks.STRIP_COLOR:
            setViewsFor(tgt: 1)
        case BathTubFeedbacks.STRIP_SPEED:
            setViewsFor(tgt: 1)
        case BathTubFeedbacks.STRIP_BRIGHT:
            setViewsFor(tgt: 1)
        default:
            return
        }
    }

    func didReceiveFeedback(about: String, text: String) {
        // Do anything
    }

}

extension ChromoViewController: DataBackProtocol {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let allColorVC = segue.destination as? ChromoAllColorViewController {
            allColorVC.target = self.target
            allColorVC.backDelegate = self
        }
    }
    
    func retrieveData(data: Any) {
        if let newTarget = data as? Int {
            target = newTarget
        }
    }
}

extension ChromoViewController: RequestProtocol {
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) { }
    
    func onError(code: Int, error: Error, source: String) { }
    
}
