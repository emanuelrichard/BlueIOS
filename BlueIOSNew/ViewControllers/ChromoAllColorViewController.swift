//
//  ChromoAllColorViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import FlexColorPicker
import DCKit

class ChromoAllColorViewController: UIViewController {
    
    @IBOutlet weak var targetChromo_sbt: UISegmentedControl!
    @IBOutlet weak var pckAllColor: RadialPaletteControl!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var caixaCor1: DCBorderedButton!
    @IBOutlet weak var caixaCor2: DCBorderedButton!
    @IBOutlet weak var caixaCor3: DCBorderedButton!
    
    var backgroundColors = UIColor.red // Substitua pela sua cor desejada
    var backgroundColors2 = UIColor.red // Substitua pela sua cor desejada
    var backgroundColors3 = UIColor.red // Substitua pela sua cor desejada

    var target = 0
    var backDelegate: DataBackProtocol?
    private var sldTimer: Timer = Timer.scheduledTimer(withTimeInterval:  0.1, repeats: false) { t in }
    
    var favoriteColor: UIColor = .black // Variable to store the favorite color
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cria um gradiente com as 3 cores desejadas
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor,
                                UIColor(red: 93/255, green: 143/255, blue: 250/255, alpha: 1).cgColor,
                                UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor]
        
        // Define o plano de fundo da view com o gradiente
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        configureSegmentedControlTextColors()
        
        // Configure o gesto de clique longo para o elemento de interface
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress1(_:)))
        let longPressGesture2 = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress2(_:)))
        let longPressGesture3 = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress3(_:)))
        caixaCor1.addGestureRecognizer(longPressGesture)
        caixaCor2.addGestureRecognizer(longPressGesture2)
        caixaCor3.addGestureRecognizer(longPressGesture3)
        
        if let colorData1 = UserDefaults.standard.data(forKey: "backgroundColorKey"),
           let backgroundColor1 = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData1) as? UIColor {
            // Use a cor recuperada conforme necessário.
            caixaCor1.backgroundColor = backgroundColor1
            caixaCor1.normalBackgroundColor = backgroundColor1
            caixaCor1.selectedBackgroundColor = backgroundColor1
        } else {
            caixaCor1.backgroundColor = .black
            caixaCor1.normalBackgroundColor = .black
            caixaCor1.selectedBackgroundColor = .black
        }
        
        if let colorData2 = UserDefaults.standard.data(forKey: "backgroundColorKey2"),
           let backgroundColor2 = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData2) as? UIColor {
            // Use a cor recuperada conforme necessário.
            caixaCor2.backgroundColor = backgroundColor2
            caixaCor2.normalBackgroundColor = backgroundColor2
            caixaCor2.selectedBackgroundColor = backgroundColor2
        } else {
            caixaCor2.backgroundColor = .black
            caixaCor2.normalBackgroundColor = .black
            caixaCor2.selectedBackgroundColor = .black
        }
        
        if let colorData3 = UserDefaults.standard.data(forKey: "backgroundColorKey3"),
           let backgroundColor3 = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData3) as? UIColor {
            // Use a cor recuperada conforme necessário.
            caixaCor3.backgroundColor = backgroundColor3
            caixaCor3.normalBackgroundColor = backgroundColor3
            caixaCor3.selectedBackgroundColor = backgroundColor3
        } else {
            caixaCor3.backgroundColor = .black
            caixaCor3.normalBackgroundColor = .black
            caixaCor3.selectedBackgroundColor = .black
        }
    }
    
    // Configura as cores de texto para o UISegmentedControl
    private func configureSegmentedControlTextColors() {
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        targetChromo_sbt.setTitleTextAttributes(normalTextAttributes, for: .normal)
        targetChromo_sbt.setTitleTextAttributes(selectedTextAttributes, for: .selected)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        targetChromo_sbt.selectedSegmentIndex = target
        
        // Assumes BLE service responses
        BLEService.it.delegates(ble: nil, conn: self, comm: self).ok()
        
        // Assume responses in Wifi
        WiFiService.it.delegates(conn: self, comm: self).ok()
        
        // Assume responses in MQTT
        MqttService.it.delegates(conn: self, comm: self).ok()
        
        if(Settings.n_spotleds <= 0) {
            targetChromo_sbt.setEnabled(false, forSegmentAt: 0)
            target = 1
        }
        if(Settings.n_stripleds <= 0) {
            target = 0
            targetChromo_sbt.setEnabled(false, forSegmentAt: 1)
            colorTextSegment(color: UIColor.lightGray, segment: targetChromo_sbt)
        }
    }
    
    private func colorTextSegment(color: UIColor, segment: UISegmentedControl){
        // Crie um dicionário com as configurações de texto desejadas
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: color // Altere a cor do texto aqui
        ]
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white // Altere a cor do texto selecionado aqui
        ]
        
        // Aplique as configurações ao seu UISegmentedControl
        segment.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segment.setTitleTextAttributes(selectedTextAttributes, for: .selected)
    }
    
    @IBAction func onTargetChange(_ ctrl: UISegmentedControl) {
        target = ctrl.selectedSegmentIndex
    }
    
    @IBAction func allColorChange(_ sender: Any) {
        sldTimer.invalidate()
        sldTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { t in
            let color = self.pckAllColor.selectedColor.hsbColor.asTupleNoAlpha()
//            print("colors: hue: \((color.hue) * 100 * 3.6)")
//            print("colors: sat: \(color.saturation)")
//            print("colors: brig: \(ColorDefs.HSBBrightScale[Settings.spot_bright])")
            
            let hue = (color.hue) * 100 * 3.6
            let saturation = color.saturation
            var bright = 1
            
            let rgbe_color = self.hsvToRgb(h: Float(hue), s: Float(saturation), v: Float(bright))
            
//            print("colors RGBe: \(rgbe_color.red), \(rgbe_color.green), \(rgbe_color.blue)")
            
            let cmd = self.target == 0 ?
            TubCommands.SPOT_STATIC_HSL + "\(rgbe_color.red) \(rgbe_color.green) \(rgbe_color.blue)" :
            TubCommands.STRIP_STATIC_HSL + "\(rgbe_color.red) \(rgbe_color.green) \(rgbe_color.blue)"
            Utils.sendCommand(cmd: cmd, value: nil, word: nil)
            
            // Update the favorite color and the color box
            self.favoriteColor = self.pckAllColor.selectedColor
            
        }
    }
    
    @IBAction func backClick(_ sender: Any) {
        backDelegate?.retrieveData(data: target)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func favColor1(_ sender: Any) {
        if let colorData1 = UserDefaults.standard.data(forKey: "backgroundColorKey"),
           let backgroundColor1 = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData1) as? UIColor {
            // Use a cor recuperada conforme necessário.
            let hue = backgroundColor1.hsbColor.asTupleNoAlpha().hue * 100 * 3.6
            let saturation = backgroundColor1.hsbColor.asTupleNoAlpha().saturation
            var bright = 1
            
            let rgbe_color = self.hsvToRgb(h: Float(hue), s: Float(saturation), v: Float(bright))
            
            let cmd = self.target == 0 ?
            TubCommands.SPOT_STATIC_HSL + "\(rgbe_color.red) \(rgbe_color.green) \(rgbe_color.blue)" :
            TubCommands.STRIP_STATIC_HSL + "\(rgbe_color.red) \(rgbe_color.green) \(rgbe_color.blue)"
            Utils.sendCommand(cmd: cmd, value: nil, word: nil)
            
            caixaCor1.backgroundColor = backgroundColor1
            caixaCor1.normalBackgroundColor = backgroundColor1
            caixaCor1.selectedBackgroundColor = backgroundColor1
        }
    }
    
    @IBAction func favColor2(_ sender: Any) {
        if let colorData2 = UserDefaults.standard.data(forKey: "backgroundColorKey2"),
           let backgroundColor2 = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData2) as? UIColor {
            // Use a cor recuperada conforme necessário.
            let hue = backgroundColor2.hsbColor.asTupleNoAlpha().hue * 100 * 3.6
            let saturation = backgroundColor2.hsbColor.asTupleNoAlpha().saturation
            var bright = 1
            
            let rgbe_color = self.hsvToRgb(h: Float(hue), s: Float(saturation), v: Float(bright))
            
            let cmd = self.target == 0 ?
            TubCommands.SPOT_STATIC_HSL + "\(rgbe_color.red) \(rgbe_color.green) \(rgbe_color.blue)" :
            TubCommands.STRIP_STATIC_HSL + "\(rgbe_color.red) \(rgbe_color.green) \(rgbe_color.blue)"
            Utils.sendCommand(cmd: cmd, value: nil, word: nil)
            
            caixaCor2.backgroundColor = backgroundColor2
            caixaCor2.normalBackgroundColor = backgroundColor2
            caixaCor2.selectedBackgroundColor = backgroundColor2
        }
    }
    
    @IBAction func favColor3(_ sender: Any) {
        if let colorData3 = UserDefaults.standard.data(forKey: "backgroundColorKey3"),
           let backgroundColor3 = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData3) as? UIColor {
            // Use a cor recuperada conforme necessário.
            let hue = backgroundColor3.hsbColor.asTupleNoAlpha().hue * 100 * 3.6
            let saturation = backgroundColor3
                .hsbColor.asTupleNoAlpha().saturation
            var bright = 1
            
            let rgbe_color = self.hsvToRgb(h: Float(hue), s: Float(saturation), v: Float(bright))
            
            let cmd = self.target == 0 ?
            TubCommands.SPOT_STATIC_HSL + "\(rgbe_color.red) \(rgbe_color.green) \(rgbe_color.blue)" :
            TubCommands.STRIP_STATIC_HSL + "\(rgbe_color.red) \(rgbe_color.green) \(rgbe_color.blue)"
            Utils.sendCommand(cmd: cmd, value: nil, word: nil)
            
            caixaCor3.backgroundColor = backgroundColor3
            caixaCor3.normalBackgroundColor = backgroundColor3
            caixaCor3.selectedBackgroundColor = backgroundColor3
        }
    }
    
    @IBAction func handleLongPress1(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            // Código a ser executado quando o clique longo começar
            saveColors(caixaCor: caixaCor1)
            backgroundColors = favoriteColor
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: backgroundColors, requiringSecureCoding: false) {
                UserDefaults.standard.set(colorData, forKey: "backgroundColorKey")
                UserDefaults.standard.synchronize()
            }
        }
    }

    @IBAction func handleLongPress2(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            // Código a ser executado quando o clique longo começar
            saveColors(caixaCor: caixaCor2)
            backgroundColors2 = favoriteColor
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: backgroundColors2, requiringSecureCoding: false) {
                UserDefaults.standard.set(colorData, forKey: "backgroundColorKey2")
                UserDefaults.standard.synchronize()
            }
        }
    }

    @IBAction func handleLongPress3(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            // Código a ser executado quando o clique longo começar
            saveColors(caixaCor: caixaCor3)
            backgroundColors3 = favoriteColor
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: backgroundColors3, requiringSecureCoding: false) {
                UserDefaults.standard.set(colorData, forKey: "backgroundColorKey3")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func saveColors(caixaCor: DCBorderedButton){
        let colorBack = favoriteColor
        caixaCor.backgroundColor = colorBack
        caixaCor.normalBackgroundColor = colorBack
        caixaCor.selectedBackgroundColor = colorBack
    }

    func hslToRgb(h: CGFloat, s: CGFloat, l: CGFloat) -> (CGFloat, CGFloat, CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        let c = (1 - abs(2 * l - 1)) * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = l - c / 2
        
        switch h {
        case 0..<60:
            r = c + m
            g = x + m
            b = m
        case 60..<120:
            r = x + m
            g = c + m
            b = m
        case 120..<180:
            r = m
            g = c + m
            b = x + m
        case 180..<240:
            r = m
            g = x + m
            b = c + m
        case 240..<300:
            r = x + m
            g = m
            b = c + m
        default:
            r = c + m
            g = m
            b = x + m
        }
        
        return (r * 255, g * 255, b * 255)
    }

    func hsvToRgb(h: Float, s: Float, v: Float) -> (red: Int, green: Int, blue: Int) {
        let c = v * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = v - c

        var r: Float = 0
        var g: Float = 0
        var b: Float = 0

        switch h {
        case ..<60:
            r = c
            g = x
            b = 0
        case ..<120:
            r = x
            g = c
            b = 0
        case ..<180:
            r = 0
            g = c
            b = x
        case ..<240:
            r = 0
            g = x
            b = c
        case ..<300:
            r = x
            g = 0
            b = c
        default:
            r = c
            g = 0
            b = x
        }

        let red = (r + m) * 255
        let green = (g + m) * 255
        let blue = (b + m) * 255

        return (red: Int(red), green: Int(green), blue: Int(blue))
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
