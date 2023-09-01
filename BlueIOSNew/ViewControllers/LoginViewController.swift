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
        
        
        //BathTub Logo
//        bathtub_image.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(bathtub_image)
//
//        NSLayoutConstraint.activate([
//            bathtub_image.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            bathtub_image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//        ])
        
//        // Txt email
//        txt_email.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(txt_email)
//        txt_email.textAlignment = .center
//
//
//        NSLayoutConstraint.activate([
//            // Centralizar a label horizontalmente
//            txt_email.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            txt_email.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            // txt_email a parte superior da label com a parte superior da view_config_notific
//            //txt_email.topAnchor.constraint(equalTo: bathtub_image.bottomAnchor),
//            // Definir a largura máxima da label
//            txt_email.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            txt_email.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            // Alinhar a direita da label com a direita da view_config_notific
//            txt_email.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//
//        // Configura o campo do email
//        email_edt.layer.cornerRadius = 20.0
//        email_edt.layer.masksToBounds = true
//        email_edt.backgroundColor = UIColor.clear
//        email_edt.layer.borderColor = UIColor.white.cgColor
//        email_edt.layer.borderWidth = 1.5
//        email_edt.textColor = UIColor.white
//
//        email_edt.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(email_edt)
//
//        NSLayoutConstraint.activate([
//            // Centralizar a label horizontalmente
//            email_edt.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            // txt_email a parte superior da label com a parte inferior do texto email
//            email_edt.topAnchor.constraint(equalTo: txt_email.bottomAnchor, constant: 10),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            email_edt.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
//            // Alinhar a direita da label com a direita da view_config_notific
//            email_edt.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
//        ])
//
//        //Texto Senha
//        txt_senha.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(txt_senha)
//        txt_senha.textAlignment = .center
//
//
//        NSLayoutConstraint.activate([
//            // Centralizar a label horizontalmente
//            txt_senha.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            // txt_email a parte superior da label com a parte inferior do editor de texto email
//            txt_senha.topAnchor.constraint(equalTo: email_edt.bottomAnchor, constant: 20),
//            // Definir a largura máxima da label
//            txt_senha.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            txt_senha.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            // Alinhar a direita da label com a direita da view_config_notific
//            txt_senha.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//
//
//        // Configura o campo de senha
//        pswd_edt.layer.cornerRadius = 20.0
//        pswd_edt.layer.masksToBounds = true
//        pswd_edt.backgroundColor = UIColor.clear
//        pswd_edt.layer.borderColor = UIColor.white.cgColor
//        pswd_edt.layer.borderWidth = 1.5
//        pswd_edt.textColor = UIColor.white
//
//        pswd_edt.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(pswd_edt)
//
//        NSLayoutConstraint.activate([
//            // Centralizar a label horizontalmente
//            pswd_edt.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            // txt_email a parte superior da label com a parte inferior do texto email
//            pswd_edt.topAnchor.constraint(equalTo: txt_senha.bottomAnchor, constant: 10),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            pswd_edt.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
//            // Alinhar a direita da label com a direita da view_config_notific
//            pswd_edt.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
//        ])
//
//
//        // Layout butons
//
//        //Bunton Enter
//        enter_btn.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(enter_btn)
//
//
//        NSLayoutConstraint.activate([
//            // txt_email a parte superior da label com a parte superior da view_config_notific
//            enter_btn.topAnchor.constraint(equalTo: pswd_edt.bottomAnchor, constant: 50),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            enter_btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
//
//        ])
//
//        //Button Register
//        register_btn.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(register_btn)
//
//
//        NSLayoutConstraint.activate([
//            //register_btn.centerXAnchor.constraint(equalTo: enter_btn.centerXAnchor),
//            // txt_email a parte superior da label com a parte superior da view_config_notific
//            register_btn.topAnchor.constraint(equalTo: pswd_edt.bottomAnchor, constant: 50),
//            // Alinhar a esquerda da label com a esquerda da view_config_notific
//            register_btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
//
//        ])
        
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
