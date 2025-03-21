//
//  SettingsViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import DCKit
import MSCircularSlider
import CoreImage.CIFilterBuiltins
import SafariServices
import SwiftUI
import DropDown

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var power_btn: UIButton!
    
    @IBOutlet weak var tubnameStatus_txt: UILabel!
    @IBOutlet weak var tubname_edt: UITextField!
    @IBOutlet weak var tubnameSave_btn: UIButton!
    
    @IBOutlet weak var profileStatus: UILabel!
    @IBOutlet weak var profile1_btn: DashedButton!
    @IBOutlet weak var profile1_edt: UITextField!
    @IBOutlet weak var pf1Action_btn: UIButton!
    @IBOutlet weak var profile2_btn: DashedButton!
    @IBOutlet weak var profile2_edt: UITextField!
    @IBOutlet weak var pf2Action_btn: UIButton!
    @IBOutlet weak var profile3_btn: DashedButton!
    @IBOutlet weak var profile3_edt: UITextField!
    @IBOutlet weak var pf3Action_btn: UIButton!
    @IBOutlet weak var profile4_btn: DashedButton!
    @IBOutlet weak var profile4_edt: UITextField!
    @IBOutlet weak var pf4Action_btn: UIButton!
    @IBOutlet weak var profile5_btn: DashedButton!
    @IBOutlet weak var profile5_edt: UITextField!
    @IBOutlet weak var pf5Action_btn: UIButton!
    
    @IBOutlet weak var brightStatus_txt: UILabel!
    @IBOutlet weak var bright_sld: MSCircularSlider!
    @IBOutlet weak var bright_txx: UILabel!
    
    @IBOutlet weak var sch_btn: UISegmentedControl!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var ftDuration_txt: UILabel!
    @IBOutlet weak var ftDuration_edt: UITextField!
    @IBOutlet weak var repeat_tgl: UISwitch!
    @IBOutlet weak var fillWarmTime_txt: UILabel!
    @IBOutlet weak var dom_btn: DCBorderedButton!
    @IBOutlet weak var seg_btn: DCBorderedButton!
    @IBOutlet weak var ter_btn: DCBorderedButton!
    @IBOutlet weak var qua_btn: DCBorderedButton!
    @IBOutlet weak var qui_btn: DCBorderedButton!
    @IBOutlet weak var sex_btn: DCBorderedButton!
    @IBOutlet weak var sab_btn: DCBorderedButton!
    @IBOutlet weak var saveFilter_btn: DCBorderedButton!
    @IBOutlet weak var clearFilter_btn: DCBorderedButton!
    
    @IBOutlet weak var atualizacao_btn: DCBorderedButton!
    
    
    @IBOutlet weak var brilho_opcao: UIView!
    
    @IBOutlet weak var filterStatus_txt: UILabel!
    @IBOutlet weak var wifiStatus_txt: UILabel!
    @IBOutlet weak var ssid_txt: UITextField!
    @IBOutlet weak var pswd_txt: UITextField!
    @IBOutlet weak var setWifi_btn: DCBorderedButton!
    
    @IBOutlet weak var drainStatus_txt: UILabel!
    @IBOutlet weak var drainMode_swt: UISwitch!
    @IBOutlet weak var drainTime_txt: UITextField!
    
    @IBOutlet weak var mqttStatus_txt: UILabel!
    
    @IBOutlet weak var qrcode_img: UIImageView!
    
    @IBOutlet weak var settings_stk: UIStackView!
    
    @IBOutlet weak var item0: UIView!
    @IBOutlet weak var inner0: DCBorderedView!
    
    @IBOutlet weak var itemFusoHorario: UIView!
    @IBOutlet weak var innerFusoHorario: DCBorderedView!
    
    @IBOutlet weak var itemBloqueio: UIView!
    @IBOutlet weak var innerBloqueio: DCBorderedView!
    
    @IBOutlet weak var itemAquecimento: UIView!
    @IBOutlet weak var innerAquecimento: DCBorderedView!
    
    @IBOutlet weak var itemDesligamentoAutomatico: UIView!
    @IBOutlet weak var innerDesligamentoAutomatico: DCBorderedView!
    
    @IBOutlet weak var itemTempoEnchimento: UIView!
    @IBOutlet weak var innerTempoEnchimento: DCBorderedView!
    
    @IBOutlet weak var itemPf: UIView!
    @IBOutlet weak var innerPf: DCBorderedView!
    
    @IBOutlet weak var item1: UIView!
    @IBOutlet weak var inner1: DCBorderedView!
    
    @IBOutlet weak var item2: UIView!
    @IBOutlet weak var inner2: DCBorderedView!
    
    @IBOutlet weak var item3: UIView!
    @IBOutlet weak var inner3: DCBorderedView!
    
    @IBOutlet weak var item4: UIView!
    @IBOutlet weak var inner4: DCBorderedView!
    
    @IBOutlet weak var itemDr: UIView!
    @IBOutlet weak var innerDr: DCBorderedView!
    
    @IBOutlet weak var item5: UIView!
    @IBOutlet weak var inner5: DCBorderedView!
    
    @IBOutlet weak var item6: UIView!
    @IBOutlet weak var inner6: DCBorderedView!
    
    @IBOutlet weak var item7: UIView!
    @IBOutlet weak var inner7: DCBorderedView!
    
    @IBOutlet weak var itemN: UIView!
    
    @IBOutlet weak var view_tool_bar: UIView!
    @IBOutlet weak var logo_img: UIImageView!
    
    @IBOutlet weak var switch_bloqueio: UISwitch!
    @IBOutlet weak var switch_aquecimento: UISwitch!
    @IBOutlet weak var switch_aquecimento_txt: UILabel!
    @IBOutlet weak var switch_bloqueio_txt: UILabel!
    
    @IBOutlet weak var desligamento_automatico_valor: UILabel!
    @IBOutlet weak var desligamento_automatico_status: UILabel!
    @IBOutlet weak var desligamento_automatico_slider: MSCircularSlider!
    
    @IBOutlet weak var tempo_enchimento_valor: UILabel!
    @IBOutlet weak var tempo_enchimento_status: UILabel!
    @IBOutlet weak var tempo_enchimento_slider: MSCircularSlider!

    @IBOutlet weak var limparRegistroBtn: DCBorderedButton!
    @IBOutlet weak var verificarErroBtn: DCBorderedButton!
    
    @IBOutlet weak var statusErroCodigo: UILabel!
    @IBOutlet weak var dataErroCodigo: UILabel!
    
    @IBOutlet weak var scrolView: UIView!
    
    @IBOutlet weak var openFusoHorario: UIButton!
    @IBOutlet weak var fusoHorario_status: UILabel!
    
    @IBOutlet weak var horariosDeAgenda: UILabel!

    
    private var brightsetTimer: Timer?
    
    private var wifi_toast = false
    private var wifiState_clone = 0
    
    let ci_context = CIContext()
    let ci_filter = CIFilter(name: "CIQRCodeGenerator")
    
    private var viewSelected: UIView?

    var menus: [DropDown] = []
    let timeZonesAMPM = (-12...12).map { offset -> String in
        let sign = offset >= 0 ? "+" : "-"
        let absOffset = abs(offset)
        return "UTC \(sign)\(String(format: "%02d", absOffset)):00"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cria um gradiente com as 3 cores desejadas
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor,
                                UIColor(red: 93/255, green: 143/255, blue: 255/255, alpha: 1).cgColor,
                                UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor]
        
        // Define o plano de fundo da view com o gradiente
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        self.setupDropDownMenu(for: self.openFusoHorario, withAction: TubCommands.SET_FUSO, atIndex: 0)
                
        //ToolBar View
        view_tool_bar.translatesAutoresizingMaskIntoConstraints = false
        view_tool_bar.backgroundColor = UIColor.clear // Adicione esta linha para tornar o fundo transparente
        view.addSubview(view_tool_bar)
        let guide = view.safeAreaLayoutGuide
        
        // Crie um dicionário com as configurações de texto desejadas
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.darkGray // Altere a cor do texto aqui
        ]

        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white // Altere a cor do texto selecionado aqui
        ]
        
        // Aplique as configurações ao seu UISegmentedControl
        sch_btn.setTitleTextAttributes(normalTextAttributes, for: .normal)
        sch_btn.setTitleTextAttributes(selectedTextAttributes, for: .selected)


        
        NSLayoutConstraint.activate([
            view_tool_bar.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            view_tool_bar.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            view_tool_bar.topAnchor.constraint(equalTo: guide.topAnchor),
            view_tool_bar.heightAnchor.constraint(equalToConstant: 44.0),
            view_tool_bar.widthAnchor.constraint(equalToConstant: 50.0)
        ])
        
        //Logo dentro da view toolbar
        logo_img.translatesAutoresizingMaskIntoConstraints = false
        view_tool_bar.addSubview(logo_img)
        
        NSLayoutConstraint.activate([
            logo_img.widthAnchor.constraint(equalToConstant: 50.0),
            logo_img.heightAnchor.constraint(equalToConstant: 50.0),
            logo_img.centerXAnchor.constraint(equalTo: view_tool_bar.centerXAnchor),
            logo_img.centerYAnchor.constraint(equalTo: view_tool_bar.centerYAnchor),
        ])
        
        
        //Bunton on/off dentro da view toolbar
        power_btn.translatesAutoresizingMaskIntoConstraints = false
        view_tool_bar.addSubview(power_btn)
        
        
        NSLayoutConstraint.activate([
            power_btn.centerYAnchor.constraint(equalTo: view_tool_bar.centerYAnchor),
            power_btn.trailingAnchor.constraint(equalTo: view_tool_bar.trailingAnchor, constant: -15),
        ])
        
        if(Settings.modo_painel == "BLOQUEADO"){
            switch_bloqueio.isOn = true
            switch_bloqueio_txt.text = "— Bloqueado"
        } else{
            switch_bloqueio.isOn = false
            switch_bloqueio_txt.text = "— Desbloqueado"

        }
        
        if(Settings.aquecedor_automatico == 1){
            switch_aquecimento.isOn = true
            switch_aquecimento_txt.text = "— Ligado"

        } else{
            switch_aquecimento.isOn = false
            switch_aquecimento_txt.text = "— Desligado"

        }
        
        view.addSubview(view_tool_bar)
        view.addSubview(scrolView)
        
        view_tool_bar.translatesAutoresizingMaskIntoConstraints = false
        scrolView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Constraints para view_tool_bar
            view_tool_bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            view_tool_bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view_tool_bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Constraints para scrollView
            scrolView.topAnchor.constraint(equalTo: view_tool_bar.bottomAnchor),
            scrolView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrolView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrolView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Assumes BLE service responses
        BLEService.it.delegates(ble: nil, conn: self, comm: self).ok()
        
        // Assume responses in Wifi
        WiFiService.it.delegates(conn: self, comm: self).ok()
        
        // Assume responses in MQTT
        MqttService.it.delegates(conn: self, comm: self).ok()
        
        // Setup delegates
        tubname_edt.delegate = self
        tubname_edt.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        profile1_edt.delegate = self
        profile2_edt.delegate = self
        profile3_edt.delegate = self
