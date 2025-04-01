//
//  Settings.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation

class Settings {
    
    static var it = UserDefaults.standard
    
    // User
    static var uemail = ""
    static var upswd = ""
    static var uname = ""
    static var last_BTid = ""
    
    // General Config
    static var inApp_notif = false
    static var vol_notif = 20
    static var off_action = 0       // 0~3
    
    // Tub
    static var BTid = ""
    static var favorite = ""
    static var online = false
    static var loc_lat = ""
    static var loc_lng = ""
    static var tubname = ""
    static var tub_pswd1 = ""
    static var tub_pswd2 = ""
    static var tub_pswd3 = ""
    static var tub_pswd4 = ""
    static var n_pswd = 0
    
    static var power = 0
    static var backlight = 0        // 1~100
    static var temp_off = 0
    static var delay_n1 = 0
    static var delay_n2 = 0
    
    static var heater = 0
    static var has_heater = 0
    
    static var curr_temp = 15       // 15~40
    static var desr_temp = 15       // 15~40
    static var has_temp = 0
    
    static var ft_days = 0
    static var ft_hour = 0
    static var ft_min = 0
    static var ft_time = 0
    static var bh_days = 0
    static var bh_hour = 0
    static var bh_min = 0
    static var bh_temp = 0
    static var fl_time = 0
    static var wm_time = 0
    
    static var ralo_on_off = ""
    
    static var memos: Int {
        get {
            return (memo1 == 0 ? 0:1) +
                    (memo2 == 0 ? 0:1) +
                    (memo3 == 0 ? 0:1)
        }
    }
    static var memo1 = 0
    static var memo2 = 0
    static var memo3 = 0
    static var memo1_name = ""
    static var memo2_name = ""
    static var memo3_name = ""
    
    static var produto = ""
    
    static var memo4 = ""
    static var memo5 = ""
    
    static var qt_bombs = 0
    static var bomb_1 = -1
    static var bomb_2 = -1
    static var bomb_3 = -1
    static var bomb_4 = -1
    static var bomb_5 = -1
    static var bomb_6 = -1
    static var bomb_7 = -1
    static var bomb_8 = -1
    static var bomb_9 = -1
    static var cooling = 0
    
    static var level = 0            // 0~2
    
    static var auto_on = 0
    
    static var waterctrl = 0
    static var has_waterctrl = 0
    
    static var has_drain = 0
    static var drain_mode = 0
    static var drain_time = 0
    
    static var has_cromo = 0
    
    static var n_spotleds = 0
    static var n_stripleds = 0
    
    static var spot_state = 0
    static var strip_state = 0
    
    static var spot_static = 0
    static var strip_static = 0
    
    static var spot_speed = 0       // 1~10
    static var strip_speed = 0      // 1~10
    
    static var spot_bright = 0      // 0~10
    static var strip_bright = 0     // 0~10
    
    static var spot_cmode = 0
    static var strip_cmode = 0
    
    static var keep_warm = 0
    static var bubbles = -1
    static var cascata = -1
    static var modo_eco = 0
    static var banheira_com_aquecedor : String = ""
    static var modo_painel : String = ""
    static var aquecedor_on_off = -1
    static var aquecedor_automatico : Int = -1
    static var timeoutligado : Int = -1
    static var timeEnchimento : Int = -1
    
    
    static var auto_conn = false
    
    static var firmware = ""
    static var version = ""
    
    static var wifi_state = -1
    static var ip = ""
    static var ssid = ""
    static var pswd = ""
    
    static var mqtt_state = -1
    static var mqtt_pub = ""
    static var mqtt_sub = ""
    
    static var initialized = false
    static var pswd_err = false
    
    static var codigo_erro = -1
    static var data_erro = -1
    
    // Painel solar
    static var temp_solar = -1
    static var temp_off_set_solar = -1
    static var canal_solar = -1
    static var canal_valvula_solar = -1
    static var temp_esperar_agua_quente = -1
    static var off_set_solar_aquecedor = -1
    static var off_set_soh_solar = -1
    static var inicio_horario = -1
    static var fim_horario = -1
    static var solar = -1
    
