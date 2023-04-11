//
//  ConfigViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit

class ConfigViewController: UIViewController {
    
    @IBOutlet weak var qtBombs_ctr: UISegmentedControl!
    @IBOutlet weak var waterEntry_ctr: UISegmentedControl!
    @IBOutlet weak var autoOn_ctr: UISegmentedControl!
    @IBOutlet weak var warmer_ctr: UISegmentedControl!
    @IBOutlet weak var tempSensor_ctr: UISegmentedControl!
    @IBOutlet weak var cromoOption_ctr: UISegmentedControl!
    @IBOutlet weak var spotMode_ctr: UISegmentedControl!
    @IBOutlet weak var stripMode_ctr: UISegmentedControl!
    
    private var canSend = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assumeDelegates()

        initCtrls()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        assumeDelegates()
    }
    
    private func assumeDelegates() {
        // Assumes BLE service responses
        BLEService.it.delegates(ble: nil, conn: self, comm: self).ok()
        
        // Assume responses in Wifi
        WiFiService.it.delegates(conn: self, comm: self).ok()
        
        // Assume responses in MQTT
        MqttService.it.delegates(conn: self, comm: self).ok()
    }
    
    private func initCtrls() {
        qtBombs_ctr.selectedSegmentIndex = Settings.qt_bombs
        waterEntry_ctr.selectedSegmentIndex = Settings.has_waterctrl
        autoOn_ctr.selectedSegmentIndex = Settings.auto_on
        warmer_ctr.selectedSegmentIndex = Settings.has_heater
        tempSensor_ctr.selectedSegmentIndex = Settings.has_temp
        cromoOption_ctr.selectedSegmentIndex = Settings.has_cromo
        spotMode_ctr.selectedSegmentIndex = Settings.spot_cmode
        stripMode_ctr.selectedSegmentIndex = Settings.strip_cmode
    }
    
    @IBAction func qtBombsClick(_ sender: Any) {
        let value = qtBombs_ctr.selectedSegmentIndex
        if(canSend) { Utils.sendCommand(cmd: TubCommands.SET_Q_BOMBS, value: value, word: nil) }
        else { canSend = true}
    }
    
    @IBAction func waterEntryClick(_ sender: Any) {
        let value = waterEntry_ctr.selectedSegmentIndex
        if(canSend) { Utils.sendCommand(cmd: TubCommands.SET_WATER_CTRL, value: value, word: nil) }
        else { canSend = true}
    }
    
    @IBAction func autoOnClick(_ sender: Any) {
        let value = autoOn_ctr.selectedSegmentIndex
        if(canSend) { Utils.sendCommand(cmd: TubCommands.SET_AUTO_ON, value: value, word: nil) }
        else { canSend = true}
    }
    
    @IBAction func warmerClick(_ sender: Any) {
        let value = warmer_ctr.selectedSegmentIndex
        if(canSend) { Utils.sendCommand(cmd: TubCommands.SET_WARMER, value: value, word: nil) }
        else { canSend = true}
    }
    
    @IBAction func tempSensorClick(_ sender: Any) {
        let value = tempSensor_ctr.selectedSegmentIndex
        if(canSend) { Utils.sendCommand(cmd: TubCommands.SET_HASTEMP, value: value, word: nil) }
        else { canSend = true}
    }
    
    @IBAction func cromoOptionClick(_ sender: Any) {
        let value = cromoOption_ctr.selectedSegmentIndex
        if(canSend) { Utils.sendCommand(cmd: TubCommands.SET_HASCROMO, value: value, word: nil) }
        else { canSend = true}
    }
    
    @IBAction func spotModeClick(_ sender: Any) {
        let value = spotMode_ctr.selectedSegmentIndex
        if(canSend) { Utils.sendCommand(cmd: TubCommands.SET_SPOT_CMODE, value: value, word: nil) }
        else { canSend = true}
    }
    
    
    @IBAction func stripModeClick(_ sender: Any) {
        let value = stripMode_ctr.selectedSegmentIndex
        if(canSend) { Utils.sendCommand(cmd: TubCommands.SET_STRIP_CMODE, value: value, word: nil) }
        else { canSend = true}
    }
    
    @IBAction func exitConfigClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
}

extension ConfigViewController: ConnectingProtocol, CommunicationProtocol {
    
    func didStartConnectingTub() {
        // Do anything
    }
    
    func didConnectTub() {
        // Do anything
    }
    
    func didDisconnectTub() {
        RequestManager.it.saveTubInfoRequest()
        
        Settings.resetAll()
        navigationController?.popViewController(animated: true)
    }
    
    func didFail() {
        RequestManager.it.saveTubInfoRequest()
        
        Settings.resetAll()
        navigationController?.popViewController(animated: true)
    }
    
    func didReceiveFeedback(about: String, value: Int) {
        switch about {
            case BathTubFeedbacks.HAS_HEATER: break
            case BathTubFeedbacks.HAS_WATER_CTRL: break
            case BathTubFeedbacks.AUTO_ON: break
            case BathTubFeedbacks.HAS_TEMP: break
            case BathTubFeedbacks.HAS_CROMO: break
            case BathTubFeedbacks.GET_SPOT_CMODE: break
            case BathTubFeedbacks.GET_STRIP_CMODE: break
            default:
                return
        }
        canSend = false
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { (timer) in
            self.canSend = true
        }
        initCtrls()
    }
    
    func didReceiveFeedback(about: String, text: String) {
    }
}
