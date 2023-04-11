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
    @IBOutlet weak var msg_height: NSLayoutConstraint!
    
    private let realmDB = RealmDB.it
    private var addedUser: User? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name_edt.delegate = self
        email_edt.delegate = self
        
        msg_height.isActive = true
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
        navigationController?.popViewController(animated: true)
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
                self.msg_height.isActive = false
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