    //Esvaziar
    static var ralo = -1
    static var tempoEsvaziar = -1

    //Fuso
    static var fuso = -13
}

extension Settings {
    
    static func inititate(){
        // Load basic info
        loadLoggedUser()
        loadfavTub()
        loadConfigs()
    }
    
    static func saveLoggedUser(email: String, pswd: String, name: String) {
        self.uemail = email
        self.upswd = pswd
        self.uname = name
        
        let login = "\(email)§\(pswd)§\(name)"
        it.set(login, forKey: "APP_LOGIN")
    }

    static func loadLoggedUser() {
        if let login = it.object(forKey: "APP_LOGIN") as? String {
            let l = login.components(separatedBy: "§")
            self.uemail = l.first ?? ""
            self.upswd = l[1]
            self.uname = l.last ?? ""
            return
        }
        self.uemail = ""
        self.upswd = ""
        self.uname = ""
    }
    
    static func saveFavTub(BT_id: String) {
        self.favorite = BT_id
        it.set(self.favorite, forKey: "FAV_TUB")
    }

    static func loadfavTub() {
        if let fav = it.object(forKey: "FAV_TUB") as? String {
            self.favorite = fav
            return
        }
        self.favorite = ""
    }
    
    static func saveConfigs(inApp: Bool?, vol: Int?, off: Int?) {
        if let ia = inApp {
            self.inApp_notif = ia
            it.set(self.inApp_notif, forKey: "IAP_NOT")
        }
        if let vl = vol {
            self.vol_notif = vl
            it.set(self.vol_notif, forKey: "VOL_NOT")
        }
        if let of = off {
            self.off_action = of
            it.set(self.off_action, forKey: "OFF_ACT")
        }
    }

    static func loadConfigs() {
        if let ia = it.object(forKey: "IAP_NOT") as? Bool {
            self.inApp_notif = ia
        }
        if let vl = it.object(forKey: "VOL_NOT") as? Int {
            self.vol_notif = vl
        }
        if let of = it.object(forKey: "OFF_ACT") as? Int {
            self.off_action = of
        }
    }
    
    static func logout() {
        // Clear Settings
        self.uemail = ""
        self.upswd = ""
        self.uname = ""
        
        // Clear userdefaults
        it.removeObject(forKey: "APP_LOGIN")
        it.removeObject(forKey: "FAV_TUB")
        
        // Clear saved tubs
        if let db = RealmDB.it {
            do {
                try db.write {
                    //db.delete(db.objects(Tub.self))
                    db.deleteAll()
                }
            } catch  { }
        }
        
    }
    
    static func resetAll() {
        online = false
        
        BTid = ""
        tubname = ""
        tub_pswd1 = ""
        tub_pswd2 = ""
        tub_pswd3 = ""
        tub_pswd4 = ""
        n_pswd = 0
        
        loc_lat = ""
        loc_lng = ""
        
        power = 0
        backlight = 0        // 1~100
        temp_off = 0
        delay_n1 = 0
        delay_n2 = 0
        
        heater = 0
        has_heater = 0
        
        ft_days = 0
        ft_hour = 0
        ft_min = 0
        ft_time = 0
        bh_days = 0
        bh_hour = 0
        bh_min = 0
        bh_temp = 0
        fl_time = 0
        wm_time = 0
        
        memo1 = 0
        memo2 = 0
        memo3 = 0
        memo1_name = ""
        memo2_name = ""
        memo3_name = ""
        memo4 = ""
        memo5 = ""
        
        produto = ""
        
        curr_temp = 15       // 15~40
        desr_temp = 15       // 15~40
        has_temp = 0
        
        qt_bombs = 0
        bomb_1 = 0
        bomb_2 = 0
        bomb_3 = 0
        bomb_4 = 0
        bomb_5 = 0
        bomb_6 = 0
        bomb_7 = 0
        bomb_8 = 0
        bomb_9 = 0
        cooling = 0
        
        level = 0            // 0~2
        
        auto_on = 0
        
        waterctrl = 0
        has_waterctrl = 0
        has_drain = 0
        drain_mode = 0
        drain_time = 0
        
        has_cromo = 0
        
        n_spotleds = 0
        n_stripleds = 0
        
        spot_state = 0
        strip_state = 0
        
        spot_static = 0
        strip_static = 0
        
        spot_speed = 0       // 1~10
        strip_speed = 0      // 1~10
        
        spot_bright = 0      // 0~10
        strip_bright = 0     // 0~10
        
        spot_cmode = 0
        strip_cmode = 0
        
        keep_warm = 0
        bubbles = -1
        cascata = -1
        modo_eco = 0
        banheira_com_aquecedor = ""
        modo_painel = ""
        aquecedor_on_off = -1
        aquecedor_automatico = -1
        timeoutligado = -1
        
        ralo_on_off = ""
        
        auto_conn = false
        
        firmware = ""
        version = ""
        
        wifi_state = -1
        ip = ""
        ssid = ""
        pswd = ""
        
        mqtt_state = -1
        mqtt_pub = ""
        mqtt_sub = ""
        
        initialized = false
        pswd_err = false
        
        codigo_erro = -1
        data_erro = -1
        
        timeEnchimento = -1
        
        //painel solar
        temp_solar = -1
        temp_off_set_solar = -1
        canal_solar = -1
        canal_valvula_solar = -1
        temp_esperar_agua_quente = -1
        off_set_solar_aquecedor = -1
        off_set_soh_solar = -1
        inicio_horario = -1
        fim_horario = -1
        
        //esvaziar
        ralo = -1
        tempoEsvaziar = -1

        //fuso
        fuso = -1
    }
    
}

