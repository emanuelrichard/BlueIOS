//
//  ChromoAllColorViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import FlexColorPicker

class ChromoAllColorViewController: UIViewController {
    
    @IBOutlet weak var targetChromo_sbt: UISegmentedControl!
    
    @IBOutlet weak var pckAllColor: RadialPaletteControl!
    @IBOutlet weak var backButton: UIButton!
    
    var target = 0
    var backDelegate: DataBackProtocol?
    private var sldTimer: Timer = Timer.scheduledTimer(withTimeInterval:  0.1, repeats: false) { t in }
    
    override func viewDidAppear(_ animated: Bool) {
        targetChromo_sbt.selectedSegmentIndex = target
        
        // Assumes BLE service responses
        BLEService.it.delegates(ble: nil, conn: self, comm: self).ok()
        
        // Assume responses in Wifi
        WiFiService.it.delegates(conn: self, comm: self).ok()
        
        // Assume responses in MQTT
        MqttService.it.delegates(conn: self, comm: self).ok()
    }
    
    @IBAction func onTargetChange(_ ctrl: UISegmentedControl) {
        target = ctrl.selectedSegmentIndex
    }
    
    @IBAction func allColorChange(_ sender: Any) {
        sldTimer.invalidate()
                sldTimer = Timer.scheduledTimer(withTimeInterval:  0.3, repeats: false) { t in
                    let color = self.pckAllColor.selectedColor.hsbColor.asTupleNoAlpha()
                    let cmd = self.target == 0 ?
                        TubCommands.SPOT_STATIC_HSL + "\(Int(color.hue * 100 * 3.6)) \(Int(color.saturation * 100)) \(ColorDefs.HSBBrightScale[Settings.spot_bright])" :
                        TubCommands.STRIP_STATIC_HSL + "\(Int(color.hue * 100 * 3.6)) \(Int(color.saturation * 100)) \(ColorDefs.HSBBrightScale[Settings.strip_bright])"
                    Utils.sendCommand(cmd: cmd, value: nil, word: nil)
                }
    }
    
    @IBAction func backClick(_ sender: Any) {
        backDelegate?.retrieveData(data: target)
        navigationController?.popViewController(animated: true)
    }
    
}

// Connection e Communication delegates
extension ChromoAllColorViewController: ConnectingProtocol, CommunicationProtocol {

    func didStartConnectingTub() {
        // Do anything
    }

    func didConnectTub() {
        // Do anything
    }

    func didDisconnectTub() {
        Settings.resetAll()
        navigationController?.popViewController(animated: true)
    }

    func didFail() {
        Settings.resetAll()
    }

    func didReceiveFeedback(about: String, value: Int) {
        // Do anything
    }

    func didReceiveFeedback(about: String, text: String) {
        // Do anything
    }

}
