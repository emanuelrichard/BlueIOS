//
//  GeneralConfigViewController.swift
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
    
    @IBOutlet weak var view_title: UIView!
    @IBOutlet weak var scrol_view: UIScrollView!
    @IBOutlet weak var view_config_notific: UIView!
    
    @IBOutlet weak var title_notificacao: UILabel!
    @IBOutlet weak var txt_notific_tela: UILabel!
    @IBOutlet weak var title_vol_notific: UILabel!
    @IBOutlet weak var txt_vol_dispositivo: UILabel!
    @IBOutlet weak var txt_vol_manual: UILabel!
    
    private var mTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cria um gradiente com as 3 cores desejadas
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor, UIColor(red: 102/255, green: 148/255, blue: 250/255, alpha: 1).cgColor, UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor]
        
        // Define o plano de fundo da view com o gradiente
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        
//        //View Title
//        view_title.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(view_title)
//
//        NSLayoutConstraint.activate([
//            view_title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            view_title.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            view_title.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            view_title.heightAnchor.constraint(equalToConstant: view_title.intrinsicContentSize.height)
//        ])
//
//        titleNot_txt.translatesAutoresizingMaskIntoConstraints = false
//        view_title.addSubview(titleNot_txt)
//
//        NSLayoutConstraint.activate([
//            titleNot_txt.centerXAnchor.constraint(equalTo: view_title.centerXAnchor),
//            titleNot_txt.centerYAnchor.constraint(equalTo: view_title.centerYAnchor, constant: 20)
//        ])
        
        
        //Scrol View
//        scrol_view.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrol_view)
//
//        NSLayoutConstraint.activate([
//            scrol_view.topAnchor.constraint(equalTo: view_title.bottomAnchor, constant: 80),
//            scrol_view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrol_view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrol_view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
        
        scrol_view.isScrollEnabled = true // Permitir rolagem vertical
        scrol_view.showsHorizontalScrollIndicator = false // Esconder a barra de rolagem horizontal
        
        // Dentro da Scroll view

        
        // Label title de notificação
//        title_notificacao.translatesAutoresizingMaskIntoConstraints = false
//        view_config_notific.addSubview(title_notificacao)
//        title_notificacao.textAlignment = .center
//
//
//        NSLayoutConstraint.activate([
//            // Centralizar a label horizontalmente
//            title_notificacao.centerXAnchor.constraint(equalTo: view_config_notific.centerXAnchor),
//            // Alinhar a parte superior da label com a parte superior da view_config_notific
//            title_notificacao.topAnchor.constraint(equalTo: view_config_notific.topAnchor),
//            // Definir a largura máxima da label
//            title_notificacao.widthAnchor.constraint(lessThanOrEqualTo: view_config_notific.widthAnchor),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            title_notificacao.leadingAnchor.constraint(equalTo: view_config_notific.leadingAnchor),
//            // Alinhar a direita da label com a direita da view_config_notific
//            title_notificacao.trailingAnchor.constraint(equalTo: view_config_notific.trailingAnchor)
//        ])
//
//        // Label texto de notificacao na tela
//        txt_notific_tela.translatesAutoresizingMaskIntoConstraints = false
//        view_config_notific.addSubview(txt_notific_tela)
        
        txt_notific_tela.text = "Com o aplicativo aberto,as notificações\ndeverão ser exibidas na tela:"

//        NSLayoutConstraint.activate([
//            txt_notific_tela.topAnchor.constraint(equalTo: title_notificacao.bottomAnchor, constant: 20),
//            // Definir a largura máxima da label
//            txt_notific_tela.widthAnchor.constraint(lessThanOrEqualTo: view_config_notific.widthAnchor, multiplier: 0.8, constant: 0),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            txt_notific_tela.leadingAnchor.constraint(equalTo: view_config_notific.leadingAnchor, constant: 10),
//        ])
        
        // Adicione o UISwitch como subview da view_config_notific antes da UILabel
