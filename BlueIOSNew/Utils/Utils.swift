//
//  Utils.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import Network
import NetworkExtension

class Utils {
    
    // Parse the feedback string into a key value pair
    static func getParsedFeedback(feedback: String) -> [Substring]? {
        var fbk = feedback
        fbk = fbk.trimmingCharacters(in: .whitespacesAndNewlines)
        fbk = fbk.replacingOccurrences(of: BLEDefs.CMD_START, with: "")
        fbk = fbk.replacingOccurrences(of: BLEDefs.CMD_END, with: "")
        var parsed = fbk.split(separator: BLEDefs.CMD_SEPARATOR)
        if(parsed.count > 1){
            let key = parsed.removeFirst()
            let value = parsed.joined(separator: " ")
            parsed.removeAll()
            parsed.append(key)
            parsed.append(Substring(value))

            return parsed
        } else {
             return nil
        }
    }
    
    // Send the command middleware, route the command to the connected service
    static func sendCommand(cmd: String, value: Int?, word: String?) {
        var m_code = ""
        var command = ""
        
        // Add the beginning marker
        if(cmd != TubCommands.WIFI) { command = ":" }
        // Add the password
        command += "\(Settings.tub_pswd1) "
        // Add the message code
        m_code = generateSequentialCode()
        command += "\(m_code) "
        // Add the command key
        command += "\(cmd)"
        // Add the command value
        if(value != nil) { command += String(value!) } // Add any value (If exists)
        else if(word != nil){ command += word! }       // Add any text (If exists)
        // Add the ending marker
        if(cmd != TubCommands.WIFI) { command += ";" }
        
        print("SENDING COMMAND \(command) WITH CODE \(m_code)")
        CommandQoS.addPendingCommand(code: m_code, command: command)
        
        sendRawCommand(command: command)
    }
    
    static func sendRawCommand(command: String?) {
        guard command != nil
        else { return }
        
        // Analyse the connected service to route to
        if(BLEService.it.state == Connection.State.CONNECTED) {
            BLEService.it.enqueueCommand(command: command!)
        } else if(WiFiService.it.state == Connection.State.CONNECTED) {
            WiFiService.it.sendCommand(command: command!)
        } else if(MqttService.it.state == Connection.State.CONNECTED) {
            MqttService.it.sendCommand(command: command!)
        }
    }
    
    static func sendDate() {
        let date = Date()
        let ntp = Int(date.timeIntervalSince1970)
        sendCommand(cmd: TubCommands.SET_DATE, value: nil, word: "\(ntp)")
    }
    
    private static var sequentialNumbers: [String] = (1...99).map { String(format: "%02d", $0) }
    private static var currentIndex: Int = 0

    private static func generateSequentialCode() -> String {
        let code = sequentialNumbers[currentIndex]
        currentIndex = (currentIndex + 1) % sequentialNumbers.count
        return code
    }
    
    // Verify there's a valid connection
    func isConnected() -> Bool {
        return BLEService.it.state == Connection.State.CONNECTED ||
            WiFiService.it.state == Connection.State.CONNECTED ||
            MqttService.it.state == Connection.State.CONNECTED
    }
    
    // Get the MQTT id from the pub/sub topics
    static func getMqttId(pub: String = Settings.mqtt_pub , sub: String = Settings.mqtt_sub) -> String? {
        guard
            pub.contains("_") &&
            sub.contains("_")
        else { return nil }
        
        let id1 = pub.split(separator: "_")[0]
        let id2 = sub.split(separator: "_")[0]
        
        guard id1 == id2 else {
            return nil
        }
        
        return String(id1)
    }
    
    // Disconnect from the current connected service
    static func disconnect() {
        // Analyse the connected service to disconnect from
        if(BLEService.it.state == Connection.State.CONNECTED) {
            BLEService.it.disconnect()
        } else if(WiFiService.it.state == Connection.State.CONNECTED) {
            WiFiService.it.disconnect()
        } else if(MqttService.it.state == Connection.State.CONNECTED) {
            MqttService.it.disconnect()
        }
    }
    
    static func getWiFiNetworkName() -> String? {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        monitor.start(queue: queue)
        
        let wifiInterface = monitor.currentPath.availableInterfaces.first { interface in
            interface.type == .wifi
        }
        
        if let wifiInterface = wifiInterface {
            let wifiSSID = getWiFiSSID(from: wifiInterface)
            print("SSID: \(wifiSSID ?? "Nenhum")") // Adicione esta linha para imprimir o SSID
            
            return wifiSSID
        }
        
        
        print("Nenhuma rede Wi-Fi conectada") // Adicione esta linha para indicar que nenhuma rede Wi-Fi está conectada
        return nil
    }

