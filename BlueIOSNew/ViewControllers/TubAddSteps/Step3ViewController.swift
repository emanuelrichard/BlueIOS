//
//  Step3ViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit

class Step3ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tubpswd_edt: UITextField!
    @IBOutlet weak var connected_txt: UILabel!
    
    var restartSteps : (()-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tubpswd_edt.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func restartStepsClick(_ sender: Any) {
        restartSteps?()
    }
}
