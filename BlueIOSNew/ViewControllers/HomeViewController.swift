//
//  HomeViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import DCKit
import MSCircularSlider
import SwiftUI

class HomeViewController: UIViewController {
    
    // UI Controls vars
    @IBOutlet weak var viwLoading: UIView!
    
    @IBOutlet weak var power_btn: UIButton!
    
    @IBOutlet weak var temp_sld: MSCircularSlider!
    @IBOutlet weak var desr_sld: MSCircularSlider!
    
    @IBOutlet weak var desr_viw: UIView!
    @IBOutlet weak var desrTitle_txt: UILabel!
    @IBOutlet weak var desr_txt: UILabel!
    @IBOutlet weak var desrUnity_txt: UILabel!
    
    @IBOutlet weak var temp_viw: UIView!
    @IBOutlet weak var separador: UIView!
    @IBOutlet weak var tempTitle_txt: UILabel!
    @IBOutlet weak var temp_txt: UILabel!
    @IBOutlet weak var tempUnity_txt: UILabel!
    
    @IBOutlet weak var lvl_ico: UIImageView!
    @IBOutlet weak var heater_ico: UIImageView!
    @IBOutlet weak var spot_ico: UIImageView!

    
    @IBOutlet weak var bomb1_act: UIButton!
    @IBOutlet weak var bomb2_act: UIButton!
    @IBOutlet weak var bomb3_act: UIButton!
    @IBOutlet weak var bomb4_act: UIButton!
    @IBOutlet weak var bomb5_act: UIButton!
    @IBOutlet weak var bomb6_act: UIButton!
    @IBOutlet weak var bomb7_act: UIButton!
    @IBOutlet weak var bomb8_act: UIButton!
    @IBOutlet weak var bomb9_act: UIButton!
    
    @IBOutlet weak var waterEntry_act: UIButton!
    @IBOutlet weak var autoOn_act: UIButton!
    @IBOutlet weak var keepWarm_act: UIButton!
    @IBOutlet weak var bubbles_act: UIButton!
    @IBOutlet weak var cascata_bt: UIButton!
    

    @IBOutlet weak var bleDisconn_ico: UIButton!
    

    @IBOutlet weak var wifiDisconn_ico: UIButton!
    

    @IBOutlet weak var mqttDisconn_ico: UIButton!
    
    //VIews
    @IBOutlet weak var view_tool_bar: UIView!
    @IBOutlet weak var conection_view: UIView!
    @IBOutlet weak var info_view: UIStackView!
    @IBOutlet weak var bombas_view: UIStackView!
    @IBOutlet weak var utilitarios_view: UIStackView!
    @IBOutlet weak var utilitarios_view2: UIStackView!
    @IBOutlet weak var logo_img: UIImageView!
    
    @IBOutlet weak var esvaziamentoView: UIView!
    @IBOutlet weak var timerRaloTxt: UILabel!
    @IBOutlet weak var esvaziandoTxt: UILabel!



    //Painel Solar
//    @IBOutlet weak var painelSolar_icon: UIImageView!
//    @IBOutlet weak var templSolar_txt: UILabel!

    
    // Standart vars
    private var tempsetTimer: Timer?
    private var updateTimer: Timer?
    
    // Calcular a largura da view
    let widthInPixels = UIScreen.main.bounds.width - 150
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Cria um gradiente com as 3 cores desejadas
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor,
            UIColor(red: 93/255, green: 143/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor
        ]
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.backgroundColor = .clear
        
        layoutHome()
        
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
        
        esvaziar()
        
