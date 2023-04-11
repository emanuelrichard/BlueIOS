//
//  InstallationViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import DCKit

class InstallationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var form_viw: UIScrollView!
    @IBOutlet weak var pass_viw: DCBorderedView!
    
    @IBOutlet weak var installerName_edt: UITextField!
    @IBOutlet weak var installerDate_edt: UITextField!
    @IBOutlet weak var serialNumber_edt: UITextField!
    @IBOutlet weak var ownerName_edt: UITextField!
    @IBOutlet weak var ownerAddr_edt: UITextField!
    @IBOutlet weak var ownerNumber_edt: UITextField!
    @IBOutlet weak var onwerNeigb_edt: UITextField!
    @IBOutlet weak var ownerExtras_edt: UITextField!
    @IBOutlet weak var onwerCity_edt: UITextField!
    @IBOutlet weak var ownerState_edt: UITextField!
    @IBOutlet weak var ownerZip_edt: UITextField!
    
    @IBOutlet weak var submitForm_btn: DCBorderedButton!
    @IBOutlet weak var cancelForm_btn: DCBorderedButton!
    
    @IBOutlet weak var installerCode_edt: UITextField!
    @IBOutlet weak var installerOk_btn: DCBorderedButton!
    @IBOutlet weak var installerCancel_btn: DCBorderedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextFields()
        
        swapViews(showForm: false)
    }
    
    private func setupTextFields() {
        installerCode_edt.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        serialNumber_edt.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        ownerState_edt.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        ownerZip_edt.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        
        installerCode_edt.delegate = self
        installerName_edt.delegate = self
        installerDate_edt.delegate = self
        serialNumber_edt.delegate = self
        ownerName_edt.delegate = self
        ownerAddr_edt.delegate = self
        ownerNumber_edt.delegate = self
        onwerNeigb_edt.delegate = self
        ownerExtras_edt.delegate = self
        onwerCity_edt.delegate = self
        ownerState_edt.delegate = self
        ownerZip_edt.delegate = self
    }
    
    private func swapViews(showForm: Bool) {
        form_viw.isUserInteractionEnabled = showForm
        pass_viw.isHidden = showForm
        submitForm_btn.isEnabled = showForm
        cancelForm_btn.isEnabled = showForm
    }
    
    @IBAction func installerOkClick(_ sender: Any) {
        self.installerOk_btn.isEnabled = false
        self.installerOk_btn.setTitle("Aguarde...", for: .disabled)
        swapViews(showForm: true)
    }
    
    @IBAction func installerCancelClick(_ sender: Any) {
        if let code = installerCode_edt.text {
            if(code.count == 11) {
                navigationController?.popViewController(animated: true)
                return
            }
        }
        Utils.toast(vc: self, message: "Credenciais incorretas", type: 2)
    }
    
    @IBAction func submitFormClick(_ sender: Any) {
        var canSubmit = true
        
        let installer = installerName_edt.text ?? ""
        if(installer.isEmpty) { canSubmit = false }
        let date = installerDate_edt.text ?? ""
        if(date.isEmpty) { canSubmit = false }
        let serial = serialNumber_edt.text ?? ""
        if(serial.isEmpty) { canSubmit = false }
        let owner = ownerName_edt.text ?? ""
        if(owner.isEmpty) { canSubmit = false }
        let main = ownerAddr_edt.text ?? ""
        if(main.isEmpty) { canSubmit = false }
        let number = ownerNumber_edt.text ?? ""
        if(number.isEmpty) { canSubmit = false }
        let neighb = onwerNeigb_edt.text ?? ""
        if(neighb.isEmpty) { canSubmit = false }
        let extras = ownerExtras_edt.text ?? ""
        let city = onwerCity_edt.text ?? ""
        if(city.isEmpty) { canSubmit = false }
        let uf = ownerState_edt.text ?? ""
        if(uf.isEmpty) { canSubmit = false }
        let zip = ownerZip_edt.text ?? ""
        if(zip.isEmpty) { canSubmit = false }
        
        if(canSubmit) {
            let ownerAddr = getAddress(main: main, number: number, neighb: neighb, extras: extras, city: city, uf: uf, zip: zip)
            
            //TODO: Get coordinates
            
            self.submitForm_btn.isEnabled = true
            self.submitForm_btn.setTitle("Aguarde...", for: .disabled)
            
            //RequestManager.it.logoutRequest(delegate: self)
            self.performSegue(withIdentifier: "Config", sender: nil)
            
        } else {
            Utils.toast(vc: self, message: "Formulário incorreto, verifique os campos", type: 2)
        }
        self.performSegue(withIdentifier: "Config", sender: nil)
    }
    
    @IBAction func cancelFormClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func getAddress(main: String, number: String, neighb: String, extras: String, city: String, uf: String, zip: String) -> String {
        
        var address = ""
        address += "\(main), \(number)"
        if(!extras.isEmpty) { address += " - \(extras)" }
        address += " - \(neighb), \(city) - \(uf), \(zip)"
        return address
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        switch tag {
        case 1: installerDate_edt.becomeFirstResponder()
        case 2: serialNumber_edt.becomeFirstResponder()
        case 3: ownerName_edt.becomeFirstResponder()
        case 4: ownerAddr_edt.becomeFirstResponder()
        case 5: ownerNumber_edt.becomeFirstResponder()
        case 6: onwerNeigb_edt.becomeFirstResponder()
        case 7: ownerExtras_edt.becomeFirstResponder()
        case 8: onwerCity_edt.becomeFirstResponder()
        case 9: ownerState_edt.becomeFirstResponder()
        case 10: ownerZip_edt.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }

        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        switch textField.tag {
        case 0:
            return count <= 11
        case 3:
            return count <= 13
        case 10:
            return count <= 2
        case 11:
            return count <= 9
        default:
            return true
        }
        
    }
}

extension InstallationViewController: RequestProtocol {
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) {
        DispatchQueue.main.async {
            self.installerOk_btn.isEnabled = true
            self.installerOk_btn.setTitle("Prosseguir", for: .normal)
            self.installerOk_btn.isEnabled = true
            self.installerOk_btn.setTitle("Enviar dados", for: .normal)
            
            if(code < 400) {
                if(source == "GET_INSTLR"){
                    let instlr = response.first!
                    self.installerName_edt.text = instlr["installer_name"] as? String
                    self.installerDate_edt.text = self.getCurrentDate()
                    
                    self.swapViews(showForm: true)
                } else {
                    self.performSegue(withIdentifier: "Config", sender: nil)
                }
            } else if(code < 500) {
                Utils.handleHTTPError(vc: self, code: code)
            }
        }
    }
    
    func onError(code: Int, error: Error, source: String) {
        DispatchQueue.main.async {
            self.installerOk_btn.isEnabled = true
            self.installerOk_btn.setTitle("Prosseguir", for: .normal)
            self.installerOk_btn.isEnabled = true
            self.installerOk_btn.setTitle("Enviar dados", for: .normal)

            //print(error)
            Utils.handleHTTPError(vc: self, code: code)
        }
    }
    
}
