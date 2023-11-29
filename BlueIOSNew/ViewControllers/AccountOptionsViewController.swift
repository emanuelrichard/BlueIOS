//
//  AccountOptionsViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 12/04/23.
//

import UIKit
import DCKit

class AccountOptionsViewController: UIViewController {

    @IBOutlet weak var edtName: UITextField!
    @IBOutlet weak var edtCurrPswd: UITextField!
    @IBOutlet weak var edtNewPswd1: UITextField!
    @IBOutlet weak var edtNewPswd2: UITextField!
    @IBOutlet weak var btnSave: DCBorderedButton!
    @IBOutlet weak var btnLogoff: DCBorderedButton!
    @IBOutlet weak var btnDeleteAcc: DCBorderedButton!
    @IBOutlet weak var btnBack: DCBorderedButton!
    
    
    var logoffLongPress = UILongPressGestureRecognizer(target: AccountOptionsViewController.self, action: #selector(logoff))
    var deleteLongPress = UILongPressGestureRecognizer(target: AccountOptionsViewController.self, action: #selector(deleteAccount))
    
    private var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyGradient(to: btnSave)
        applyGradient(to: btnLogoff)
        
        // Configura o campo do nomo
        edtName.layer.cornerRadius = 15.0
        edtName.layer.masksToBounds = true
        edtName.backgroundColor = UIColor.clear
        edtName.layer.borderColor = UIColor.lightGray.cgColor
        edtName.layer.borderWidth = 1
        edtName.textColor = UIColor.white
        
        // Configura o campo do pswd antigo
        edtCurrPswd.layer.cornerRadius = 15.0
        edtCurrPswd.layer.masksToBounds = true
        edtCurrPswd.backgroundColor = UIColor.clear
        edtCurrPswd.layer.borderColor = UIColor.lightGray.cgColor
        edtCurrPswd.layer.borderWidth = 1
        edtCurrPswd.textColor = UIColor.white
        
        // Configura o campo do pswd1
        edtNewPswd1.layer.cornerRadius = 15.0
        edtNewPswd1.layer.masksToBounds = true
        edtNewPswd1.backgroundColor = UIColor.clear
        edtNewPswd1.layer.borderColor = UIColor.lightGray.cgColor
        edtNewPswd1.layer.borderWidth = 1
        edtNewPswd1.textColor = UIColor.white
        
        // Configura o campo do pswd2
        edtNewPswd2.layer.cornerRadius = 15.0
        edtNewPswd2.layer.masksToBounds = true
        edtNewPswd2.backgroundColor = UIColor.clear
        edtNewPswd2.layer.borderColor = UIColor.lightGray.cgColor
        edtNewPswd2.layer.borderWidth = 1
        edtNewPswd2.textColor = UIColor.white
        
        // Cria um gradiente com as 3 cores desejadas
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor, UIColor(red: 102/255, green: 148/255, blue: 250/255, alpha: 1).cgColor, UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor]
        
        // Define o plano de fundo da view com o gradiente
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        edtName.text = Settings.uname

        logoffLongPress = UILongPressGestureRecognizer(target: self, action: #selector(logoff))
        logoffLongPress.minimumPressDuration = 0.8
        btnLogoff.addGestureRecognizer(logoffLongPress)
        
        deleteLongPress = UILongPressGestureRecognizer(target: self, action: #selector(deleteAccount))
        deleteLongPress.minimumPressDuration = 0.8
        btnDeleteAcc.addGestureRecognizer(deleteLongPress)
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
    
    @objc private func logoff() {
        if(logoffLongPress.state == .ended) {
            btnCtrl(enabled: false)
            RequestManager.it.logoutRequest(delegate: nil)

            Settings.logout()
            backToLogin()
        }
    }
    
    @objc private func deleteAccount() {
        if(deleteLongPress.state == .ended) {
            btnCtrl(enabled: false)
            RequestManager.it.deleteUserRequest(delegate: self)
        }
    }
    
    @IBAction func saveChangesClick(_ sender: Any) {
        var name = edtName.text
        var pswd1 = edtNewPswd1.text
        var pswd2 = edtNewPswd2.text
        let pswdC = edtCurrPswd.text!
        
        if(!(name?.isEmpty ?? true)) {
            guard isValidName(name!) else {
                return
            }
            Settings.uname = name!
            password = Settings.upswd
        } else { name = nil }
        
        if(!(pswd1?.isEmpty ?? true)) {
            guard isValidPswd1(pswd1!) else {
                return
            }
        } else { pswd1 = nil }
        
        if(!(pswd2?.isEmpty ?? true)) {
            guard isValidPswd2(pswd2!) else {
                return
            }
            password = pswd1!
        } else { pswd2 = nil }
        
        if(pswd1 != nil && Settings.upswd != pswdC) {
            password = ""
            Utils.toast(vc: self, message: "Senha atual está incorreta", type: 2)
            return
        }
        
        btnCtrl(enabled: false)
        
        RequestManager.it.updateUserRequest(name: name, password: pswd1, delegate: self)
    }
    
    @IBAction func logoffClick(_ sender: Any) {
        Utils.toast(vc: self, message: "Segure o botão para confirmar a ação")
    }
    
    @IBAction func deleteClick(_ sender: Any) {
        Utils.toast(vc: self, message: "Segure o botão para confirmar a ação")
    }
    
    @IBAction func backClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension AccountOptionsViewController {
    
    // MARK: - Métodos de Validação
    
    // Verifica se o nome inserido é válido
    private func isValidName(_ name: String) -> Bool {
        if edtName.text!.count < 4 {
            Utils.toast(vc: self, message: "Nome muito curto, tente digitar um nome um pouco mais completo", type: 2)
            edtName.textColor = UIColor.init(named: "red_color")
            return false
        } else {
            edtName.textColor = UIColor.init(named: "title_color")
            return true
        }
    }
    
    // Verifica se a senha inserida atende aos requisitos mínimos
    private func isValidPswd1(_ pswd1: String) -> Bool {
        if pswd1.count < 6 {
            Utils.toast(vc: self, message: "A senha deve conter no mínimo 6 dígitos", type: 2)
            edtNewPswd1.textColor = UIColor.init(named: "red_color")
            return false
        } else {
            edtNewPswd1.textColor = UIColor.init(named: "title_color")
            return true
        }
    }
    
    // Verifica se as duas senhas inseridas coincidem
    private func isValidPswd2(_ pswd2: String) -> Bool {
        if edtNewPswd1.text! != pswd2 {
            Utils.toast(vc: self, message: "As senhas não correspondem", type: 2)
            edtNewPswd2.textColor = UIColor.init(named: "red_color")
            return false
         } else {
            edtNewPswd2.textColor = UIColor.init(named: "title_color")
            return true
         }
    }
    
    // MARK: - Outros Métodos
    
    // Retorna para a tela de login
    private func backToLogin() {
        navigationController?.popToViewController((navigationController?.viewControllers[1])!, animated: true)
    }
    
    // Controla o estado habilitado/desabilitado dos botões
    private func btnCtrl(enabled: Bool) {
        btnSave.isEnabled = enabled
        btnLogoff.isEnabled = enabled
        //btnDeleteAcc.isEnabled = enabled
        //btnBack.isEnabled = enabled
    }
}


extension AccountOptionsViewController: RequestProtocol {
    
    // MARK: - Métodos do Protocolo de Requisição
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) {
        DispatchQueue.main.async {
            self.btnCtrl(enabled: true)
            
            // Verifica se a requisição foi bem-sucedida (código de status < 400)
            if code < 400 {
                switch source {
                case "PUT_USER":
                    
                    // Atualiza a senha local se não estiver vazia
                    if !self.password.isEmpty {
                        Settings.saveLoggedUser(email: Settings.uemail, pswd: self.password, name: Settings.uname)
                        self.password = ""
                    }
                    
                    Utils.toast(vc: self, message: "Alterações salvas com sucesso", type: 1)
                    
                    // Remove a tela após um atraso
                    Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { (timer) in
                        self.navigationController?.popViewController(animated: true)
                    }
                    break
                case "DELETE_USER":
                    Utils.toast(vc: self, message: "Conta deletada com sucesso", type: 1)
                    
                    // Faz logout e volta para a tela de login após um atraso
                    Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { (timer) in
                        Settings.logout()
                        self.backToLogin()
                    }
                    break
                default:
                    return
                }
            } else if code < 500 {
                // Trata erros com código de status entre 400 e 499
                self.password = ""
                
                // Verifica se o erro é devido a acesso não autorizado (401 Não Autorizado)
                if code == 401 {
                    Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { (timer) in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
                // Trata outros erros HTTP
                Utils.handleHTTPError(vc: self, code: code, msg: "Não foi possível completar sua requisição, tente novamente mais tarde")
            }
        }
    }
    
    func onError(code: Int, error: Error, source: String) {
        DispatchQueue.main.async {
            self.password = ""
            self.btnCtrl(enabled: true)
            
            // Trata erros com código de status >= 500
            Utils.handleHTTPError(vc: self, code: code, msg: "Não foi possível completar sua requisição, tente novamente mais tarde")
        }
    }
}