//        view_config_notific.addSubview(iaNot_swt)
//
//        iaNot_swt.translatesAutoresizingMaskIntoConstraints = false
//
//        // Adicione as restrições para o UISwitch
//        NSLayoutConstraint.activate([
//            iaNot_swt.leadingAnchor.constraint(equalTo: txt_notific_tela.trailingAnchor, constant: 40),
//            iaNot_swt.centerYAnchor.constraint(equalTo: txt_notific_tela.centerYAnchor),
//        ])
//            
//        //Title Volume de notificacao
//        
//        view_config_notific.addSubview(title_vol_notific)
//        title_vol_notific.translatesAutoresizingMaskIntoConstraints = false
//        title_vol_notific.textAlignment = .center
//        
//        NSLayoutConstraint.activate([
//            // Centralizar a label horizontalmente
//            title_vol_notific.centerXAnchor.constraint(equalTo: view_config_notific.centerXAnchor),
//            // Alinhar a parte superior da label com a parte inferior da txt_notific_tela
//            title_vol_notific.topAnchor.constraint(equalTo: txt_notific_tela.bottomAnchor, constant: 20),
//            // Definir a largura máxima da label
//            title_vol_notific.widthAnchor.constraint(lessThanOrEqualTo: view_config_notific.widthAnchor),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            title_vol_notific.leadingAnchor.constraint(equalTo: view_config_notific.leadingAnchor),
//            // Alinhar a direita da label com a direita da view_config_notific
//            title_vol_notific.trailingAnchor.constraint(equalTo: view_config_notific.trailingAnchor)
//        ])
//        
//        // Label de texto acompanha dipositivo
//        txt_vol_dispositivo.translatesAutoresizingMaskIntoConstraints = false
//        view_config_notific.addSubview(txt_vol_dispositivo)
//        
//
//        NSLayoutConstraint.activate([
//            // Alinhar a parte superior da label com a parte inferior da txt_notific_tela
//            txt_vol_dispositivo.topAnchor.constraint(equalTo: title_vol_notific.bottomAnchor, constant: 20),
//            // Definir a largura máxima da label
//            txt_vol_dispositivo.widthAnchor.constraint(lessThanOrEqualTo: view_config_notific.widthAnchor, multiplier: 0.8, constant: 0),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            txt_vol_dispositivo.leadingAnchor.constraint(equalTo: view_config_notific.leadingAnchor, constant: 20),
//        ])
//        
//        // Adicione o UISwitch como subview da view_config_notific antes da UILabel
//        view_config_notific.addSubview(aVolNot_swt)
//        aVolNot_swt.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            aVolNot_swt.leadingAnchor.constraint(equalTo: txt_vol_dispositivo.trailingAnchor, constant: 40),
//            aVolNot_swt.centerYAnchor.constraint(equalTo: txt_vol_dispositivo.centerYAnchor),
//            aVolNot_swt.centerXAnchor.constraint(equalTo: iaNot_swt.centerXAnchor),
//        ])
//        
//        //label de texto manual
//        txt_vol_manual.translatesAutoresizingMaskIntoConstraints = false
//        view_config_notific.addSubview(txt_vol_manual)
//        
//        NSLayoutConstraint.activate([
//            // Alinhar a parte superior da label com a parte inferior da txt_notific_tela
//            txt_vol_manual.topAnchor.constraint(equalTo: txt_vol_dispositivo.bottomAnchor, constant: 30),
//            // Definir a largura máxima da label
//            txt_vol_manual.widthAnchor.constraint(lessThanOrEqualTo: view_config_notific.widthAnchor, multiplier: 0.8, constant: 0),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            txt_vol_manual.leadingAnchor.constraint(equalTo: view_config_notific.leadingAnchor, constant: 20),
//        ])
//        
//        //Slider de ajustar o volume
//        view_config_notific.addSubview(volNot_sld)
//        volNot_sld.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            // Centralizar a label horizontalmente
//            volNot_sld.centerXAnchor.constraint(equalTo: view_config_notific.centerXAnchor),
//            // Alinhar a parte superior da label com a parte inferior da txt_notific_tela
//            volNot_sld.topAnchor.constraint(equalTo: txt_vol_manual.bottomAnchor, constant: 20),
//            // Definir a largura máxima da label
//            volNot_sld.widthAnchor.constraint(lessThanOrEqualTo: view_config_notific.widthAnchor, constant: -20),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            volNot_sld.leadingAnchor.constraint(equalTo: view_config_notific.leadingAnchor, constant: 20),
//        ])
        

        
        
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

}