extension Settings {
    
    static func updateIntSettings(about: String, value: Int) {
        print("\(about):\(value)")
        switch about {
        case BathTubFeedbacks.QT_BOMBS:
            Settings.qt_bombs = value
        case BathTubFeedbacks.HAS_WATER_CTRL:
            Settings.has_waterctrl = value
        case BathTubFeedbacks.WATER_CTRL:
            Settings.waterctrl = value
        case BathTubFeedbacks.HAS_TEMP:
            Settings.has_temp = value
        case BathTubFeedbacks.AUTO_ON:
            Settings.auto_on = value
        case BathTubFeedbacks.KEEP_WARM:
            Settings.keep_warm = value
        case BathTubFeedbacks.AQUECEDOR_ON_OFF:
            Settings.aquecedor_on_off = value
        case BathTubFeedbacks.AQUECEDOR_AUTOMATICO:
            Settings.aquecedor_automatico = value
        case BathTubFeedbacks.TIMEOUTBANHEIRA:
            Settings.timeoutligado = value
        case BathTubFeedbacks.HAS_HEATER:
            Settings.has_heater = value
        case BathTubFeedbacks.HAS_DRAIN:
            Settings.has_drain = value
        case BathTubFeedbacks.DRAIN_TIME:
            Settings.drain_time = value
        case BathTubFeedbacks.HAS_CROMO:
            Settings.has_cromo = value
        case BathTubFeedbacks.WIFI_STATE:
            Settings.wifi_state = value
        case BathTubFeedbacks.BACKLIGHT:
            Settings.backlight = value
        case BathTubFeedbacks.TEMP_OFFSET:
            Settings.temp_off = value
        case BathTubFeedbacks.GET_TN1:
            Settings.delay_n1 = value
        case BathTubFeedbacks.GET_TN2:
            Settings.delay_n2 = value
        case BathTubFeedbacks.FT_DAYS:
            Settings.ft_days = value
        case BathTubFeedbacks.FT_HOUR:
            Settings.ft_hour = value
        case BathTubFeedbacks.FT_MIN:
            Settings.ft_min = value
        case BathTubFeedbacks.FT_TIME:
            Settings.ft_time = value
        case BathTubFeedbacks.BH_DAYS:
            Settings.bh_days = value
        case BathTubFeedbacks.BH_HOUR:
            Settings.bh_hour = value
        case BathTubFeedbacks.BH_MIN:
            Settings.bh_min = value
        case BathTubFeedbacks.BH_TEMP:
            Settings.bh_temp = value
        case BathTubFeedbacks.FL_TIME:
            Settings.fl_time = value
        case BathTubFeedbacks.WM_TIME:
            Settings.wm_time = value
        case BathTubFeedbacks.POWER:
            var p = value
            if(p == 2) { p = 0 }
            Settings.power = p
            initialized = true
        case BathTubFeedbacks.TEMP_NOW:
            Settings.curr_temp = value
            Notifications.notify(title: "\(tubname) na temperatura desejada", message: "A banheira já se encontra na temperatura desejada", reason: about, identifier: "\(Utils.getMqttId() ?? " Banheira")_TEMP")
        case BathTubFeedbacks.TEMP_DESIRED:
            Settings.desr_temp = value
            
        case BathTubFeedbacks.BOMB1_STATE:
            Settings.bomb_1 = value
        case BathTubFeedbacks.BOMB2_STATE:
            Settings.bomb_2 = value
        case BathTubFeedbacks.BOMB3_STATE:
            Settings.bomb_3 = value
        case BathTubFeedbacks.BOMB4_STATE:
            Settings.bomb_4 = value
        case BathTubFeedbacks.BOMB5_STATE:
            Settings.bomb_5 = value
        case BathTubFeedbacks.BOMB6_STATE:
            Settings.bomb_6 = value
        case BathTubFeedbacks.BOMB7_STATE:
            Settings.bomb_7 = value
        case BathTubFeedbacks.BOMB8_STATE:
            Settings.bomb_8 = value
        case BathTubFeedbacks.BOMB9_STATE:
            Settings.bomb_9 = value
            
        case BathTubFeedbacks.HEATER_STATE:
            Settings.heater = value
        case BathTubFeedbacks.LEVEL_STATE:
            Settings.level = value
            Notifications.notify(title: "\(tubname) em nível máximo", message: "A banheira já se encontra cheia", reason: about, identifier: "\(Utils.getMqttId() ?? " Banheira")_LEVEL")
        case BathTubFeedbacks.QT_SPOTLEDS:
            Settings.n_spotleds = value
        case BathTubFeedbacks.QT_STRIPLEDS:
            Settings.n_stripleds = value
        case BathTubFeedbacks.SPOTS_STATE:
            Settings.spot_state = value
        case BathTubFeedbacks.SPOTS_COLOR:
            Settings.spot_static = value
        case BathTubFeedbacks.SPOTS_SPEED:
            Settings.spot_speed = value
        case BathTubFeedbacks.SPOTS_BRIGHT:
            Settings.spot_bright = value
        case BathTubFeedbacks.SPOTS_COLORMODE:
            Settings.spot_cmode = value
        case BathTubFeedbacks.STRIP_STATE:
            Settings.strip_state = value
        case BathTubFeedbacks.STRIP_COLOR:
            Settings.strip_static = value
        case BathTubFeedbacks.STRIP_SPEED:
            Settings.strip_speed = value
        case BathTubFeedbacks.STRIP_BRIGHT:
            Settings.strip_bright = value
        case BathTubFeedbacks.STRIP_COLORMODE:
            Settings.strip_cmode = value
        case BathTubFeedbacks.COOLING:
            Settings.cooling = value
        case BathTubFeedbacks.MQTT_STATE:
            Settings.mqtt_state = value
            Settings.online = value == 1
        case BathTubFeedbacks.TUB_NPSWD:
            Settings.n_pswd = value
        case BathTubFeedbacks.CASCATA:
            Settings.cascata = value
        case BathTubFeedbacks.BLOWER:
            Settings.bubbles = value
        case BathTubFeedbacks.MODO_ECO:
            Settings.modo_eco = value
        case BathTubFeedbacks.CODIGO_ERRO:
            Settings.codigo_erro = value
        case BathTubFeedbacks.DATA_ERRO:
            Settings.data_erro = value
        case BathTubFeedbacks.LAST_ON:
            Settings.online = true
        case BathTubFeedbacks.STATUS_M1:
            memo1 = value
        case BathTubFeedbacks.STATUS_M2:
            memo2 = value
        case BathTubFeedbacks.STATUS_M3:
            memo3 = value
        case BathTubFeedbacks.TIMEOUTENCHENDO:
            timeEnchimento = value
            //Painel Solar
        case BathTubFeedbacks.TEMP_SOLAR:
            temp_solar = value
        case BathTubFeedbacks.SOLAR:
            solar = value
        case BathTubFeedbacks.TEMP_OFF_SET_SOLAR:
            temp_off_set_solar = value
        case BathTubFeedbacks.CANAL_SOLAR:
            canal_solar = value
        case BathTubFeedbacks.CANAL_VALVULA_SOLAR:
            canal_valvula_solar = value
        case BathTubFeedbacks.TEMP_ESPERAR_AGUA_QUENTE:
            temp_esperar_agua_quente = value
        case BathTubFeedbacks.OFF_SET_SOLAR_AQUECEDOR:
            off_set_solar_aquecedor = value
        case BathTubFeedbacks.OFF_SET_SOH_SOLAR:
            off_set_soh_solar = value
        case BathTubFeedbacks.INICIO_HORARIO:
            inicio_horario = value
        case BathTubFeedbacks.FIM_HORARIO:
            fim_horario = value
        case BathTubFeedbacks.RALO:
                ralo = value
        case BathTubFeedbacks.TEMPO_ESVAZIAR:
                tempoEsvaziar = value
        case BathTubFeedbacks.FUSO:
                fuso = value
        default:
            return
        }
    }
    