//        profile4_edt.delegate = self
//        profile5_edt.delegate = self
        ssid_txt.delegate = self
        pswd_txt.delegate = self
        
        // Setup tags as heights
        inner0.tag = Int(inner0.frame.height)
        innerFusoHorario.tag = Int(innerFusoHorario.frame.height)
        innerBloqueio.tag = Int(innerBloqueio.frame.height)
        innerAquecimento.tag = Int(innerAquecimento.frame.height)
        innerDesligamentoAutomatico.tag = Int(innerDesligamentoAutomatico.frame.height)
        innerTempoEnchimento.tag = Int(innerTempoEnchimento.frame.height)
        innerPf.tag = Int(innerPf.frame.height)
        inner1.tag = Int(inner1.frame.height)
        inner2.tag = Int(inner2.frame.height)
        inner3.tag = Int(inner3.frame.height)
        inner4.tag = Int(inner4.frame.height)
        innerDr.tag = Int(innerDr.frame.height)
        inner5.tag = Int(inner5.frame.height)
        inner6.tag = Int(inner6.frame.height)
        inner7.tag = Int(inner7.frame.height)
        
        // Setup gesture recognizer for UIViews
        item0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClick0)))
        
        itemFusoHorario.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClickFusoHorario)))
        
        itemPf.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClickPf)))
        
        item1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClick1)))
        
        itemBloqueio.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClickBloqueio)))
        
        itemAquecimento.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClickAquecimento)))
        
        itemTempoEnchimento.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClickTempoEnchimento)))
        
        itemDesligamentoAutomatico.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClickDesligamentoAutomatico)))
        
        item2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClick2)))
        
        item3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClick3)))
        
        item4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClick4)))
        
        itemDr.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClickDr)))
        
        item5.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClick5)))
        
        item6.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClick6)))
        
        item7.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClick7)))
        
        itemN .addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClickN)))
        
        // Tubname
        tubnameStatus_txt.text = "— \(Settings.tubname)"
        tubname_edt.text = Settings.tubname
        
        // Fuso
        updateFusoHorarioStatus(fuso: Settings.fuso)

        
        // Profiles
        profileStatus.text = "— \(Settings.memos)/3 salvos"
        manageProfiles(slot: profile1_btn, slotname: profile1_edt, slotAct: pf1Action_btn, pos: 1, del: Settings.memo1 == 0, ini: true)
        manageProfiles(slot: profile2_btn, slotname: profile2_edt, slotAct: pf2Action_btn, pos: 2, del: Settings.memo2 == 0, ini: true)
        manageProfiles(slot: profile3_btn, slotname: profile3_edt, slotAct: pf3Action_btn, pos: 3, del: Settings.memo3 == 0, ini: true)
        
        profile1_edt.text = Settings.memo1_name.isEmpty ? "Memoria 1" : Settings.memo1_name
        profile2_edt.text = Settings.memo2_name.isEmpty ? "Memoria 2" : Settings.memo2_name
        profile3_edt.text = Settings.memo3_name.isEmpty ? "Memoria 3" : Settings.memo3_name
        
        // Bright
        bright_txx.text = "\(Settings.backlight)%"
        brightStatus_txt.text = "— \(Settings.backlight)%"
        bright_sld.currentValue = Double(Settings.backlight)
        bright_sld.delegate = self
        
        // Desligamento Automático
        if Settings.timeoutligado == 0 {
            desligamento_automatico_status.text = "— Desativado"
            desligamento_automatico_valor.text = "off"
        } else {
            let valorTimeOut = Float(Settings.timeoutligado) / 60.0
            let hours = Int(valorTimeOut)
            let minutes = Int((valorTimeOut - Float(hours)) * 60)
            let formattedTime = String(format: "%d:%02d", hours, minutes)
            
            desligamento_automatico_slider.currentValue = Double(valorTimeOut)
            desligamento_automatico_valor.text = "\(formattedTime)h"
            desligamento_automatico_status.text = "— \(formattedTime)h"
        }
        desligamento_automatico_slider.currentValue = Double(Settings.timeoutligado)
        desligamento_automatico_slider.delegate = self
        
        //tempo de enchimento
        if Settings.timeoutligado == 0 {
            tempo_enchimento_status.text = "— Desativado"
            tempo_enchimento_valor.text = "off"
        }else{
            let enchimento = Float(Settings.timeEnchimento) / 60.0
            tempo_enchimento_slider._currentValue = Double(enchimento)
            tempo_enchimento_valor.text = "\(enchimento)hr"
            tempo_enchimento_status.text = "— \(enchimento)hr"
        }
        tempo_enchimento_slider.currentValue = Double(Settings.timeEnchimento)
        tempo_enchimento_slider.delegate = self
        
        // Filtering
        filterStatus_txt.text = Settings.bh_days == 0 && Settings.ft_days == 0 ? "— Não agendado" : "— Agendado"
        if(Settings.bh_days == 0) {
            repeat_tgl.setOn(false, animated: true)
            ft_repeatChange(0)
            ftDuration_edt.text = "34"
        } else {
            scheduleCtrl("")
        }
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(clearFillWarmTimes))
        fillWarmTime_txt.addGestureRecognizer(lpgr)
        
        dom_btn.addTarget(self, action: #selector(dayPressed), for: .touchUpInside)
        seg_btn.addTarget(self, action: #selector(dayPressed), for: .touchUpInside)
        ter_btn.addTarget(self, action: #selector(dayPressed), for: .touchUpInside)
        qua_btn.addTarget(self, action: #selector(dayPressed), for: .touchUpInside)
        qui_btn.addTarget(self, action: #selector(dayPressed), for: .touchUpInside)
        sex_btn.addTarget(self, action: #selector(dayPressed), for: .touchUpInside)
        sab_btn.addTarget(self, action: #selector(dayPressed), for: .touchUpInside)
        if(Settings.has_cromo == 2 || Settings.qt_bombs == 0) {
            item2.alpha = 0.6
            item2.isUserInteractionEnabled = false
            filterStatus_txt.text = "— Indisponível"
        }
        
        // Wi-Fi
        ssid_txt.text = Utils.getWiFiNetworkName()
        wifiStatus_txt.text = Settings.wifi_state == 2 ? "— \(Settings.ssid)" : "— Não configurado"
        wifiState_clone = Settings.wifi_state
        if(WiFiService.it.state == Connection.State.CONNECTED ||
            MqttService.it.state == Connection.State.CONNECTED) {
            setWifi_btn.isEnabled = false
        }
        
        //Drain
//        drainStatus_txt.text = Settings.drain_mode == 1 ? "— Toque longo" : "— Toque curto"
//        drainMode_swt.isOn = Settings.drain_mode == 1
//        drainTime_txt.text = "\(Settings.drain_time/60                                                    )"
//        if(Settings.has_drain == 0) {
//            itemDr.alpha = 0.6
//            itemDr.isUserInteractionEnabled = false
//            drainStatus_txt.text = "— Indisponível"
//        }
        
        // QRCode
        generateQRCode()
        
        applyGradient(to: setWifi_btn)
        applyGradient(to: tubnameSave_btn)
        applyGradient(to: saveFilter_btn)
        applyGradient(to: clearFilter_btn)
        applyGradient(to: atualizacao_btn)
        
        configurarProduto()
    }
    
    private func configurarFiltroOuBanho() {
        let isBanho = sch_btn.selectedSegmentIndex == 0
        let settings = isBanho ? (Settings.bh_hour, Settings.bh_min, Settings.bh_days, Settings.bh_temp) : (Settings.ft_hour, Settings.ft_min, Settings.ft_days, Settings.ft_time)
        
        setFilteringDate(hour: settings.0, minute: settings.1, now: settings.2 == 0)
        ftDuration_txt.text = isBanho ? "Temperatura: (°C)" : "Duração: (minutos)"
        ftDuration_edt.placeholder = isBanho ? "40" : "240"
        ftDuration_edt.text = settings.2 == 0 ? (isBanho ? "34" : "120") : "\(settings.3)"
        setActiveDays(days: settings.2)
        
        if isBanho {
            let fl = (0...65499).contains(Settings.fl_time) ? "\(Settings.fl_time)" : "--"
            let wm = (1...254).contains(Settings.wm_time) ? "\(Settings.wm_time)" : "--"
            fillWarmTime_txt.text = "Tempo para encher/aquecer (minutos): \(fl) / \(wm)"
        } else {
            fillWarmTime_txt.text = ""
        }
    }
    
    private func configurarStatusFiltragem(){
        
        let diasSemana = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
        var textoAgenda = ""
        
        if Settings.ft_days > 0 && Settings.ft_days < 128 {
            textoAgenda = "Filtragem agendados nos dias:\n"
            let diasAgendados = diasSemana.enumerated().filter { index, _ in
                ((Settings.ft_days >> index) & 1) == 1
            }.map { $0.element }
            textoAgenda += diasAgendados.joined(separator: ", ")
            horariosDeAgenda.textColor = .green
        } else if Settings.ft_days == 128 {
            textoAgenda = "— Filtragem Agendada —"
            horariosDeAgenda.textColor = .green
        } else {
            textoAgenda = "— Não há filtragem agendada no momento —"
            horariosDeAgenda.textColor = .red
        }
        
        horariosDeAgenda.text = textoAgenda
        
        setActiveDays(days: Settings.ft_days)
        if(Settings.ft_days <= 0){
            ftDuration_edt.text = ""
            filterStatus_txt.text = "— Não agendado"
        } else {
            filterStatus_txt.text = "— Agendado"
        }
    }
    
    private func configurarStatusBanho(){
        
        let diasSemana = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
        var textoAgenda = ""
        
        if Settings.ft_days > 0 && Settings.ft_days < 128 {
            textoAgenda = "Banhos agendados nos dias:\n"
            let diasAgendados = diasSemana.enumerated().filter { index, _ in
                ((Settings.ft_days >> index) & 1) == 1
            }.map { $0.element }
            textoAgenda += diasAgendados.joined(separator: ", ")
            horariosDeAgenda.textColor = .green
        } else if Settings.ft_days == 128 {
            textoAgenda = "— Banho Agendado —"
            horariosDeAgenda.textColor = .green
        } else {
            textoAgenda = "— Não há banho agendado no momento —"
            horariosDeAgenda.textColor = .red
        }
        
        horariosDeAgenda.text = textoAgenda
        
        setActiveDays(days: Settings.bh_days)
        if(Settings.bh_days <= 0){
            ftDuration_edt.text = ""
            filterStatus_txt.text = "— Não agendado"
        } else {
            filterStatus_txt.text = "— Agendado"
        }
    }
    
    private func configurarProduto() {
        switch Settings.produto {
        case "BluePLUS", "BlueFLEX", "BlueCROMO":
            brilho_opcao.isHidden = true
            sch_btn.setEnabled(false, forSegmentAt: 0)
            sch_btn.selectedSegmentIndex = 1
        case "BlueSLIM":
            brilho_opcao.isHidden = true
        case "ProTECLAS":
            brilho_opcao.isHidden = false
        default:
            break
        }
        configurarFiltroOuBanho()
        configurarStatusFiltragem()
    }
    
    private func applyGradient(to button: UIButton) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: button.bounds.width + 1000, height: button.bounds.height)
        gradientLayer.colors = [
            UIColor(red: 0, green: 0.2, blue: 0.4, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 0.4, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        button.layer.addSublayer(gradientLayer)
    }
    
    func atualizarErro() {
        if (Settings.codigo_erro == 0){
            statusErroCodigo.text = "Sem erros"
        } else {
            statusErroCodigo.text = "Codigo \(Settings.codigo_erro)"
        }
        
        if(Settings.data_erro == 0){
            dataErroCodigo.text = "--/--/--"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"  // Define o formato desejado (dia/mês/ano)

            let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(Settings.data_erro)))
            dataErroCodigo.text = formattedDate
        }
        
        let date = Date()
        _ = Int(date.timeIntervalSince1970)
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
        } else {
            if let pvc = self.navigationController?.viewControllers[1] {
                self.navigationController?.popToViewController(pvc, animated: true)
            }
        }
        
        // Colapse all views
        setupSelected(inner: inner0, show: false)
        setupSelected(inner: innerFusoHorario, show: false)
        setupSelected(inner: innerPf, show: false)
        setupSelected(inner: inner1, show: false)
        
        setupSelected(inner: innerBloqueio, show: false)
        setupSelected(inner: innerAquecimento, show: false)
        setupSelected(inner: innerDesligamentoAutomatico, show: false)
        setupSelected(inner: innerTempoEnchimento, show: false)
        
        if(Settings.qt_bombs > 0 || Settings.has_cromo != 2) {
            setupSelected(inner: inner2, show: false)   // Case filtering supported
        } else {
            let arr_view = settings_stk.arrangedSubviews[2]
            settings_stk.removeArrangedSubview(arr_view)
            arr_view.removeFromSuperview()
        }
        setupSelected(inner: inner3, show: false)
        setupSelected(inner: inner4, show: false)
        setupSelected(inner: innerDr, show: false)
        setupSelected(inner: inner5, show: false)
        setupSelected(inner: inner6, show: false)
        setupSelected(inner: inner7, show: false)
        
        // Update power indicator
        updatePower()
    }
    
    @objc private func itemClick0(sender: UITapGestureRecognizer) {
        setupSelected(inner: inner0, show: true)
        tubname_edt.text = Settings.tubname
    }
    
    @objc private func itemClickFusoHorario(sender: UITapGestureRecognizer) {
        setupSelected(inner: innerFusoHorario, show: true)
    }
    
    @objc private func itemClickPf(sender: UITapGestureRecognizer) {
        setupSelected(inner: innerPf, show: true)
    }
    
    @objc private func itemClick1(sender: UITapGestureRecognizer) {
        setupSelected(inner: inner1, show: true)
    }
    
    @objc private func itemClick2(sender: UITapGestureRecognizer) {
        setupSelected(inner: inner2, show: true)
    }
    
    @objc private func itemClickBloqueio(sender: UITapGestureRecognizer) {
        setupSelected(inner: innerBloqueio, show: true)
    }
    
    @objc private func itemClickAquecimento(sender: UITapGestureRecognizer) {
        setupSelected(inner: innerAquecimento, show: true)
    }
    
    @objc private func itemClickDesligamentoAutomatico(sender: UITapGestureRecognizer) {
        setupSelected(inner: innerDesligamentoAutomatico, show: true)
    }
    
    @objc private func itemClickTempoEnchimento(sender: UITapGestureRecognizer) {
        setupSelected(inner: innerTempoEnchimento, show: true)
    }
    
    @objc private func itemClick3(sender: UITapGestureRecognizer) {
        if(viewSelected != inner3) {
            if(BLEService.it.state != Connection.State.CONNECTED) {
                Utils.toast(vc: self, message: "Só é possível configurar o Wi-Fi quando conectado via Bluetooth")
            }
        }
        setupSelected(inner: inner3, show: true)
    }
    
    @objc private func itemClick4(sender: UITapGestureRecognizer) {
        setupSelected(inner: inner4, show: true)
    }
    
    @objc private func itemClickDr(sender: UITapGestureRecognizer) {
        setupSelected(inner: innerDr, show: true)
    }
    
    @objc private func itemClick5(sender: UITapGestureRecognizer) {
        setupSelected(inner: inner5, show: true)
    }
    
    @objc private func itemClick6(sender: UITapGestureRecognizer) {
        if(viewSelected != inner6) {
            let ssid = Utils.getWiFiNetworkName() ?? ""
            if(ssid != Settings.ssid) {
                Utils.toast(vc: self, message: "Para realizar a atualização você deve estar conectado na mesma rede que sua banheira")
            }
        }
        setupSelected(inner: inner6, show: true)
    }
    
    @objc private func itemClick7(sender: UITapGestureRecognizer) {
        setupSelected(inner: inner7, show: true)
    }
    
    @objc private func itemClickN(sender: UITapGestureRecognizer) {
        Utils.disconnect()
    }
    
    @IBAction func clear_error(_ sender: Any) {
        Utils.sendCommand(cmd: TubCommands.APAGA_ERRO, value: nil, word: nil)
        statusErroCodigo.text = "Sem erros"
        dataErroCodigo.text = "--/--/--"
    }
    
    @IBAction func verificar_Error(_ sender: Any) {
        Utils.sendCommand(cmd: TubCommands.STATUS_ERRO, value: nil, word: nil)
        
        atualizarErro()
    }
    
    private func setupSelected(inner: UIView, show: Bool) {
        var hide = !show
        // If the same item is selected, we hide it
        if(inner == viewSelected) {
            hide = true
            viewSelected = nil
        } else {
            if let selected = viewSelected {
                setupSelected(inner: selected, show: false)
            }
        }
        
//        print("setup \(inner)")
//        print("setup \(inner.constraints.filter{$0.firstAttribute == .height}.first)")
        
        // Force keyboard hiding
        inner.endEditing(true)
        
        // Code responsible to show/hide a view
        if let constraint = (inner.constraints.filter{$0.firstAttribute == .height}.first) {
            
            inner.isHidden = hide
            constraint.constant = CGFloat(hide ? 0 : inner.tag) // Inner tag defined as the preferred height
            inner.layoutIfNeeded()
            
            if(!hide) { viewSelected = inner }
        }
    }
    
    func setupDropDownMenu(for button: UIButton, withAction action: String, atIndex index: Int) {
        DispatchQueue.main.async {
            
            let menu = DropDown()
            menu.dataSource = self.timeZonesAMPM
            
            menu.anchorView = button
            menu.bottomOffset = CGPoint(x: 0, y: button.bounds.height)
            
            // Definir o valor inicial com base no Settings.fuso
            let fusoAtual = Settings.fuso
            let fusoFormatado = String(format: "%+03d:00", fusoAtual)
            let valorInicial = "UTC \(fusoFormatado)"
            button.setTitle(valorInicial, for: .normal)
            
            if let indexInicial = self.timeZonesAMPM.firstIndex(of: valorInicial) {
                menu.selectRow(at: indexInicial)
            }
            
            // Ação quando um item é selecionado no menu suspenso
            menu.selectionAction = { [weak self] index, item in
                guard let self = self else { return }
                button.setTitle(item, for: .normal)
                
                // Extrair o valor do item selecionado
                let value = item.replacingOccurrences(of: "UTC ", with: "").replacingOccurrences(of: ":00", with: "")
                
                // Enviar um comando com base na ação e no valor extraído
                Utils.sendCommand(cmd: action, value: nil, word: value)
                
                // Atualizar o status imediatamente após o envio do comando
                if let fusoValue = Int(value) {
                    self.updateFusoHorarioStatus(fuso: fusoValue)
                }
            }
            
            self.menus.append(menu)
            button.tag = index
            
            // Adicionar ação de toque ao botão
            button.addTarget(self, action: #selector(self.openMenuButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    // Método para atualizar o status do fuso horário
    func updateFusoHorarioStatus(fuso: Int) {
        DispatchQueue.main.async {
            let fusoFormatado = String(format: "%+03d", fuso)
            self.fusoHorario_status.text = "— UTC \(fusoFormatado):00"
        }
    }
    
    // Ação quando um botão de menu é tocado
    @IBAction func openMenuButtonTapped(_ sender: UIButton) {
        if sender.tag < menus.count {
            menus[sender.tag].show()
        }
    }
    
    
    @IBAction func profile1Click(_ sender: Any) {
        manageProfiles(slot: profile1_btn, slotname: profile1_edt, slotAct: pf1Action_btn, pos: 1, del: false)
    }
    
    @IBAction func pf1EndClick(_ sender: Any) {
        profile1_edt.isEnabled = false
        if((profile1_edt.text ?? "").isEmpty) {
            profile1_edt.text = "Memoria 1"
        }
        Utils.sendCommand(cmd: TubCommands.NAME_MEMO, value: nil, word: "1 \(profile1_edt.text!)")
    }
    
    @IBAction func pf1ActionClick(_ sender: Any) {
        manageProfiles(slot: profile1_btn, slotname: profile1_edt, slotAct: pf1Action_btn, pos: 1, del: true)
    }
    
    @IBAction func profile2Click(_ sender: Any) {
        manageProfiles(slot: profile2_btn, slotname: profile2_edt, slotAct: pf2Action_btn, pos: 2, del: false)
    }
    
    @IBAction func pf2EndClick(_ sender: Any) {
        profile2_edt.isEnabled = false
        if((profile2_edt.text ?? "").isEmpty) {
            profile2_edt.text = "Memoria 2"
        }
        Utils.sendCommand(cmd: TubCommands.NAME_MEMO, value: nil, word: "2 \(profile2_edt.text!)")
    }
    
    @IBAction func pf2ActionClick(_ sender: Any) {
        manageProfiles(slot: profile2_btn, slotname: profile2_edt, slotAct: pf2Action_btn, pos: 2, del: true)
    }
    
    @IBAction func profile3Click(_ sender: Any) {
        manageProfiles(slot: profile3_btn, slotname: profile3_edt, slotAct: pf3Action_btn, pos: 3, del: false)
    }
    
    @IBAction func pf3EndClick(_ sender: Any) {
        profile3_edt.isEnabled = false
        if((profile3_edt.text ?? "").isEmpty) {
            profile3_edt.text = "Memoria 3"
        }
        Utils.sendCommand(cmd: TubCommands.NAME_MEMO, value: nil, word: "3 \(profile3_edt.text!)")
    }
    
    @IBAction func pf3ActionClick(_ sender: Any) {
        manageProfiles(slot: profile3_btn, slotname: profile3_edt, slotAct: pf3Action_btn, pos: 3, del: true)
    }
    
    @IBAction func profile4Click(_ sender: Any) {
        manageProfiles(slot: profile4_btn, slotname: profile4_edt, slotAct: pf4Action_btn, pos: 4, del: false)
    }
    
    @IBAction func pf4EndClick(_ sender: Any) {
        profile4_edt.isEnabled = false
        if((profile4_edt.text ?? "").isEmpty) {
            profile4_edt.text = "Perfil 4"
        }
        Utils.sendCommand(cmd: TubCommands.NAME_MEMO, value: nil, word: "4 \(profile4_edt.text!)")
    }
    
    @IBAction func pf4ActionClick(_ sender: Any) {
        manageProfiles(slot: profile4_btn, slotname: profile4_edt, slotAct: pf4Action_btn, pos: 4, del: true)
    }
    
    @IBAction func profile5Click(_ sender: Any) {
        manageProfiles(slot: profile5_btn, slotname: profile5_edt, slotAct: pf5Action_btn, pos: 5, del: false)
    }
    
    @IBAction func pf5EndClick(_ sender: Any) {
        profile5_edt.isEnabled = false
        if((profile5_edt.text ?? "").isEmpty) {
            profile5_edt.text = "Perfil 5"
        }
        Utils.sendCommand(cmd: TubCommands.NAME_MEMO, value: nil, word: "5 \(profile5_edt.text!)")
    }
    
    @IBAction func pf5ActionClick(_ sender: Any) {
        manageProfiles(slot: profile5_btn, slotname: profile5_edt, slotAct: pf5Action_btn, pos: 5, del: true)
    }
    
    func manageProfiles(slot: DashedButton, slotname: UITextField, slotAct: UIButton,
                        pos: Int, del: Bool = false, ini: Bool = false) {
        print("Memoria \(pos)")
        let delete = del && !slot.initialized
        if(!slot.initialized) {
            if(!del && !ini) {
                Utils.sendCommand(cmd: TubCommands.LOAD_MEMO, value: pos, word: nil)
                Utils.toast(vc: self, message: "Memoria carregado com sucesso", type: 1)
                //print("Memoria carregado com sucesso")
                return
            }
        }
        
        slot.dash(delete)
        let act_img = delete ? UIImage(named: "sdcard")
                             : UIImage(named: "ic_delete")
        slotAct.setImage(act_img, for: .normal)
        let color = delete ? UIColor.green
                           : UIColor.red
        slotAct.tintColor = color
        
        if(ini) { return }
        
        slotname.text = "Memoria \(pos)"
        slotname.isEnabled = !delete
        slotname.becomeFirstResponder()
        
        delete ? Utils.sendCommand(cmd: TubCommands.CLR_MEMO, value: pos, word: nil)
               : Utils.sendCommand(cmd: TubCommands.SAVE_MEMO, value: pos, word: nil)
    }
    
    @IBAction func scheduleCtrl(_ sender: Any) {
        if(sch_btn.selectedSegmentIndex == 0) {
            setFilteringDate(hour: Settings.bh_hour, minute: Settings.bh_min, now: Settings.bh_days == 0)
            ftDuration_txt.text = "Temperatura: (°C)"
            ftDuration_edt.placeholder = "40"
            ftDuration_edt.text = Settings.bh_days == 0 ? "34" : "\(Settings.bh_temp)"
            setActiveDays(days: Settings.bh_days)
            let fl = (Settings.fl_time > 0 && Settings.fl_time < 65500) ? "\(Settings.fl_time)" : "--"
            let wm = (Settings.wm_time > 0 && Settings.wm_time < 255) ? "\(Settings.wm_time)" : "--"
            fillWarmTime_txt.text = "Tempo para encher/aquecer (minutos): \(fl) / \(wm)"
        } else {
            setFilteringDate(hour: Settings.ft_hour, minute: Settings.ft_min, now: Settings.ft_days == 0)
            ftDuration_txt.text = "Duração: (minutos)"
            ftDuration_edt.text = Settings.ft_days == 0 ? "120": "\(Settings.ft_time)"
            ftDuration_edt.placeholder = "240"
            setActiveDays(days: Settings.ft_days)
            fillWarmTime_txt.text = ""
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
                Utils.askOffAction(vc: self)
            } else {
                Utils.askOffAction(vc: self)
            }
            Settings.power = 0
        }
        updatePower()
    }
    
    @objc func clearFillWarmTimes(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == UIGestureRecognizer.State.ended {
            Utils.toast(vc: self, message: "Tempos limpos com sucesso", type: 1)
            Utils.sendCommand(cmd: TubCommands.CLR_FTIME, value: nil, word: nil)
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
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.tag == 960) {
            if let text = textField.text {
                let dt = Int(text) ?? 0
                if (1...960).contains(dt) {
                    Utils.sendCommand(cmd: TubCommands.SET_DRAIN_TIME, value: dt, word: nil)
                } else {
                    Utils.toast(vc: self, message: "Tempo inválido, o valor dever ser um inteiro entre 0~960", type: 2)
                }
            }
        }
        
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= textField.tag
    }
    
}

extension SettingsViewController: MSCircularSliderDelegate {
    
    @IBAction func powerClick(_ sender: Any) {
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
                if(Settings.ralo_on_off.isEmpty) {
                    Utils.sendCommand(cmd: TubCommands.POWER, value: p, word: nil)
                    Settings.power = 0
                } else {
                    Utils.askOffAction(vc: self)
                }
                Settings.power = 0
            }
            updatePower()
        }
    
    // Tubname
    @IBAction func saveTubnameClick(_ sender: Any) {
        let tubname = tubname_edt.text!
        if(tubname.isEmpty) { return }
        
        if let db = RealmDB.it, let tub = Tub.initFromSettings() {
            tub.tub_name = tubname
            RequestManager.it.updateTubRequest(tub: tub, delegate: self)
            
            do {
                try db.write {
                    db.add(tub, update: .modified)
                    Settings.tubname = tubname
                    tubnameStatus_txt.text = "— \(Settings.tubname)"
                    Utils.toast(vc: self, message: "Novo nome salvo com sucesso", type: 1)
                }
            } catch {
                Utils.toast(vc: self, message: "Não foi possível salvar o novo nome", type: 2)
                tubname_edt.text = Settings.tubname
            }
        }
    }
    
    // Bright. enchimento, desligamento
    func circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool) {
        
        // Arredondar o valor para o múltiplo mais próximo de 0.5
        let roundedValue = round(value * 2) / 2.0
        // Converter o valor arredondado para minutos (1 hora = 60 minutos)
        let valueHora = roundedValue * 60

        // Verificar se o slider é o controle de brilho
        if slider == bright_sld {
            // Atualizar os textos de exibição com o valor de brilho em porcentagem
            bright_txx.text = "\(Int(value))%"
            brightStatus_txt.text = "— \(Int(value))%"
            
            // Verificar se a mudança foi feita pelo usuário
            if(fromUser) {
                // Invalidar o temporizador existente, se houver
                self.brightsetTimer?.invalidate()
                // Configurar um novo temporizador para enviar o comando de ajuste de brilho após 0.3 segundos
                self.brightsetTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false){ t in
                    Utils.sendCommand(cmd: TubCommands.SET_BACKLIGHT, value: value < 1 ? 1 : Int(value), word: nil)
                }
            }
        }
        // Verificar se o slider é o controle de desligamento automático
        else if slider == desligamento_automatico_slider {
            if value == 0 {
                // Atualizar os textos de exibição para mostrar que o desligamento automático está desativado
                desligamento_automatico_valor.text = "off"
                desligamento_automatico_status.text = "— Desativado"
            } else {
                // Converter roundedValue para horas e minutos
                let hours = Int(roundedValue)
                let minutes = Int((Double(roundedValue) - Double(hours)) * 60)
                let formattedTime = String(format: "%d:%02d", hours, minutes)
                
                // Atualizar os textos de exibição com o valor de desligamento automático em horas e minutos
                desligamento_automatico_valor.text = "\(formattedTime)hr"
                desligamento_automatico_status.text = "— \(formattedTime)hr"
            }
            
            // Verificar se a mudança foi feita pelo usuário
            if(fromUser) {
                // Invalidar o temporizador existente, se houver
                self.brightsetTimer?.invalidate()
                // Configurar um novo temporizador para enviar o comando de ajuste de tempo de desligamento automático após 0.3 segundos
                self.brightsetTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false){ t in
                    Utils.sendCommand(cmd: TubCommands.TIMEOUT_BANHEIRA, value: Int(valueHora), word: nil)
                }
            }
        }
        // Verificar se o slider é o controle de tempo de enchimento
        else if slider == tempo_enchimento_slider {
            if value == 0 {
                // Atualizar os textos de exibição para mostrar que o enchimento está desativado
                tempo_enchimento_valor.text = "off"
                tempo_enchimento_status.text = "— Desativado"
            } else {
                // Atualizar os textos de exibição com o valor de tempo de enchimento em horas
                tempo_enchimento_valor.text = "\(roundedValue)hr"
                tempo_enchimento_status.text = "— \(roundedValue)hr"
            }
            
            // Verificar se a mudança foi feita pelo usuário
            if(fromUser) {
                // Invalidar o temporizador existente, se houver
                self.brightsetTimer?.invalidate()
                // Configurar um novo temporizador para enviar o comando de ajuste de nível de água após 0.3 segundos
                self.brightsetTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false){ t in
                    Utils.sendCommand(cmd: TubCommands.CURRENT_WATER_LEVEL, value: Int(valueHora), word: nil)
                }
            }
        }
    }
    
    // Filtering
    @IBAction func saveFiltering(_ sender: Any) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
        let days = getActiveDays()
        let hour = components.hour!
        let minute = components.minute!
        let duration = validateFilteringDuration(dur: ftDuration_edt.text)
        
        if(duration.isEmpty) {
            let range = sch_btn.selectedSegmentIndex == 0 ? "15~40" : "1~240"
            Utils.toast(vc: self, message: "Duração inválida, valor deve ser um inteiro entre \(range)", type: 2)
            return
        }
        
        Utils.toast(vc: self, message: "Agendamento salvo com sucesso", type: 1)
        let command = sch_btn.selectedSegmentIndex == 0 ? TubCommands.SET_BATH : TubCommands.SET_FILTER
        Utils.sendCommand(cmd: command, value: nil, word: "\(days) \(hour) \(minute) \(duration)")
    }
    
    @IBAction func clearFiltering(_ sender: Any) {
        Utils.toast(vc: self, message: "Agenda limpa com sucesso", type: 1)
        let command = sch_btn.selectedSegmentIndex == 0 ? TubCommands.CLR_BATH : TubCommands.CLR_FILTER
        Utils.sendCommand(cmd: command, value: nil, word: nil)
    }
    
    @IBAction func ft_repeatChange(_ sender: Any) {
        dom_btn.isEnabled = repeat_tgl.isOn
        seg_btn.isEnabled = repeat_tgl.isOn
        ter_btn.isEnabled = repeat_tgl.isOn
        qua_btn.isEnabled = repeat_tgl.isOn
        qui_btn.isEnabled = repeat_tgl.isOn
        sex_btn.isEnabled = repeat_tgl.isOn
        sab_btn.isEnabled = repeat_tgl.isOn
    }
    
    func validateFilteringDuration(dur: String?) -> String {
        let range = sch_btn.selectedSegmentIndex == 0 ? 15...40 : 1...240
        
        if let dur_s = dur {
            if let dur_i = Int(dur_s) {
                if(range.contains(dur_i)) {
                    return dur_s
                }
            }
            return ""
        }
        return ""
    }
    
    func getActiveDays() -> Int {
        var days = 0
        if(repeat_tgl.isOn) {
            if(dom_btn.isSelected){ days += 1 }
            if(seg_btn.isSelected){ days += 2 }
            if(ter_btn.isSelected){ days += 4 }
            if(qua_btn.isSelected){ days += 8 }
            if(qui_btn.isSelected){ days += 16 }
            if(sex_btn.isSelected){ days += 32 }
            if(sab_btn.isSelected){ days += 64 }
        } else {
            days = 128
        }
        return days
    }
    
    func setActiveDays(days: Int){
        if(Settings.qt_bombs <= 0 || Settings.has_cromo == 2) { return }
        
        dom_btn.isSelected = ((days >> 0) & 0x01) == 1
        seg_btn.isSelected = ((days >> 1) & 0x01) == 1
        ter_btn.isSelected = ((days >> 2) & 0x01) == 1
        qua_btn.isSelected = ((days >> 3) & 0x01) == 1
        qui_btn.isSelected = ((days >> 4) & 0x01) == 1
        sex_btn.isSelected = ((days >> 5) & 0x01) == 1
        sab_btn.isSelected = ((days >> 6) & 0x01) == 1
        repeat_tgl.setOn(((days >> 7) & 0x01) == 0 && days > 0, animated: true)
        ft_repeatChange(0)
    }
    
    func setFilteringDate(hour: Int, minute: Int, now: Bool){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let date = dateFormatter.date(from: "\(hour):\(minute)") {
            timePicker.date = now ? Date() : date
        }
    }
    
    @objc private func dayPressed(button: UIButton) {
        button.isSelected = !button.isSelected
    }
    
    // Wi-Fi
    @IBAction func setWiFiClick(_ sender: Any) {
        _ = textFieldShouldReturn(ssid_txt)
        
        let ssid = ssid_txt.text ?? ""
        let pswd = pswd_txt.text ?? ""
        
        if(ssid.isEmpty || pswd.count < 8) {
            Utils.toast(vc: self, message: "Por favor verifique os campos e tente novamente")
        }
        
        Utils.sendCommand(cmd: TubCommands.WIFI, value: nil, word: "\(ssid) \(pswd)")
        wifi_toast = true
    }
    
    // Drain
    @IBAction func drainModeChange(_ sender: Any) {
        if(drainMode_swt.isOn) {
            Utils.sendCommand(cmd: TubCommands.SET_DRAIN_MODE, value: 1, word: nil)
        } else {
            Utils.sendCommand(cmd: TubCommands.SET_DRAIN_MODE, value: 0, word: nil)
        }
    }
    
    // QRCode
    private func generateQRCode(){
        if let _ = Utils.getMqttId() {
    
            let data_id = Tub.initFromSettings()!.description.data(using: .utf8)

            if let filter = ci_filter {
                filter.setValue(data_id, forKey: "inputMessage")
                
                if let output = filter.outputImage {
                    qrcode_img.image = UIImage(ciImage: output)
                    qrcode_img.layer.magnificationFilter = CALayerContentsFilter.nearest
                }
        
            }
        }
    }
    
    //OTA
    @IBAction func initOTA(_ sender: Any) {
        
        let alert = UIAlertController(title: "Tem certeza que deseja atualizar sua banheira ?", message: "Escolha uma das opções:", preferredStyle: .actionSheet)

        // Adiciona opções na lista de opções
        alert.addAction(UIAlertAction(title: "Atualizar painel via OTA", style: .default, handler: { _ in
            // Código para lidar com a seleção da opção 1
            let ip = Settings.ip
            let url = URL(string: "http://\(ip)")
            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false, block: { _ in
                let vc = SFSafariViewController(url: url!)
                self.present(vc, animated: true, completion: nil)
            })

            Utils.sendCommand(cmd: TubCommands.OTA_MODE, value: nil, word: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Atualizar painel automatico", style: .default, handler: { _ in
            // Código para lidar com a seleção da opção 2
            Utils.sendCommand(cmd: TubCommands.OTA_MODE, value: nil, word: " auto")
        }))

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        // Configura o popoverPresentationController para iPad
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = (sender as AnyObject).bounds
        }
        

        // Exibe a lista de opções
        present(alert, animated: true, completion: nil)
    }
    
    //Bloqueio de painel
    @IBAction func switch_bloqueio(_ sender: UISwitch){
        if sender.isOn {
                print("Switch is ON \(Settings.modo_painel)")
                Utils.sendCommand(cmd: TubCommands.MODO_BLOQUEIO, value: nil, word: "bloqueado")
                switch_bloqueio_txt.text = "— Bloqueado"
                Settings.modo_painel = "bloqueado"

            } else {
                print("Switch is OFF \(Settings.modo_painel)")
                Utils.sendCommand(cmd: TubCommands.MODO_BLOQUEIO, value: nil, word: "normal")
                switch_bloqueio_txt.text = "— Desbloqueado"
                Settings.modo_painel = "normal"

            }
    }
    
    //Aquecimento automatico
    @IBAction func switch_aquecimento(_ sender: UISwitch){
        if sender.isOn {
                print("Switch is ON \(Settings.aquecedor_automatico)")
                Utils.sendCommand(cmd: TubCommands.MODO_AQUECIMENTO, value: 1, word: nil)
                switch_aquecimento_txt.text = "— Ligado"
                Settings.aquecedor_automatico = 1
            } else {
                print("Switch is OFF \(Settings.aquecedor_automatico)")
                Utils.sendCommand(cmd: TubCommands.MODO_AQUECIMENTO, value: 0, word: nil)
                switch_aquecimento_txt.text = "— Desligado"
                Settings.aquecedor_automatico = 0

            }
    }
    
}

