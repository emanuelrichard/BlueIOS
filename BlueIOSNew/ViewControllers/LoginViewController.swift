//
//  LoginViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import DCKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email_edt: UITextField!
    @IBOutlet weak var pswd_edt: UITextField!
    @IBOutlet weak var enter_btn: DCBorderedButton!
    
    private let realmDB = RealmDB.it
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Settings
        Settings.inititate()
        
        // Check for already logged users
        if(!Settings.uemail.isEmpty) {
            performSegue(withIdentifier: "Logged", sender: nil)
        }
        
        // Setup edit's delegates
        email_edt.delegate = self
        pswd_edt.delegate = self
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

extension LoginViewController: RequestProtocol {
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) {
        DispatchQueue.main.async {
            self.enter_btn.isEnabled = true
            self.pswd_edt.text = ""
            if(code < 400) {
                if(source == "POST_LOGIN") {
                    let login = response.first!
                    let name = login["name"] as! String
                    Settings.saveLoggedUser(email: Settings.uemail, pswd: Settings.upswd, name: name)
                    
                    self.performSegue(withIdentifier: "ALogged", sender: nil)
                } else if(source == "USER_FORGOT") {
                    Utils.toast(vc: self, message: "E-mail enviado com sucesso", type: 1)
                }
            } else if(code < 500) {
                if(code == 404) { Utils.handleHTTPError(vc: self, code: code, msg: "Usuário não cadastrado, tente outro e-mail") }
                else { Utils.handleHTTPError(vc: self, code: code, msg: "Não foi possível completar sua requisição, tente novamente mais tarde") }
            }
        }
    }
    
    func onError(code: Int, error: Error, source: String) {
        DispatchQueue.main.async {
            self.enter_btn.isEnabled = true
            Settings.upswd = ""
            //print(error)
            Utils.handleHTTPError(vc: self, code: code, msg: "Não foi possível completar sua requisição, tente novamente mais tarde")
        }
    }
    
}