    static func getWiFiSSID(from interface: NWInterface) -> String? {
        let interfaceName = interface.name
        let interfaces = CNCopySupportedInterfaces() as? [String: Any]
        
        if let interfaceInfo = interfaces?[interfaceName] as? [String: Any],
           let ssidData = interfaceInfo[kCNNetworkInfoKeySSID as String] as? Data,
           let ssid = String(data: ssidData, encoding: .utf8) {
            return ssid
        }
    
        
        return nil
    }

    
    static func isNetworkReachable() -> Bool {
        return Reachability.isConnectedToNetwork()
    }
    
    static func askOffAction(vc: UIViewController) {

        // create the alert
        let alert = UIAlertController(title: "Ação ao desligar", message: "Gostaria de apenas desligar ou desligar e esvaziar também?", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Desligar", style: UIAlertAction.Style.default, handler: { action in
            Utils.sendCommand(cmd: TubCommands.POWER, value: 2, word: nil)
            Settings.power = 2
        }))
        alert.addAction(UIAlertAction(title: "Desligar e Esvaziar", style: UIAlertAction.Style.cancel, handler: { action in
                Utils.sendCommand(cmd: TubCommands.POWER, value: 0, word: nil)
        }))

        // show the alert
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func getModeString(mode: Int, source: Int) -> String {
        var string = ""
        switch(mode) {
        case ColorDefs.ColorMode.OFF.rawValue : string = "Desligado"
            case ColorDefs.ColorMode.RANDOM1.rawValue : string = "Randomico 1"
            case ColorDefs.ColorMode.RANDOM2.rawValue : string = "Randomico 2"
            case ColorDefs.ColorMode.SEQ1.rawValue : string = "Sequêncial 1"
            case ColorDefs.ColorMode.SEQ2.rawValue : string = "Sequêncial 2"
            case ColorDefs.ColorMode.BOOMERANG1.rawValue : string = "Boomerang 1"
            case ColorDefs.ColorMode.BOOMERANG2.rawValue : string = "Boomerang 2"
            case ColorDefs.ColorMode.CALEDOSCOPY.rawValue : string = "Caleidoscópio"
            case ColorDefs.ColorMode.STROBE.rawValue : string = "Strobe"
            case ColorDefs.ColorMode.STATIC.rawValue :
                switch(source) {
                case ColorDefs.ColorStatic.CYAN.rawValue : string = "Cyano"
                case ColorDefs.ColorStatic.BLUE.rawValue : string = "Azul"
                case ColorDefs.ColorStatic.PINK.rawValue : string = "Rosa"
                case ColorDefs.ColorStatic.MAGENTA.rawValue : string = "Magenta"
                case ColorDefs.ColorStatic.RED.rawValue : string = "Vermelho"
                case ColorDefs.ColorStatic.ORANGE.rawValue : string = "Laranja"
                case ColorDefs.ColorStatic.YELLOW.rawValue : string = "Amarelo"
                case ColorDefs.ColorStatic.GREEN.rawValue : string = "Verde"
                case ColorDefs.ColorStatic.CUSTOM.rawValue : string = "Custom"
                default : string = "Branco"
                }
            default : string = "Desligado"
        }
        return string
    }
    
    static func handleHTTPError(vc: UIViewController?, code: Int, msg: String? = nil) {
        guard vc != nil else { return }
        
        if(code < 500) {
            if(code == 403 || code == 401) {
                toast(vc: vc!, message: "Credenciais de login incorretas, por favor realize o login novamente", type: 2)
            } else if(msg != nil) {
                toast(vc: vc!, message: msg!, type: 2)
            }
        } else if(code < 900) {
            toast(vc: vc!, message: "Erro inesperado, tente novamente mais tarde", type: 2)
        } else {
            toast(vc: vc!, message: "Verifique sua conexão e tente novamente mais tarde", type: 2)
        }
    }
    
    static func toast(vc: UIViewController, message : String, type: Int = 0, font: UIFont = .systemFont(ofSize: 12.0)) {

        //let toastLabel = UILabel(frame: CGRect(x: vc.view.frame.size.width/2 - 75, y: vc.view.frame.size.height-100, width: 150, height: 35))
        let toastLabel = UILabel(frame: CGRect(x: 10, y: vc.view.safeAreaLayoutGuide.layoutFrame.minY+3, width: (vc.view.frame.width - 20), height: 35))
        toastLabel.numberOfLines = 0
        toastLabel.backgroundColor = type == 0 ?
            UIColor.black.withAlphaComponent(0.8)
            : type == 1 ?
                (UIColor.init(named: "toastOk_color") ?? UIColor.green).withAlphaComponent(0.8) :
                (UIColor.init(named: "toastErr_color") ?? UIColor.red).withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.firstLineHeadIndent = 8
        style.headIndent = 8
        style.tailIndent = -8
        
        toastLabel.attributedText = NSAttributedString(string: message,
                                             attributes: [NSAttributedString.Key.paragraphStyle: style])
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        vc.view.addSubview(toastLabel)
        let multiplier = Double(message.count/30) + 0.8
        UIView.animate(withDuration: 2.5, delay: (1.8 * multiplier), options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
