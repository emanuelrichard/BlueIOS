//
//  LoginViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 08/04/23.
//

import UIKit
import DCKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email_edt: UITextField!
    @IBOutlet weak var pswd_edt: UITextField!
    @IBOutlet weak var enter_btn: DCBorderedButton!
    @IBOutlet weak var register_btn: DCBorderedButton!
    
    @IBOutlet weak var view_principal: UIView!
    @IBOutlet weak var bathtub_image: UIImageView!
    @IBOutlet weak var txt_email: UILabel!
    @IBOutlet weak var txt_senha: UILabel!

    
    private let realmDB = RealmDB.it
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Cria um gradiente com as 3 cores desejadas
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor, UIColor(red: 102/255, green: 148/255, blue: 250/255, alpha: 1).cgColor, UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor]
        
        // Define o plano de fundo da view com o gradiente
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Load Settings
        Settings.inititate()
        
        // Check for already logged users
        if(!Settings.uemail.isEmpty) {
            performSegue(withIdentifier: "ALogged", sender: nil)
        }
        
        // Setup edit's delegates
        email_edt.delegate = self
        pswd_edt.delegate = self
        
        applyGradient(to: enter_btn)
        applyGradient(to: register_btn)
    }
    
    private func applyGradient(to button: UIButton) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.colors = [
            UIColor(red: 0, green: 0.2, blue: 0.4, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 0.4, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        button.layer.addSublayer(gradientLayer)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       let nextTag = textField.tag + 1
       // Try to find next responder
       let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder?

       if nextResponder != nil {
           // Found next responder, so set it
           nextResponder?.becomeFirstResponder()
       } else {
           // Not found, so remove keyboard
           textField.resignFirstResponder()
       }

       return false
   }
    
    @IBAction func registeredClick(_ sender: Any) {
        self.performSegue(withIdentifier: "ARegister", sender: nil)
    }
    
    @IBAction func enterClick(_ sender: Any) {
        enter_btn.isEnabled = false
        validateLogin()
        enter_btn.superview?.endEditing(true)
    }
    
    private func validateLogin() {
        if let email = email_edt.text, let pswd = pswd_edt.text {
            Settings.uemail = email
            Settings.upswd = pswd
            RequestManager.it.loginRequest(email: email, pswd: pswd, delegate: self)
            Utils.toast(vc: self, message: "Validando credenciais...", type: 0)
            return
        }
        Utils.toast(vc: self, message: "Credenciais de login incorretas", type: 2)
    }
    
    @IBAction func forgotPassClick(_ sender: Any) {
        if let email = email_edt.text, !email.isEmpty {
            self.enter_btn.isEnabled = false
            RequestManager.it.userForgotRequest(email: email, delegate: self)
            return
        }
        Utils.toast(vc: self, message: "Preencha o campo de e-mail para que uma nova senha possa ser enviada", type: 2)
    }
}

// Definição de uma extensão da classe LoginViewController que implementa o protocolo RequestProtocol
extension LoginViewController: RequestProtocol {
    
    // Função chamada quando a requisição HTTP é bem sucedida
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) {
        DispatchQueue.main.async {
            // Habilita o botão de entrar novamente
            self.enter_btn.isEnabled = true
            
            // Limpa o campo de senha
            self.pswd_edt.text = ""
            
            // Verifica se o código HTTP retornado é menor do que 400 (sucesso)
            if(code < 400) {
                // Verifica a origem da requisição
                if(source == "POST_LOGIN") {
                    // Extrai os dados de login do primeiro item do array de resposta
                    let login = response.first!
                    let name = login["name"] as! String
                    
                    // Salva o usuário logado nos ajustes do aplicativo
                    Settings.saveLoggedUser(email: Settings.uemail, pswd: Settings.upswd, name: name)
                    
                    // Executa a transição para a próxima tela do aplicativo
                    self.performSegue(withIdentifier: "ALogged", sender: nil)
                } else if(source == "USER_FORGOT") {
                    // Mostra uma mensagem de sucesso para o usuário
                    Utils.toast(vc: self, message: "E-mail enviado com sucesso", type: 1)
                }
            } else if(code < 500) {
                // Verifica o código HTTP retornado
                if(code == 404) {
                    // Mostra uma mensagem de erro específica para o usuário quando o código 404 é retornado
                    Utils.handleHTTPError(vc: self, code: code, msg: "Usuário não cadastrado, tente outro e-mail")
                }
                else {
                    // Mostra uma mensagem de erro genérica para o usuário quando um código HTTP entre 400 e 499 é retornado
                    Utils.handleHTTPError(vc: self, code: code, msg: "Não foi possível completar sua requisição, tente novamente mais tarde")
                }
            }
        }
    }
    
    // Função chamada quando a requisição HTTP falha
    func onError(code: Int, error: Error, source: String) {
        DispatchQueue.main.async {
            // Habilita o botão de entrar novamente
            self.enter_btn.isEnabled = true
            
            // Limpa a senha salva
            Settings.upswd = ""
            
            // Imprime o erro no console (comentado)
            //print(error)
            
            // Mostra uma mensagem de erro genérica para o usuário
            Utils.handleHTTPError(vc: self, code: code, msg: "Não foi possível completar sua requisição, tente novamente mais tarde")
        }
    }
    
}
