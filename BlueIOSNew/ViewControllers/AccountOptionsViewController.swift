import UIKit
import DCKit

class AccountOptionsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var edtName: UITextField!
    @IBOutlet private weak var edtCurrPswd: UITextField!
    @IBOutlet private weak var edtNewPswd1: UITextField!
    @IBOutlet private weak var edtNewPswd2: UITextField!
    @IBOutlet private weak var btnSave: DCBorderedButton!
    @IBOutlet private weak var btnLogoff: DCBorderedButton!
    @IBOutlet private weak var btnDeleteAcc: DCBorderedButton!
    @IBOutlet private weak var btnBack: DCBorderedButton!
    @IBOutlet private weak var versionTxt: UILabel!
    
    // MARK: - Properties
    private lazy var logoffLongPress: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(logoff))
        gesture.minimumPressDuration = 0.8
        return gesture
    }()
    
    private lazy var deleteLongPress: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteAccount))
        gesture.minimumPressDuration = 0.8
        return gesture
    }()
    
    private var password = ""
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupVersionLabel()
        setupGradientBackground()
        setupButtons()
        setupTextFields()
        edtName.text = Settings.uname
    }
    
    private func setupVersionLabel() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionTxt.text = "Versão: \(version)"
        }
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor,
            UIColor(red: 102/255, green: 148/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupButtons() {
        [btnSave, btnLogoff].forEach(applyGradient)
    }
    
    private func setupTextFields() {
        [edtName, edtCurrPswd, edtNewPswd1, edtNewPswd2].forEach { textField in
            textField?.layer.cornerRadius = 15.0
            textField?.layer.masksToBounds = true
            textField?.backgroundColor = .clear
            textField?.layer.borderColor = UIColor.lightGray.cgColor
            textField?.layer.borderWidth = 1
            textField?.textColor = .white
        }
    }
    
    private func setupGestureRecognizers() {
        btnLogoff.addGestureRecognizer(logoffLongPress)
        btnDeleteAcc.addGestureRecognizer(deleteLongPress)
    }
    
    // MARK: - Helper Methods
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
    
    private func btnCtrl(enabled: Bool) {
        [btnSave, btnLogoff].forEach { $0?.isEnabled = enabled }
    }
    
    private func backToLogin() {
        navigationController?.popToViewController((navigationController?.viewControllers[1])!, animated: true)
    }
    
    // MARK: - Actions
    @objc private func logoff() {
        guard logoffLongPress.state == .ended else { return }
        btnCtrl(enabled: false)
        RequestManager.it.logoutRequest(delegate: nil)
        Settings.logout()
        backToLogin()
    }
    
    @objc private func deleteAccount() {
        guard deleteLongPress.state == .ended else { return }
        btnCtrl(enabled: false)
        RequestManager.it.deleteUserRequest(delegate: self)
    }
    
    @IBAction func saveChangesClick(_ sender: Any) {
        guard validateInputs() else { return }
        btnCtrl(enabled: false)
        RequestManager.it.updateUserRequest(name: edtName.text, password: edtNewPswd1.text, delegate: self)
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
    
    // MARK: - Validation Methods
    private func validateInputs() -> Bool {
        if let name = edtName.text, !name.isEmpty {
            guard isValidName(name) else { return false }
            Settings.uname = name
            password = Settings.upswd
        }
        
        if let pswd1 = edtNewPswd1.text, !pswd1.isEmpty {
            guard isValidPswd1(pswd1) else { return false }
            
            if let pswd2 = edtNewPswd2.text, !pswd2.isEmpty {
                guard isValidPswd2(pswd2) else { return false }
                password = pswd1
            }
            
            if Settings.upswd != edtCurrPswd.text {
                password = ""
                Utils.toast(vc: self, message: "Senha atual está incorreta", type: 2)
                return false
            }
        }
        
        return true
    }
    
    private func isValidName(_ name: String) -> Bool {
        guard name.count >= 4 else {
            Utils.toast(vc: self, message: "Nome muito curto, tente digitar um nome um pouco mais completo", type: 2)
            edtName.textColor = UIColor(named: "red_color")
            return false
        }
        edtName.textColor = UIColor(named: "title_color")
        return true
    }
    
    private func isValidPswd1(_ pswd1: String) -> Bool {
        guard pswd1.count >= 6 else {
            Utils.toast(vc: self, message: "A senha deve conter no mínimo 6 dígitos", type: 2)
            edtNewPswd1.textColor = UIColor(named: "red_color")
            return false
        }
        edtNewPswd1.textColor = UIColor(named: "title_color")
        return true
    }
    
    private func isValidPswd2(_ pswd2: String) -> Bool {
        guard edtNewPswd1.text == pswd2 else {
            Utils.toast(vc: self, message: "As senhas não correspondem", type: 2)
            edtNewPswd2.textColor = UIColor(named: "red_color")
            return false
        }
        edtNewPswd2.textColor = UIColor(named: "title_color")
        return true
    }
}

// MARK: - RequestProtocol Extension
extension AccountOptionsViewController: RequestProtocol {
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) {
        DispatchQueue.main.async {
            self.btnCtrl(enabled: true)
            
            if code < 400 {
                switch source {
                case "PUT_USER":
                    self.handlePutUserSuccess()
                case "DELETE_USER":
                    self.handleDeleteUserSuccess()
                default:
                    break
                }
            } else if code < 500 {
                self.handleClientError(code)
            }
        }
    }
    
    func onError(code: Int, error: Error, source: String) {
        DispatchQueue.main.async {
            self.password = ""
            self.btnCtrl(enabled: true)
            Utils.handleHTTPError(vc: self, code: code, msg: "Não foi possível completar sua requisição, tente novamente mais tarde")
        }
    }
    
    private func handlePutUserSuccess() {
        if !self.password.isEmpty {
            Settings.saveLoggedUser(email: Settings.uemail, pswd: self.password, name: Settings.uname)
            self.password = ""
        }
        Utils.toast(vc: self, message: "Alterações salvas com sucesso", type: 1)
        Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func handleDeleteUserSuccess() {
        Utils.toast(vc: self, message: "Conta deletada com sucesso", type: 1)
        Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
            Settings.logout()
            self.backToLogin()
        }
    }
    
    private func handleClientError(_ code: Int) {
        self.password = ""
        if code == 401 {
            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
        Utils.handleHTTPError(vc: self, code: code, msg: "Não foi possível completar sua requisição, tente novamente mais tarde")
    }
}