        CommandQoS.startQoS()
        
    }
    
    private func layoutHome() {
        
        // Configuração da View da Barra de Ferramentas
        view_tool_bar.translatesAutoresizingMaskIntoConstraints = false
        view_tool_bar.backgroundColor = UIColor.clear // Adicione esta linha para tornar o fundo transparente
        view.addSubview(view_tool_bar)
        let guide = view.safeAreaLayoutGuide

        // Definindo as constraints da view_tool_bar
        NSLayoutConstraint.activate([
            view_tool_bar.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            view_tool_bar.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            view_tool_bar.topAnchor.constraint(equalTo: guide.topAnchor),
            view_tool_bar.heightAnchor.constraint(equalToConstant: 44.0),
            view_tool_bar.widthAnchor.constraint(equalToConstant: 50.0)
        ])
        
        // Configuração do logo dentro da view_tool_bar
        logo_img.translatesAutoresizingMaskIntoConstraints = false
        view_tool_bar.addSubview(logo_img)
        
        // Definindo as constraints do logo_img
        NSLayoutConstraint.activate([
            logo_img.widthAnchor.constraint(equalToConstant: 50.0),
            logo_img.heightAnchor.constraint(equalToConstant: 50.0),
            logo_img.centerXAnchor.constraint(equalTo: view_tool_bar.centerXAnchor),
            logo_img.centerYAnchor.constraint(equalTo: view_tool_bar.centerYAnchor),
        ])
        
        // Configuração do botão de ligar/desligar dentro da view_tool_bar
        power_btn.translatesAutoresizingMaskIntoConstraints = false
        view_tool_bar.addSubview(power_btn)
        
        // Definindo as constraints do power_btn
        NSLayoutConstraint.activate([
            power_btn.centerYAnchor.constraint(equalTo: view_tool_bar.centerYAnchor),
            power_btn.trailingAnchor.constraint(equalTo: view_tool_bar.trailingAnchor, constant: -15),
        ])

        // Adicionando a info_view à view principal
        view.addSubview(info_view)
        
        // Adicionando as ImageViews ao StackView
        addImageViewsToStackView()
        
        
        //bombas view
        bombas_view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bombas_view)

        NSLayoutConstraint.activate([
            // Centralizar verticalmente a bombas_view com relação ao safeAreaLayoutGuide da view
            bombas_view.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            // Alinhar a esquerda da bombas_view com o leadingAnchor do safeAreaLayoutGuide da view
            bombas_view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            // Configurar a propriedade de largura da bombas_view para 75 pixels
            bombas_view.widthAnchor.constraint(equalToConstant: 50),
            // Definir a altura das views internas (bomb1_act, bomb2_act, bomb3_act e bomb4_act) para 50 pixels
            bomb1_act.heightAnchor.constraint(equalToConstant: 50),
            bomb2_act.heightAnchor.constraint(equalToConstant: 50),
            bomb3_act.heightAnchor.constraint(equalToConstant: 50),
            bomb4_act.heightAnchor.constraint(equalToConstant: 50),
            bomb5_act.heightAnchor.constraint(equalToConstant: 50),
            bomb6_act.heightAnchor.constraint(equalToConstant: 50),
            bomb7_act.heightAnchor.constraint(equalToConstant: 50),
            bomb8_act.heightAnchor.constraint(equalToConstant: 50),
            bomb9_act.heightAnchor.constraint(equalToConstant: 50)
        ])

        
        // utilitarios view
        utilitarios_view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(utilitarios_view)

        NSLayoutConstraint.activate([
            // Centralizar verticalmente a utilitarios_view com relação ao safeAreaLayoutGuide da view
            utilitarios_view.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            // Alinhar a direita da utilitarios_view com o trailingAnchor do safeAreaLayoutGuide da view
            utilitarios_view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            // Configurar a propriedade de largura da utilitarios_view para 75 pixels
//            utilitarios_view.widthAnchor.constraint(equalToConstant: 75),
            // Definir a altura das views internas para 50 pixels
            keepWarm_act.heightAnchor.constraint(equalToConstant: 50),
            autoOn_act.heightAnchor.constraint(equalToConstant: 50),
            waterEntry_act.heightAnchor.constraint(equalToConstant: 50),
//            cascata_bt.heightAnchor.constraint(equalToConstant: 50),
//            bubbles_act.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        //View da temp desejada e da temp atual
        desr_viw.translatesAutoresizingMaskIntoConstraints = false
        temp_viw.translatesAutoresizingMaskIntoConstraints = false
        separador.translatesAutoresizingMaskIntoConstraints = false
        
        // Configurando as labels para ajustarem automaticamente o tamanho com base no conteúdo
        desrTitle_txt.numberOfLines = 0
        desrTitle_txt.translatesAutoresizingMaskIntoConstraints = false

        desr_txt.numberOfLines = 0
        desr_txt.translatesAutoresizingMaskIntoConstraints = false

        desrUnity_txt.numberOfLines = 0
        desrUnity_txt.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(desr_viw)
        view.addSubview(temp_viw)
        view.addSubview(separador)
        
        // Centralizar verticalmente e horizontalmente a desr_viw
        // Definir o tamanho da desr_viw
        desr_viw.heightAnchor.constraint(equalToConstant: 150).isActive = true // Defina a altura desejada
        desr_viw.widthAnchor.constraint(equalToConstant: widthInPixels).isActive = true // Defina a largura desejada

        // Centralizar a desr_viw na tela
        desr_viw.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        desr_viw.bottomAnchor.constraint(equalTo: separador.topAnchor).isActive = true
        
        desr_txt.bottomAnchor.constraint(equalTo: desr_viw.bottomAnchor).isActive = true
        desr_txt.centerXAnchor.constraint(equalTo: desr_viw.centerXAnchor).isActive = true
        desr_txt.heightAnchor.constraint(equalToConstant: 50).isActive = true // Defina a altura desejada
        if let customFont = UIFont(name: "Helvetica-Bold", size: 50) {
            desr_txt.font = customFont
        }
        
        desrUnity_txt.topAnchor.constraint(equalTo: desr_txt.topAnchor).isActive = true
        desrUnity_txt.leadingAnchor.constraint(equalTo: desr_txt.trailingAnchor).isActive = true
        
        if let customFontdesrUnity = UIFont(name: "Helvetica-Bold", size: 30) {
            desrUnity_txt.font = customFontdesrUnity
        }
        
        desrTitle_txt.bottomAnchor.constraint(equalTo: desr_txt.topAnchor).isActive = true
        desrTitle_txt.centerXAnchor.constraint(equalTo: desr_viw.centerXAnchor).isActive = true
        
        //____________
        
        tempTitle_txt.numberOfLines = 0
        tempTitle_txt.translatesAutoresizingMaskIntoConstraints = false

        temp_txt.numberOfLines = 0
        temp_txt.translatesAutoresizingMaskIntoConstraints = false

        tempUnity_txt.numberOfLines = 0
        tempUnity_txt.translatesAutoresizingMaskIntoConstraints = false
        
        temp_viw.heightAnchor.constraint(equalToConstant: 100).isActive = true // Defina a altura desejada
        temp_viw.widthAnchor.constraint(equalToConstant: widthInPixels).isActive = true // Defina a largura desejada

        // Centralizar a desr_viw na tela
        temp_viw.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        temp_viw.topAnchor.constraint(equalTo: separador.bottomAnchor).isActive = true
        
        tempTitle_txt.topAnchor.constraint(equalTo: temp_viw.topAnchor, constant: 10).isActive = true
        temp_txt.centerXAnchor.constraint(equalTo: temp_viw.centerXAnchor).isActive = true
        //temp_txt.heightAnchor.constraint(equalToConstant: 50).isActive = true // Defina a altura desejada
        if let customFontTemp = UIFont(name: "Helvetica-Bold", size: 60) {
            temp_txt.font = customFontTemp
        }
        
        tempUnity_txt.topAnchor.constraint(equalTo: temp_txt.topAnchor).isActive = true
        tempUnity_txt.leadingAnchor.constraint(equalTo: temp_txt.trailingAnchor).isActive = true
        
        if let customFonttempUnity = UIFont(name: "Helvetica-Bold", size: 40) {
            tempUnity_txt.font = customFonttempUnity
        }
        
        tempTitle_txt.bottomAnchor.constraint(equalTo: temp_txt.topAnchor).isActive = true
        tempTitle_txt.centerXAnchor.constraint(equalTo: temp_viw.centerXAnchor).isActive = true

        
        separador.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        separador.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        separador.heightAnchor.constraint(equalToConstant: 2).isActive = true // Defina a altura desejada
        separador.widthAnchor.constraint(equalToConstant: temp_sld.bounds.width - 70).isActive = true  // Defina a largura desejada
        
        print("Largura entre as views: \(temp_sld.frame.maxX) ..... \(temp_sld.frame.minX) bound \(temp_sld.bounds.minX) ..... \(temp_sld.bounds.maxX)")
        print("Largura entre as views: \(bombas_view.bounds.minX - utilitarios_view.bounds.maxX)")

        // Centralizar os MSCircularSliders programaticamente:
        // Você pode centralizá-los em relação à view pai ou a qualquer outra view que deseje usar como referência para o alinhamento.
        // Por exemplo, para centralizar na view pai:
        temp_sld.translatesAutoresizingMaskIntoConstraints = false
        desr_sld.translatesAutoresizingMaskIntoConstraints = false
        desr_sld.maximumAngle = 260.0
        desr_sld.rotationAngle = 230.0
        view.addSubview(temp_sld)
        view.addSubview(desr_sld)

        NSLayoutConstraint.activate([
            temp_sld.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            temp_sld.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            // Defina outras restrições para o tamanho do temp_sld, como largura e altura, se necessário.
            //temp_sld.heightAnchor.constraint(equalToConstant: 2).isActive = true // Defina a altura desejada
            temp_sld.widthAnchor.constraint(equalToConstant: widthInPixels - 28), // Defina a largura desejada

            desr_sld.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            desr_sld.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            // Defina outras restrições para o tamanho do desr_sld, como largura e altura, se necessário.
            //desr_sld.widthAnchor.constraint(equalToConstant: (utilitarios_view.frame.maxX - bombas_view.frame.minX)), // Defina a largura desejada
            desr_sld.widthAnchor.constraint(equalToConstant: (widthInPixels)), // Defina a largura desejada
        ])
        
        // Cria um gradiente com as 3 cores desejadas
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor,
            UIColor(red: 93/255, green: 143/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor
        ]
        
        view.addSubview(viwLoading)
        viwLoading.layer.insertSublayer(gradientLayer, at: 0)
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(hideLoadingView), userInfo: nil, repeats: false)

        // Adicionar esvaziamentoView
        esvaziamentoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(esvaziamentoView)
        
        NSLayoutConstraint.activate([
            // Posicionar esvaziamentoView abaixo da view_tool_bar com um espaçamento de 10 pontos
            esvaziamentoView.topAnchor.constraint(equalTo: view_tool_bar.bottomAnchor, constant: 10),
            
            // Definir margens laterais (ajuste conforme necessário)
            esvaziamentoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            esvaziamentoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Definir altura fixa para esvaziamentoView (ajuste conforme necessário)
            esvaziamentoView.heightAnchor.constraint(equalToConstant: 100)
        ])

    }
    
    @objc func hideLoadingView() {
        // Método chamado quando o temporizador é acionado
        
        // Oculta a view de carregamento
        viwLoading.isHidden = true
    }
    
    func configureIcon(_ icon: UIButton, in view: UIView) {
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = UIColor.customColor
        view.addSubview(icon)
    }
    
    func addImageViewToStackView(imageView: UIButton, stackView: UIStackView, size: CGSize) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size.width),
            imageView.heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
    
    func addImageViewToStackViewInfo(imageView: UIImageView, stackView: UIStackView, size: CGSize) {
        imageView.frame.size = size
        stackView.addArrangedSubview(imageView)
    }

    func addImageViewsToStackView() {
        // Adicione os UIImageViews à UIStackView com o tamanho especificado
        addImageViewToStackViewInfo(imageView: lvl_ico, stackView: info_view, size: CGSize(width: 100, height: 100))
        addImageViewToStackViewInfo(imageView: spot_ico, stackView: info_view, size: CGSize(width: 100, height: 100))
        addImageViewToStackViewInfo(imageView: heater_ico, stackView: info_view, size: CGSize(width: 100, height: 100))
        
        let iconSize = CGSize(width: 50, height: 50)
        
        let bombIndicators: [UIButton] = [bomb1_act, bomb2_act, bomb3_act, bomb4_act, bomb5_act, bomb6_act, bomb7_act, bomb8_act, bomb9_act]
        bombIndicators.forEach { addImageViewToStackView(imageView: $0, stackView: bombas_view, size: iconSize) }
        
        let utilitarios: [UIButton] = [keepWarm_act, autoOn_act, waterEntry_act]
        utilitarios.forEach { addImageViewToStackView(imageView: $0, stackView: utilitarios_view, size: iconSize) }
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
            updateSpot()
            updateWaterEntry()
            updateAutoOn()
            updateKeepWarm()
            updateBubbles()
            updateCascata()
            updateBomb1()
            updateBomb2()
            updateBomb3()
            updateBomb4()
            setupConns()
            
            saveTubLocally()
            
            esvaziar()

        } else {
            if let pvc = self.navigationController?.viewControllers[1] {
                self.navigationController?.popToViewController(pvc, animated: true)
            }
        }
    }
    
    func loading(show: Bool) {
        //viwLoading.isHidden = !show
        //viwLoading.isUserInteractionEnabled = show
        //tabBarController?.tabBar.isHidden = show
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
        lvl_ico.tintColor = .nivelColor
        spot_ico.tintColor = .white
        
        // Initializing bomb indicators and other controls
        let bombIndicators: [UIButton?] = [
            bomb1_act, bomb2_act, bomb3_act, bomb4_act, bomb5_act,
            bomb6_act, bomb7_act, bomb8_act, bomb9_act,
            waterEntry_act, autoOn_act, keepWarm_act, bubbles_act, cascata_bt
        ]
        
        bombIndicators.forEach { $0?.tintColor = .lightGray }
    }
    
    func esvaziar() {
        DispatchQueue.main.async {
            
            if (Settings.ralo == 100 ) {
                self.timerRaloTxt?.isHidden = true
                self.esvaziandoTxt?.isHidden = true
                
                let horas = Settings.tempoEsvaziar / 3600
                let minutos = (Settings.tempoEsvaziar % 3600) / 60
                let segundos = Settings.tempoEsvaziar % 60
                
                print("Settings: ralo = \(Settings.ralo), power = \(Settings.power), tempoEsvaziar = \(Settings.tempoEsvaziar)")
                print("Tempo para esvaziar: \(horas)h \(minutos)m \(segundos)s")
                self.timerRaloTxt.text = "\(horas)h \(minutos)m \(segundos)s"

                
                if (Settings.power > 0) {
                    DispatchQueue.main.async {
//                        self.timerRaloTxt.text = "\(horas)h \(minutos)m \(segundos)s"
                    }
                } else {
                    self.timerRaloTxt?.isHidden = false
                    self.esvaziandoTxt?.isHidden = false
                }
            }
            else {
                self.timerRaloTxt?.isHidden = true
                self.esvaziandoTxt?.isHidden = true
            }
        }
    }
    
    // Actions
    @IBAction func powerAction(_ sender: Any) {
        // Verifica se a energia está desligada
        if(Settings.power <= 0) {
            // Envia comando para ligar a energia
            Utils.sendCommand(cmd: TubCommands.POWER, value: 1, word: nil)
            // Atualiza a configuração de energia para ligada
            Settings.power = 1
        } else {
            // Inicializa a variável p com valor 0
            var p = 0;
            // Verifica se há drenagem
            if(Settings.has_drain > 0) {
                // Define a ação de desligamento com base na configuração
                switch(Settings.off_action) {
                    case 0: p = 2
                    case 1: p = 0
                    case 2: p = -1
                    default: break
                }
            }
            // Verifica se a configuração de ralo está vazia
            if(Settings.ralo_on_off.isEmpty) {
                // Envia comando para desligar a energia com a ação definida
                Utils.sendCommand(cmd: TubCommands.POWER, value: p, word: nil)
                // Atualiza a configuração de energia para desligada
                Settings.power = 0
            } else {
                // Pergunta ao usuário qual ação tomar ao desligar
                Utils.askOffAction(vc: self)
            }
            // Atualiza a configuração de energia para desligada
            Settings.power = 0
        }
        // Atualiza a interface de energia
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
            if(Settings.modo_eco > 0) {
                Utils.sendCommand(cmd: TubCommands.MODO_ECO, value: 0, word: nil)
                Settings.modo_eco = 0
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
        updateKeepWarm()
        updateHeater()
    }
    
    @IBAction func bomb2Action(_ sender: Any) {
        bombAction(bombIndex: 2, button: bomb2_act)
    }
    
    @IBAction func bomb3Action(_ sender: Any) {
        bombAction(bombIndex: 3, button: bomb3_act)
    }
    
    @IBAction func bomb4Action(_ sender: Any) {
        bombAction(bombIndex: 4, button: bomb4_act)
    }

    @IBAction func bomb5Action(_ sender: Any) {
        bombAction(bombIndex: 5, button: bomb5_act)
    }

    @IBAction func bomb6Action(_ sender: Any) {
        bombAction(bombIndex: 6, button: bomb6_act)
    }

    @IBAction func bomb7Action(_ sender: Any) {
        bombAction(bombIndex: 7, button: bomb7_act)
    }

    @IBAction func bomb8Action(_ sender: Any) {
        bombAction(bombIndex: 8, button: bomb8_act)
    }

    @IBAction func bomb9Action(_ sender: Any) {
        bombAction(bombIndex: 9, button: bomb9_act)
    }

    // Common function to perform bomb action
    private func bombAction(bombIndex: Int, button: UIButton) {
        guard Settings.qt_bombs >= bombIndex else {
            Utils.toast(vc: self, message: "Controle indisponível")
            return // Controle indisponível
        }
        
        guard Settings.level >= 1 else {
            Utils.toast(vc: self, message: "Nível insuficiente")
            return // Nível máximo atingido
        }
        
        let bombSetting = Settings.bombSettingForIndex(bombIndex)
        let newBombSetting = bombSetting == 0 ? 1 : 0
        Utils.sendCommand(cmd: TubCommands.bombCommandForIndex(bombIndex), value: newBombSetting, word: nil)
        Settings.updateBombSettingForIndex(bombIndex, newValue: newBombSetting)

        switch bombIndex {
        case 2: return updateBomb2()
        case 3: return updateBomb3()
        case 4: return updateBomb4()
        case 5: return updateBomb5()
        case 6: return updateBomb6()
        case 7: return updateBomb7()
        case 8: return updateBomb8()
        case 9: return updateBomb9()
        default: return Utils.toast(vc: self, message: "Controle indisponível")
        }
    }
    

    @IBAction func waterEntryAction(_ sender: Any) {
//        if(Settings.has_waterctrl < 1) {
//            Utils.toast(vc: self, message: "Controle indisponível")
//            return //Controle indisponível
//        }
        
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
        if(Settings.banheira_com_aquecedor != "habilitado") {
            Utils.toast(vc: self, message: "Controle indisponível")
            return //Controle indisponível
        }
        
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
        if(Settings.banheira_com_aquecedor != "habilitado") {
            Utils.toast(vc: self, message: "Controle indisponível")
            return //Controle indisponível
        }
        
        if(Settings.modo_eco > 0) {
            Utils.sendCommand(cmd: TubCommands.MODO_ECO, value: 0, word: nil)
            Settings.modo_eco = 0
        } else {
            Utils.sendCommand(cmd: TubCommands.MODO_ECO, value: 1, word: nil)
            Settings.modo_eco = 1
        }
        
        updateKeepWarm()
    }
    
    @IBAction func bubblesAction(_ sender: Any) {
        if(Settings.bubbles < 0) {
            Utils.toast(vc: self, message: "Controle indisponível")
            return //Controle indisponível
        }
        
        if(Settings.bubbles > 0) {
            Utils.sendCommand(cmd: TubCommands.BLOWER, value: 0, word: nil)
            Settings.bubbles = 1
        } else {
            Utils.sendCommand(cmd: TubCommands.BLOWER, value: 1, word: nil)
            Settings.bubbles = 0
        }
        
        updateBubbles()
    }
    
    @IBAction func cascataAction(_ sender: Any) {
        if(Settings.cascata < 0) {
            Utils.toast(vc: self, message: "Controle indisponível")
            return //Controle indisponível
        }
        
        if(Settings.cascata > 0) {
            Utils.sendCommand(cmd: TubCommands.CASCATA, value: 0, word: nil)
            Settings.cascata = 1
        } else {
            Utils.sendCommand(cmd: TubCommands.CASCATA, value: 1, word: nil)
            Settings.cascata = 0
        }
        
        updateCascata()
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
        updateBomb5()
        updateBomb6()
        updateBomb7()
        updateBomb8()
        updateBomb9()
        
        // Other indicators
        updateWaterEntry()
        updateAutoOn()
        updateKeepWarm()
        updateBubbles()
        updateCascata()
        esvaziar()
    }
    
    private func updateTemp() {
        temp_sld.currentValue = Settings.power != 0 ? Double(Settings.curr_temp - 15) : 0
        temp_txt.text = Settings.power != 0 ? String(Settings.curr_temp) : "--"
        
        if(Settings.power != 0) { warnTemp() }
        else {
            tempTitle_txt.textColor = UIColor.white
            temp_txt.textColor = UIColor.white
            tempUnity_txt.textColor =  UIColor.white
        }
        
        updateHeaterConfig()
    }
    
    private func updateDesr() {
        desr_sld.currentValue = Settings.power != 0 ? Double(Settings.desr_temp - 15) : 0
        desr_txt.text = Settings.power != 0 ? String(Settings.desr_temp) : "--"
        
        if(Settings.power != 0) { warnDesr() }
        else {
            desrTitle_txt.textColor = UIColor.white
            desr_txt.textColor = UIColor.white
            desrUnity_txt.textColor = UIColor.white
        }
        updateHeaterConfig()
    }
    
    private func updateHeaterConfig() {
        //desr_viw.isHidden = Settings.has_heater == 0
        //desr_sld.isEnabled = Settings.has_heater != 0
        if(Settings.aquecedor_on_off == 0) { warnDesr(temp: Settings.curr_temp) }
    }
    
    private func updateHeater() {
        heater_ico.tintColor = Settings.aquecedor_on_off > 0 ? UIColor.red : UIColor.white
    }
    
    private func updateTubLevels() {
        if(true) {
            lvl_ico.tintColor = UIColor.nivelColor

            switch Settings.level {
            case 1:
                lvl_ico.image = #imageLiteral(resourceName: "level_1")
            case 2:
                lvl_ico.image = #imageLiteral(resourceName: "level_2")
            default:
                lvl_ico.image = #imageLiteral(resourceName: "level_0")
            }
            
        } else {
            lvl_ico.tintColor = UIColor.nivelColor
            lvl_ico.image = #imageLiteral(resourceName: "level_0")
        }
    }
    
    private func updateBomb1() {
        updateBombCommon(bombButton: bomb1_act, bombSetting: Settings.bomb_1, bombQuantity: Settings.qt_bombs >= 1)
    }

    private func updateBomb2() {
        updateBombCommon(bombButton: bomb2_act, bombSetting: Settings.bomb_2, bombQuantity: Settings.qt_bombs >= 2)
    }

    private func updateBomb3() {
        updateBombCommon(bombButton: bomb3_act, bombSetting: Settings.bomb_3, bombQuantity: Settings.qt_bombs >= 3)
    }

    private func updateBomb4() {
        updateBombCommon(bombButton: bomb4_act, bombSetting: Settings.bomb_4, bombQuantity: Settings.qt_bombs >= 4)
    }
    private func updateBomb5() {
        updateBombCommon(bombButton: bomb5_act, bombSetting: Settings.bomb_5, bombQuantity: Settings.qt_bombs >= 5)
    }

    private func updateBomb6() {
        updateBombCommon(bombButton: bomb6_act, bombSetting: Settings.bomb_6, bombQuantity: Settings.qt_bombs >= 6)
    }

    private func updateBomb7() {
        updateBombCommon(bombButton: bomb7_act, bombSetting: Settings.bomb_7, bombQuantity: Settings.qt_bombs >= 7)
    }

    private func updateBomb8() {
        updateBombCommon(bombButton: bomb8_act, bombSetting: Settings.bomb_8, bombQuantity: Settings.qt_bombs >= 8)
    }
    
    private func updateBomb9() {
        updateBombCommon(bombButton: bomb9_act, bombSetting: Settings.bomb_9, bombQuantity: Settings.qt_bombs >= 9)
    }

    // Common function to update bomb buttons
    private func updateBombCommon(bombButton: UIButton, bombSetting: Int, bombQuantity: Bool) {
        if(Settings.cooling > 0 && bombButton == bomb1_act) {
            bombButton.tintColor = UIColor.yellow
            return
        }
        if(Settings.power <= 0) {
            bombButton.isHidden = true
            return
        }
        
        bombButton.isEnabled = bombQuantity
        bombButton.isHidden = !bombQuantity
        
        bombButton.tintColor = bombSetting != 0 ? UIColor.systemGreen : UIColor(named: "Icon_OFF")
    }
    
    private func updateSpot() {
        if(Settings.spot_state <= 0){
            spot_ico.tintColor = UIColor.white
        } else if(Settings.spot_state == 1) {
            switch Settings.spot_static {
            case 9:
                spot_ico.tintColor = UIColor.white
            case 1:
                spot_ico.tintColor = UIColor.cyan
            case 2:
                spot_ico.tintColor = UIColor.blue
            case 3:
                spot_ico.tintColor = UIColor.systemPink
            case 4:
                spot_ico.tintColor = UIColor.magenta
            case 5:
                spot_ico.tintColor = UIColor.red
            case 6:
                spot_ico.tintColor = UIColor.orange
            case 7:
                spot_ico.tintColor = UIColor.yellow
            case 8:
                spot_ico.tintColor = UIColor.green
            default:
                spot_ico.tintColor = UIColor(named: "Icon_OFF")
            }
        } else {
            spot_ico.tintColor = UIColor(named: "Icon_OFF")
        }
    }
    
    private func updateWaterEntry() {
        if(Settings.power <= 0 || Settings.waterctrl == -1) {
            waterEntry_act.tintColor = UIColor(named: "Icon_OFF")
            waterEntry_act.isHidden = true
            return
        }
        
        waterEntry_act.tintColor = Settings.waterctrl != 0 ? UIColor.systemYellow : UIColor(named: "Icon_OFF")
        waterEntry_act.isHidden = false
    }
    
    private func updateAutoOn() {
        if(Settings.power <= 0) {
            autoOn_act.tintColor = UIColor(named: "Icon_OFF")
            return
        }
        
        autoOn_act.tintColor = Settings.auto_on != 0 ? UIColor.orange : UIColor(named: "Icon_OFF")
    }
    
    private func updateKeepWarm() {
        if(Settings.power <= 0) {
            keepWarm_act.tintColor = UIColor(named: "Icon_OFF")
            //keepWarm_act.isHidden = true
            return
        }
        
        keepWarm_act.tintColor = Settings.modo_eco != 0 ? UIColor.systemGreen : UIColor(named: "Icon_OFF")
    }
    
    private func updateCascata() {
        if(Settings.power <= 0 || Settings.cascata == -1) {
            cascata_bt.tintColor = UIColor(named: "Icon_OFF")
            cascata_bt.isHidden = true
            return
        }

        cascata_bt.tintColor = Settings.cascata != 0 ? UIColor.blue : UIColor(named: "Icon_OFF")
        cascata_bt.isHidden = false
    }
    
    private func updateBubbles() {
        if(Settings.power <= 0 || Settings.bubbles == -1) {
            bubbles_act.tintColor = UIColor(named: "Icon_OFF")
            bubbles_act.isHidden = true
            return
        }
                
        bubbles_act.tintColor = Settings.bubbles != 0 ? UIColor.blue : UIColor(named: "Icon_OFF")
        bubbles_act.isHidden = false
    }
    
    private func setupConns() {
        var up = BLEService.it.state == Connection.State.CONNECTED
        var color = up ? UIColor.conectedColor : UIColor.customColor
        print("BLE UP: \(up)")
        bleDisconn_ico.tintColor = up ? UIColor.conectedColor : UIColor.customColor

        
        up = WiFiService.it.state == Connection.State.CONNECTED
        color = up ? UIColor.conectedColor : UIColor.customColor
        print("WIFI UP: \(up)")
        wifiDisconn_ico.tintColor = color


        up = MqttService.it.state == Connection.State.CONNECTED
        color = up ? UIColor.conectedColor : UIColor.customColor
        print("MQTT UP: \(up)")
        mqttDisconn_ico.tintColor = color

    }
    
    private func warnTemp(temp: Int = Settings.curr_temp) {
        tempTitle_txt.textColor = UIColor.white
        if(temp >= 36) {
            temp_txt.textColor = UIColor.white
            tempUnity_txt.textColor = UIColor.white
            temp_sld.filledColor = UIColor.systemRed
        } else {
            temp_txt.textColor = UIColor.white
            tempUnity_txt.textColor = UIColor.white
            temp_sld.filledColor = UIColor.cyan
        }
    }
    
    private func warnDesr(temp: Int = Settings.desr_temp) {
        desrTitle_txt.textColor = UIColor.white
        if(temp >= 36) {
            desr_txt.textColor = UIColor.orange
            desrUnity_txt.textColor = UIColor.orange
            desr_sld.filledColor = UIColor.orange
        } else {
            desr_txt.textColor = UIColor.white
            desrUnity_txt.textColor = UIColor.white
            desr_sld.filledColor = UIColor.blue
        }
    }
}

