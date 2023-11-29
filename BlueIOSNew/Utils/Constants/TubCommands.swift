//
//  TubCommands.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

class TubCommands {
    
    static let STATUS = "st"
    static let POWER = "p "
    static let GET_LEVEL = "statusNivel"
    static let GET_TEMP = "statusTempAgua"
    static let GET_DTEMP = "statusTempSet"
    static let TEMP_SET = "tempset "                //const value 15~40

    static let WATER = "agua "
    static let SET_AUTOON = "saae "
    static let SPOT_OFF = "spots off"
    static let SPOT_STATIC_CROMO = "spots st "      //0 - 8 = branco - cyan - azul - rosa - magenta - vermelho - laranja - amarelo - verde
    //static let SPOT_STATIC_RGB = "spots rgb "     // + R + G + B unused
    static let SPOT_STATIC_HSL = "spots st "       // + H + S + L
    static let SPOT_RND_1 = "spots rnd1"
    static let SPOT_RND_2 = "spots rnd2"
    static let SPOT_SEQ_1 = "spots seq1"
    static let SPOT_SEQ_2 = "spots seq2"
    static let SPOT_BMR_1 = "spots bmr1"
    static let SPOT_BMR_2 = "spots bmr2"
    static let SPOT_CLD = "spots cld"
    static let SPOT_STROBE = "spots stb"
    static let SPOT_SPEED = "spots setvel "         // const value 1~10
    static let SPOT_BRIGHT = "spots setbrilho "     // const valor 1~10
    static let STRIP_OFF = "fitas off"
    static let STRIP_STATIC_CROMO = "fitas st "      //0 - 8 = branco - cyan - azul - rosa - magenta - vermelho - laranja - amarelo - verde
    //static let STRIP_STATIC_RGB = "fitas rgb "     // + R + G + B unused
    static let STRIP_STATIC_HSL = "fitas st "       // + H + S + L
    static let STRIP_RND_1 = "fitas rnd1"
    static let STRIP_RND_2 = "fitas rnd2"
    static let STRIP_SEQ_1 = "fitas seq1"
    static let STRIP_SEQ_2 = "fitas seq2"
    static let STRIP_BMR_1 = "fitas bmr1"
    static let STRIP_BMR_2 = "fitas bmr2"
    static let STRIP_CLD = "fitas cld"
    static let STRIP_STROBE = "fitas stb"
    static let STRIP_SPEED = "fitas setvel "         // const value 1~10
    static let STRIP_BRIGHT = "fitas setbrilho "     // const value 1~10
    static let LED_N = "setquantleds "              // + spot + fita
    static let WIFI = "setwifi "                    // + ssid + senha
    static let SET_BACKLIGHT = "setbacklit "
    static let TUB_PSWD = "setsenha "               // + posição + nova_senha
    static let KEEP_WARM = "smqe "
    static let TIMEZONE = "setfuso "
    static let SET_FILTER = "saf "
    static let CLR_FILTER = "aaf "
    static let SET_BATH = "sab "
    static let CLR_BATH = "aab"
    static let CLR_FTIME = "rtp"
    static let SET_DRAIN_MODE = "smar "
    static let SET_DRAIN_TIME = "settempoesvaziar "
    static let OTA_MODE = "setmodo ota"
    static let SET_DATE = "setdata "
    static let STATUS_MEMO = "statusmemo"
    static let NAME_MEMO = "smemon "
    static let SAVE_MEMO = "salvageral "
    static let LOAD_MEMO = "m "
    static let CLR_MEMO = "apagamemo "
    
    static let SET_Q_BOMBS = "setquantbombas "
    static let SET_WATER_CTRL = "setcontroleagua "
    static let SET_AUTO_ON = "setligaautom "
    static let SET_WARMER = "setaquecedor "
    static let SET_HASTEMP = "setsensortemp "
    static let SET_HASCROMO = "setcromo "
    static let SET_SPOT_CMODE = "spots setpadrao "
    static let SET_STRIP_CMODE = "fitas setpadrao "
    
    static let CASCATA = "cascata "
    static let BLOWER = "blower "
    static let MODO_ECO = "smqe "
    static let MODO_BLOQUEIO = "setmodo "
    static let MODO_AQUECIMENTO = "saw "
    static let TIMEOUT_BANHEIRA = "settimeoutligado "
    
    
    static let B1 = "s 1 "
    static let B2 = "s 2 "
    static let B3 = "s 3 "
    static let B4 = "s 4 "
    static let B5 = "s 5 "
    static let B6 = "s 6 "
    static let B7 = "s 7 "
    static let B8 = "s 8 "
    static let B9 = "s 9 "
    
    static let SPOTS_EFFECT_COLOR = "spots cor "
    static let SPOTS_MODE_CHROMO = "spots st "
    static let STRIP_EFFECT_COLOR = "fitas cor "
    static let STRIP_MODE_CHROMO = "fitas st "
    
    static let STATUS_ERRO = "stErro"
    static let APAGA_ERRO = "apagaErro"
}
