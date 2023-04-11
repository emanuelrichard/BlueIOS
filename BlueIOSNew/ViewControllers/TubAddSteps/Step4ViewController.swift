//
//  Step4ViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit

class Step4ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tubname_edt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tubname_edt.delegate = self
        tubname_edt.smartInsertDeleteType = UITextSmartInsertDeleteType.no
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 25
    }

}