extension HomeViewController: MSCircularSliderDelegate {

    func circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool) {
        // Atualiza o texto do desr_txt com base no valor do slider
        self.desr_txt.text = Settings.power != 0 ? "\(Int(value) + 15)" : "--"

        // Chama a função warnDesr(temp:) para executar a lógica relacionada ao valor do slider
        warnDesr(temp: Int(value) + 15)

        print(value)

        // Verifica se a alteração do valor foi feita pelo usuário (toque no slider)
        if fromUser {
            // Invalida o timer anterior, se existir, para evitar chamadas duplicadas
            self.tempsetTimer?.invalidate()
            // Chama a função warnDesr(temp:) para executar a lógica relacionada ao valor do slider
            warnDesr(temp: Int(value) + 15)

            // Cria um novo timer para aguardar 0.3 segundos antes de enviar o comando
            self.tempsetTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { t in
                Utils.sendCommand(cmd: TubCommands.TEMP_SET, value: Int(value) + 15, word: nil)
            }
        }
    }

}

extension HomeViewController: ConnectingProtocol, CommunicationProtocol {
    func didReceiveFeedback(about: String, text: String) {
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
        case BathTubFeedbacks.BOMB2_STATE:
            updateBomb2()
        case BathTubFeedbacks.BOMB3_STATE:
            updateBomb3()
        case BathTubFeedbacks.BOMB4_STATE:
            updateBomb4()
        case BathTubFeedbacks.BOMB5_STATE:
            updateBomb5()
        case BathTubFeedbacks.BOMB6_STATE:
            updateBomb6()
        case BathTubFeedbacks.BOMB7_STATE:
            updateBomb7()
        case BathTubFeedbacks.BOMB8_STATE:
            updateBomb8()
        case BathTubFeedbacks.BOMB9_STATE:
            updateBomb9()
        case BathTubFeedbacks.HEATER_STATE:
            updateHeater()
        case BathTubFeedbacks.SPOTS_STATE:
            updateSpot()
        case BathTubFeedbacks.SPOTS_COLOR:
            updateSpot()
        case BathTubFeedbacks.WATER_CTRL:
            updateWaterEntry()
        case BathTubFeedbacks.AUTO_ON:
            updateAutoOn()
        case BathTubFeedbacks.LEVEL_STATE:
            //Notifications.notify(title: "Banheira em nível máximo", message: "Tudo pronto para seu banho", reason: about)
            updateTubLevels()
        case BathTubFeedbacks.COOLING:
            updateBomb1()
        case BathTubFeedbacks.MODO_ECO:
            updateKeepWarm()
        default:
            return
        }
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
        case BathTubFeedbacks.BOMB2_STATE:
            updateBomb2()
        case BathTubFeedbacks.BOMB3_STATE:
            updateBomb3()
        case BathTubFeedbacks.BOMB4_STATE:
            updateBomb4()
        case BathTubFeedbacks.BOMB5_STATE:
            updateBomb5()
        case BathTubFeedbacks.BOMB6_STATE:
            updateBomb6()
        case BathTubFeedbacks.BOMB7_STATE:
            updateBomb7()
        case BathTubFeedbacks.BOMB8_STATE:
            updateBomb8()
        case BathTubFeedbacks.BOMB9_STATE:
            updateBomb9()
        case BathTubFeedbacks.HEATER_STATE:
            updateHeater()
        case BathTubFeedbacks.SPOTS_STATE:
            updateSpot()
        case BathTubFeedbacks.SPOTS_COLOR:
            updateSpot()
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
        case BathTubFeedbacks.CASCATA:
            updateCascata()
        case BathTubFeedbacks.BLOWER:
            updateBubbles()
        case BathTubFeedbacks.RALO:
            esvaziar()
        case BathTubFeedbacks.TEMPO_ESVAZIAR:
            esvaziar()
        default:
            return
        }
    }
    
    
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
        
}

extension HomeViewController: RequestProtocol {
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) { }
    
    func onError(code: Int, error: Error, source: String) { }
    
}


extension UIColor {
    static let customColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    static let nivelColor = UIColor.white
    static let conectedColor = UIColor.green
}

extension Settings {
    static func bombSettingForIndex(_ index: Int) -> Int {
        switch index {
        case 2: return bomb_2
        case 3: return bomb_3
        case 4: return bomb_4
        case 5: return bomb_5
        case 6: return bomb_6
        case 7: return bomb_7
        case 8: return bomb_8
        case 9: return bomb_9
        default: return 0
        }
    }

    static func updateBombSettingForIndex(_ index: Int, newValue: Int) {
        switch index {
        case 2: bomb_2 = newValue
        case 3: bomb_3 = newValue
        case 4: bomb_4 = newValue
        case 5: bomb_5 = newValue
        case 6: bomb_6 = newValue
        case 7: bomb_7 = newValue
        case 8: bomb_8 = newValue
        case 9: bomb_9 = newValue
        default: break
        }
    }

}

extension TubCommands {
    static func bombCommandForIndex(_ index: Int) -> String {
        return "s \(index) "
    }
}
