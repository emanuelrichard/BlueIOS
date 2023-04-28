//
//  TubAddViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import DCKit
import CoreLocation

class TubAddViewController: UIViewController {
    
    var delegate: DataBackProtocol? = nil
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var step1_cv: UIView!
    @IBOutlet weak var step2_cv: UIView!
    @IBOutlet weak var step3_cv: UIView!
    @IBOutlet weak var step4_cv: UIView!
    @IBOutlet weak var next_btn: DCBorderedButton!
    
    private var step2VC: Step2ViewController? = nil
    private var step3VC: Step3ViewController? = nil
    private var step4VC: Step4ViewController? = nil
    
    private var mTimer: Timer?
    private var step = 1
    private var tmp_pswd = ""
    private var canConn = false
    
    // Step 1
    private var scanCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        next_btn.isHidden = true

        BLEService.it.delegates(ble: nil, conn: self, comm: self).ok()
        manageSteps()
        requestLocation()
    }
    
    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.startUpdatingLocation()
        }

    }
    
    func goTo(step: Int) {
        self.step = step
        manageSteps()
    }
    
    @IBAction func nextClick(_ sender: Any) {
        switch step {
        case 3:
            checkStep3()
        case 4:
            checkStep4()
        default:
            break
        }
    }
    
    private func manageSteps() {
        step1_cv.isHidden = step != 1
        step2_cv.isHidden = step != 2
        step3_cv.isHidden = step != 3
        step4_cv.isHidden = step != 4
        
        switch step {
        case 1:
            step1()
        case 2:
            step2()
        case 3:
            step3()
        case 4:
            step4()
        default:
            break
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "S2" {
            if let s2 = segue.destination as? Step2ViewController {
                step2VC = s2
            }
            return
        }
        if segue.identifier == "S3" {
            if let s3 = segue.destination as? Step3ViewController {
                step3VC = s3
                step3VC?.restartSteps = {
                    BLEService.it.disconnect()
                    self.goTo(step: 1)
                }
            }
            return
        }
        if segue.identifier == "S4" {
            if let s4 = segue.destination as? Step4ViewController {
                step4VC = s4
            }
            return
        }
    }
    
    @IBAction func cancelClick(_ sender: Any) {
        exitSteps()
    }
    
}

// MARK: Step 1
extension TubAddViewController {
    func step1() {
        print("------ Step 1 ------")
        step = 1
        
        next_btn.isHidden = true
        
        BLEService.it.resetNearest()
        BLEService.it.startScan()
        
        mTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ [self] t in
            scanCounter += 1
            print("Timer - \(self.scanCounter) seconds")
            if(scanCounter == 1){
                BLEService.it.stopScan()
                canConn = true
            }
            if(scanCounter == 2) {
                BLEService.it.startScan()
                canConn = false
            }
            if(scanCounter == 4){
                BLEService.it.stopScan()
                canConn = true
            }
            if(scanCounter == 5) {
                BLEService.it.startScan()
                canConn = false
            }
            if(scanCounter == 8){
                BLEService.it.stopScan()
                canConn = true
            }
            if(canConn && (scanCounter == 8 || BLEService.it.nearestRSSI >= -60)) {
                scanCounter = 0
                mTimer?.invalidate()
                
                if(BLEService.it.nearestRSSI <= -64) {
                    // ERR - restart step 1
                    Utils.toast(vc: self, message: "Aproxime-se do painel de sua banheira", type: 0)
                    self.goTo(step: 1)
                } else {
                    print("SELECTED: \(BLEService.it.nearestBtid!)")
                    print("Ok - step 2 my friend !")
                    self.goTo(step: 2)
                }
            }
            
        }
    }
}

