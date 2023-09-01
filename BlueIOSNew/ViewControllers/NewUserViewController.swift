//
//  NewUserViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import DCKit

class NewUserViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var name_edt: UITextField!
    @IBOutlet weak var email_edt: UITextField!
    @IBOutlet weak var register_btn: DCBorderedButton!
    @IBOutlet weak var cancel_btn: DCBorderedButton!
    @IBOutlet weak var msg_height: DCBaseLabel!
    @IBOutlet weak var bathtubimage: UIImageView!
    
    private let realmDB = RealmDB.it
    private var addedUser: User? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cria um gradiente com as 3 cores desejadas
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor, UIColor(red: 102/255, green: 148/255, blue: 250/255, alpha: 1).cgColor, UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor]
        
        // Define o plano de fundo da view com o gradiente
        view.layer.insertSublayer(gradientLayer, at: 0)
        
//        // Configura o campo do nome
//        name_edt.layer.cornerRadius = 10.0
//        name_edt.layer.masksToBounds = true
//        name_edt.backgroundColor = UIColor.clear
//        name_edt.layer.borderColor = UIColor.white.cgColor
//        name_edt.layer.borderWidth = 2
//        name_edt.textColor = UIColor.white
//        
//        // Configura o campo do email
//        email_edt.layer.cornerRadius = 10.0
//        email_edt.layer.masksToBounds = true
//        email_edt.backgroundColor = UIColor.clear
//        email_edt.layer.borderColor = UIColor.white.cgColor
//        email_edt.layer.borderWidth = 2
//        email_edt.textColor = UIColor.white
//        
//        name_edt.delegate = self
//        email_edt.delegate = self
//        
        msg_height.isHidden = true
        bathtubimage.isHidden = false
        
        applyGradient(to: cancel_btn)
        applyGradient(to: register_btn)
        
        // Adiciona a ação de botão para voltar para a primeira tela
        cancel_btn.addTarget(self, action: #selector(goToFirstScreen), for: .touchUpInside)
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
    
    @IBAction func registerClick(_ sender: Any) {
        guard isValidName(name_edt.text!) else {
            return
        }

        guard isValidEmail(email_edt.text!) else {
            return
        }

        addedUser = User()
        addedUser!.name = name_edt.text!
        addedUser!.email = email_edt.text!

        RequestManager.it.addUserResquest(user: addedUser!, delegate: self)
        register_btn.isEnabled = false
        cancel_btn.isEnabled = false
        
    }
    
    @IBAction func cancelClick(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func goToFirstScreen() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       let nextTag = textField.tag + 1
       // Try to find next responder
       let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder?
        
        if manageFieldContents(tag: textField.tag) {
           if nextResponder != nil {
               // Found next responder, so set it
               nextResponder?.becomeFirstResponder()
           } else {
               // Not found, so remove keyboard
               textField.resignFirstResponder()
           }
        }

       return false
   }
    
    private func manageFieldContents(tag: Int) -> Bool {
        // Name field
        if(tag == 1) {
            return isValidName(name_edt.text!)
        }
        // Email field
        if(tag == 2) {
            return isValidEmail(email_edt.text!)
        }
        return false
    }
    
    private func isValidName(_ name: String) -> Bool {
        if(name_edt.text!.isEmpty || name_edt.text!.count < 4) {
            Utils.toast(vc: self, message: "Nome muito curto, tente digitar um nome um pouco mais completo", type: 2)
            name_edt.textColor = UIColor.init(named: "red_color")
            return false
        } else {
            name_edt.textColor = UIColor.init(named: "title_color")
            return true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let regex_ok = emailPred.evaluate(with: email)
        
        if(!regex_ok) {
            Utils.toast(vc: self, message: "E-mail inválido, digite um e-mail válido", type: 2)
            email_edt.textColor = UIColor.init(named: "red_color")
            return false
        } else {
            email_edt.textColor = UIColor.init(named: "title_color")
            return true
        }
    }
    
}

extension NewUserViewController: RequestProtocol {
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) {
        DispatchQueue.main.async {
            self.register_btn.isEnabled = true
            self.cancel_btn.isEnabled = true
            if(code < 400) {
                Utils.toast(vc: self, message: "E-mail enviado com sucesso", type: 1)
                self.msg_height.isHidden = false
                self.bathtubimage.isHidden = true
                return
            } else if(code < 500) {
                Utils.toast(vc: self, message: "Usuário já cadastrado no sistema", type: 0)
                return
            } else {
                Utils.handleHTTPError(vc: self, code: code, msg: "Não foi possível enviar o e-mail, tente novamente mais tarde")
            }
            
            Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { (timer) in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func onError(code: Int, error: Error, source: String) {
        DispatchQueue.main.async {
            //print(error)
            Utils.handleHTTPError(vc: self, code: code, msg: "Não foi possível enviar o e-mail, tente novamente mais tarde")
            
            Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { (timer) in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
