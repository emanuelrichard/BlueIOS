//
//  AccountOptionsViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit

class GeneralConfigViewController: UIViewController {

    @IBOutlet weak var titleNot_txt: UILabel!
    @IBOutlet weak var iaNot_swt: UISwitch!
    @IBOutlet weak var aVolNot_swt: UISwitch!
    @IBOutlet weak var volNot_sld: UISlider!
    @IBOutlet weak var offAct_sbt: UISegmentedControl!
    
    private var mTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.gotoNotifSettings))
        self.titleNot_txt.addGestureRecognizer(gestureRecognizer)
        
        iaNot_swt.isOn = Settings.inApp_notif
        if(Settings.vol_notif >= 0) { volNot_sld.value = Float(Settings.vol_notif) }
        else { enableSlider(en: false) }
        aVolNot_swt.isOn = Settings.vol_notif < 0
        offAct_sbt.selectedSegmentIndex = Settings.off_action
        
    }
    
    @objc func gotoNotifSettings(longPressGesture: UILongPressGestureRecognizer) {
        if let bundleIdentifier = Bundle.main.bundleIdentifier,
           let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
            if(UIApplication.shared.canOpenURL(appSettings)) {
                UIApplication.shared.open(appSettings)
            }
        }
    }
    
    @IBAction func inAppChange(_ sender: Any) {
        let n = iaNot_swt.isOn
        if(n) {
            Utils.toast(vc: self, message: "As notificações serão exibidas mesmo quando o aplicativo estiver aberto")
        } else {
            Utils.toast(vc: self, message: "As notificações serão exibidas apenas quando o aplicativo estiver minimizado")
        }
        Settings.saveConfigs(inApp: n, vol: nil, off: nil)
    }
    
    @IBAction func aVolChange(_ sender: Any) {
        let n = aVolNot_swt.isOn
        if(n) {
            Utils.toast(vc: self, message: "O volume da notificação será o mesmo configurado no dispositivo")
            enableSlider(en: false)
            Settings.saveConfigs(inApp: nil, vol: -1, off: nil)
            return
        }
        Utils.toast(vc: self, message: "O volume da notificação será o configurado manualmente")
        enableSlider(en: true)
        Settings.saveConfigs(inApp: nil, vol: Int(volNot_sld.value), off: nil)
    }
    
    @IBAction func volChange(_ sender: Any) {
        mTimer?.invalidate()
        mTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] (timer) in
            let v = Int(volNot_sld.value)
            if(v <= 2) {
                Utils.toast(vc: self, message: "Volumes muito baixos não são recomendados pois as notificações podem não ser percebidas")
            }
            Settings.saveConfigs(inApp: nil, vol: v, off: nil)
        }
    }
    
    private func enableSlider(en: Bool) {
        volNot_sld.isEnabled = en
        volNot_sld.alpha = en ? 1 : 0.5
    }
    
    @IBAction func offActionClick(_ sender: Any) {
        let o = offAct_sbt.selectedSegmentIndex
        switch(o) {
            case 0: Utils.toast(vc: self, message: "Apenas o painel será desligado, a banheira não será esvaziada")
            case 1: Utils.toast(vc: self, message: "O painel será desligado e a banheira será esvaziada")
            case 2: Utils.toast(vc: self, message: "Você sempre será perguntado sobre o que deseja fazer ao desligar")
        default:
            break
        }
        Settings.saveConfigs(inApp: nil, vol: nil, off: o)
    }

    @IBAction func backClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