    static func updateStrSettings(about: String, text: String) {
        print("\(about):\(text)")
        switch about {
        case BathTubFeedbacks.BANHEIRA_COM_AQUECEDOR:
            Settings.banheira_com_aquecedor = text
        case BathTubFeedbacks.MODO_PAINEL:
            Settings.modo_painel = text
        case BathTubFeedbacks.FIRMWARE:
            Settings.firmware = text
        case BathTubFeedbacks.VERSION:
            Settings.version = text
        case BathTubFeedbacks.SSID:
            Settings.ssid = text
        case BathTubFeedbacks.PSWD:
            Settings.pswd = text
        case BathTubFeedbacks.IP:
            Settings.ip = text
//            if(wifi_state == 2) {
//                saveOnlineTub()
//            }
        case BathTubFeedbacks.MQTT_PUB:
            Settings.mqtt_pub = text
        case BathTubFeedbacks.MQTT_SUB:
            Settings.mqtt_sub = text
            if(!text.isEmpty) {
                Notifications.subscribeToRemoteNotifications(topic: Utils.getMqttId(pub: text, sub: text) ?? "")
            }
        case BathTubFeedbacks.TUB_PSWD1:
            Settings.tub_pswd1 = text
        case BathTubFeedbacks.TUB_PSWD2:
            Settings.tub_pswd2 = text
        case BathTubFeedbacks.TUB_PSWD3:
            Settings.tub_pswd3 = text
        case BathTubFeedbacks.TUB_PSWD4:
            Settings.tub_pswd4 = text
        case BathTubFeedbacks.MSG_CODE:
            CommandQoS.removePendingCommand(code: text)
        case BathTubFeedbacks.PSWD_ERR:
            if(text == "ERRO") { pswd_err = true }
        case BathTubFeedbacks.STATUS_M4:
            if(text != "GRAVADA" && text != "SALVA") {
                memo4 = ""
            }
        case BathTubFeedbacks.NAME_M4:
            memo4 = text
        case BathTubFeedbacks.STATUS_M5:
            if(text != "GRAVADA" && text != "SALVA") {
                memo5 = ""
            }
        case BathTubFeedbacks.NAME_M5:
            memo5 = text
        case BathTubFeedbacks.DRAIN_MODE:
            Settings.drain_mode = text == "toque_longo" ? 1 : 0
        case BathTubFeedbacks.NAME_M1:
            Settings.memo1_name = text
        case BathTubFeedbacks.NAME_M2:
            Settings.memo2_name = text
        case BathTubFeedbacks.NAME_M3:
            Settings.memo3_name = text
        case BathTubFeedbacks.PRODUTO:
            Settings.produto = text
        case BathTubFeedbacks.RALO_ON_OFF:
            ralo_on_off = text
        default:
            return
        }
    }
}