extension SettingsViewController: ConnectingProtocol, CommunicationProtocol {
    
    func didStartConnectingTub() {
        // Do anything
    }
    
    func didConnectTub() {
        // Do anything
    }
    
    func didDisconnectTub() {
        RequestManager.it.saveTubInfoRequest()
        
        Settings.resetAll()
        //print(self.navigationController?.viewControllers[1] as Any)
        
        //self.dismiss(animated: true)
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
        case BathTubFeedbacks.STATUS_M1:
            profileStatus.text = "\(Settings.memos)/3 salvos"
        case BathTubFeedbacks.STATUS_M2:
            profileStatus.text = "\(Settings.memos)/3 salvos"
        case BathTubFeedbacks.STATUS_M3:
            profileStatus.text = "\(Settings.memos)/3 salvos"
        case BathTubFeedbacks.STATUS_M4:
            profileStatus.text = "\(Settings.memos)/3 salvos"
        case BathTubFeedbacks.STATUS_M5:
            profileStatus.text = "\(Settings.memos)/3 salvos"
        case BathTubFeedbacks.BACKLIGHT:
            brightStatus_txt.text = "— \(Settings.backlight)%"
            bright_txx.text = "\(Settings.backlight)%"
            bright_sld._currentValue = Double(Settings.backlight)
        case BathTubFeedbacks.FT_DAYS:
            configurarStatusFiltragem()
        case BathTubFeedbacks.FT_HOUR:
            if(Settings.ft_days > 0) {
                setFilteringDate(hour: Settings.ft_hour, minute: Settings.ft_min, now: Settings.ft_days == 0)
            }
        case BathTubFeedbacks.FT_MIN:
            if(Settings.ft_days > 0) {
                setFilteringDate(hour: Settings.ft_hour, minute: Settings.ft_min, now: Settings.ft_days == 0)
            }
        case BathTubFeedbacks.FT_TIME:
            if(Settings.ft_days > 0) {
                ftDuration_edt.text = "\(Settings.ft_time)"
            }
        case BathTubFeedbacks.BH_DAYS:
            configurarStatusBanho()
        case BathTubFeedbacks.BH_HOUR:
            if(Settings.bh_days > 0) {
                setFilteringDate(hour: Settings.bh_hour, minute: Settings.bh_min, now: Settings.bh_days == 0)
            }
        case BathTubFeedbacks.BH_MIN:
            if(Settings.bh_days > 0) {
                setFilteringDate(hour: Settings.bh_hour, minute: Settings.bh_min, now: Settings.bh_days == 0)
            }
        case BathTubFeedbacks.BH_TEMP:
            if(Settings.bh_days > 0) {
                ftDuration_edt.text = "\(Settings.bh_temp)"
            }
        case BathTubFeedbacks.FL_TIME:
            scheduleCtrl("")
        case BathTubFeedbacks.WM_TIME:
            scheduleCtrl("")
        case BathTubFeedbacks.WIFI_STATE:
            guard wifiState_clone != value else {
                return
            }
            wifiState_clone = value
            
            if(value == 2) {
                if(wifi_toast) {
                    Utils.toast(vc: self, message: "Wi-Fi configurado com sucesso", type: 1)
                }
                wifiStatus_txt.text = "— \(Settings.ssid)"
            } else if(value == 4) {
                if(wifi_toast) {
                    Utils.toast(vc: self, message: "Wi-Fi não pôde conectar-se a rede", type: 2)
                }
                wifiStatus_txt.text = "— Não configurado"
            } else {
                return
            }
            wifi_toast = false
        case BathTubFeedbacks.MQTT_STATE:
            if(value == 1) {
                mqttStatus_txt.text = "— Disponível"
            } else {
                mqttStatus_txt.text = "— Não disponível"
            }
        case BathTubFeedbacks.DRAIN_TIME:
            drainTime_txt.text = "\(value/60)"
        case BathTubFeedbacks.FUSO:
            updateFusoHorarioStatus(fuso: value)
        default:
            return
        }
    }
    
    func didReceiveFeedback(about: String, text: String) {
        switch(about) {
            case BathTubFeedbacks.STATUS_M1:
                profileStatus.text = "— \(Settings.memos)/3 salvos"
            case BathTubFeedbacks.NAME_M1:
                profileStatus.text = "— \(Settings.memos)/3 salvos"
                profile1_edt.text = Settings.memo1_name
            case BathTubFeedbacks.STATUS_M2:
                profileStatus.text = "— \(Settings.memos)/3 salvos"
                profileStatus.text = "— \(Settings.memos)/3 salvos"
            case BathTubFeedbacks.NAME_M2:
                profileStatus.text = "— \(Settings.memos)/3 salvos"
                profile2_edt.text = Settings.memo2_name
            case BathTubFeedbacks.STATUS_M3:
                profileStatus.text = "— \(Settings.memos)/3 salvos"
                profileStatus.text = "— \(Settings.memos)/3 salvos"
            case BathTubFeedbacks.NAME_M3:
                profileStatus.text = "— \(Settings.memos)/3 salvos"
                profile3_edt.text = Settings.memo3_name
            case BathTubFeedbacks.STATUS_M4:
                profileStatus.text = "— \(Settings.memos)/3 salvos"
                profileStatus.text = "— \(Settings.memos)/3 salvos"
            case BathTubFeedbacks.NAME_M4:
                profileStatus.text = "— \(Settings.memos)/3 salvos"
                profile4_edt.text = Settings.memo4
            case BathTubFeedbacks.STATUS_M5:
                profileStatus.text = "— \(Settings.memos)/3 salvos"
            case BathTubFeedbacks.NAME_M5:
                profileStatus.text = "— \(Settings.memos)/3 salvos"
                profile5_edt.text = Settings.memo5
            case BathTubFeedbacks.DRAIN_MODE:
                drainMode_swt.isOn = Settings.drain_mode != 0
            default:
                return
        }
    }
}

extension SettingsViewController: RequestProtocol {
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) { }
    
    func onError(code: Int, error: Error, source: String) { }
    
}