// MARK: Step 2
extension TubAddViewController: ConnectingProtocol {
    func step2() {
        print("------ Step 2 ------")
        step = 2
        
        next_btn.isHidden = true
        
        let sel_BTid = BLEService.it.nearestBtid!
        if let db = RealmDB.it {
            let tub = db.object(ofType: Tub.self, forPrimaryKey: sel_BTid)
            if(tub != nil) {
                Utils.toast(vc: self, message: "Banheira próxima já cadastrada", type: 0)
                self.goTo(step: 1)
                return
            }
        }
        
        step2VC?.connecting_txt.text = "Aguarde, conectando à \(sel_BTid)"
            
        BLEService.it.connectNearestTub()
    }
    
    func didStartConnectingTub() { }
    
    func didConnectTub() {
        print("Ok - step 3 my friend !")
        self.goTo(step: 3)
    }
    
    func didDisconnectTub() { }
    
    func didFail() { print("ERR - restart step two") }
}

// MARK: Step 3
extension TubAddViewController {
    func step3() {
        print("------ Step 3 ------")
        step = 3
        
        next_btn.isHidden = false
        
        let sel_BTid = BLEService.it.nearestBtid!.suffix(4)
        step3VC?.connected_txt.text = "Conectado à BLE \(sel_BTid)"
    }
    
    func checkStep3() {
        if let tubpswd = step3VC?.tubpswd_edt.text {
            if(tubpswd.count < 6) {
                Utils.toast(vc: self, message: "A senha deve possuir 6 caracteres", type: 2)
                return
            }
            
            if(tmp_pswd.isEmpty) {
                Utils.toast(vc: self, message: "Pressione as teclas no painel e confirme a senha", type: 2)
                return
            }
            
            if(tmp_pswd == tmp_pswd) {
                Settings.tub_pswd1 = tmp_pswd
                Utils.sendCommand(cmd: TubCommands.TUB_PSWD, value: nil, word: nil)
                
                mTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
                    // If no password 1 found, set it
                    let scmd = "\(1) \(self.tmp_pswd)"
                    Utils.sendCommand(cmd: TubCommands.TUB_PSWD, value: nil, word: scmd)
                }
                
            } else {
                Utils.toast(vc: self, message: "Senha incorreta", type: 2)
                return
            }
        }
        
    }
}

// MARK: Step 4
extension TubAddViewController {
    func step4() {
        print("------ Step 4 ------")
        
        next_btn.setTitle("Finalizar", for: .normal)
        Utils.sendCommand(cmd: TubCommands.STATUS, value: nil, word: nil)
    }
    
    func checkStep4() {
        step = 4
        
        if let name = step4VC?.tubname_edt.text {
            if(name.isEmpty) {
                Utils.toast(vc: self, message: "Digite um nome primeiro", type: 2)
                return
            }
            
            Settings.tubname = name
            if let tub = Tub.initFromSettings() {
                
                let tz = TimeZone.current.secondsFromGMT()
                Utils.sendCommand(cmd: TubCommands.TIMEZONE, value: tz, word: nil)
                
                RequestManager.it.saveTubInfoRequest()
                
                delegate?.retrieveData(data: tub)
                exitSteps()
            } else {
                Utils.toast(vc: self, message: "Algo deu errado, por favor tente novamente", type: 2)
                //goTo(step: 5)
            }
            
        }
    }
    
    func exitSteps() {
        mTimer?.invalidate()
        mTimer = nil
        BLEService.it.disconnect()
        locationManager.stopUpdatingLocation()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Step commands callback
extension TubAddViewController: CommunicationProtocol {
    func didReceiveFeedback(about: String, value: Int) {
        
    }
    
    func didReceiveFeedback(about: String, text: String) {
        switch about {
            case BathTubFeedbacks.TUB_PSWD1:
                switch step {
                case 3:
                    mTimer?.invalidate()
                    Settings.tub_pswd1 = text
                    print("Password '\(text)' found - go to step 4")
                    self.tmp_pswd = ""
                    self.goTo(step: 4)
                default:
                    break
                }
            case BathTubFeedbacks.TMP_PSWD:
                self.tmp_pswd = text
            default:
                break
        }
    }
    
}

// MARK: Location updates callback
extension TubAddViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        Settings.loc_lat = "\(locValue.latitude)"
        Settings.loc_lng = "\(locValue.longitude)"
    }
    
}
