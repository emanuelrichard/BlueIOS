//
//  TubListViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit
import DCKit
import CoreLocation
import SystemConfiguration.CaptiveNetwork
import NetworkExtension

class TubListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ATubLayoutDelegate {
    
    //var locationManager = CLLocationManager()
    var locationManger: CLLocationManager?
    
    @IBOutlet weak var viwQRCode: DCBorderedView!
    @IBOutlet weak var viwQRScan: QRScannerView!
    @IBOutlet weak var txtAddedTitle: UILabel!
    @IBOutlet weak var lstTubs: UICollectionView!
    @IBOutlet weak var btnAccOptions: UIButton!
    @IBOutlet weak var btnAppSettings: UIButton!
    @IBOutlet weak var viwLoading: UIView?
    @IBOutlet weak var configBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var view_tool_bar: UIView!
    @IBOutlet weak var logo_bar: UIImageView!
    @IBOutlet weak var view_botton_menu: UIView!
    @IBOutlet weak var view_bath_tub: UIView!
    @IBOutlet weak var view_bath_tub_bodder: UIView!
    
    private var added_lst: [Tub] = []
    private var shouldShowConn: [Int] = []
    private var selected = -1
    private var autocon = true
    private let sectionInsets = UIEdgeInsets(
      top: 10.0,
      left: 10.0,
      bottom: 10.0,
      right: 10.0)
    
    private var mTimer: Timer?
    private var scanCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ajuste de layout
        layoutTubList()
        
        // Assume responses in QRCode scans
        viwQRScan.delegate = self
        
        // Init tubs list
        if let layout = lstTubs.collectionViewLayout as? ATubViewLayout {
            layout.delegate = self
        }
        lstTubs.delegate = self
        lstTubs.dataSource = self
        
        // Assume responses of Services
        BLEService.it.delegates(ble: self, conn: self, comm: nil).ok()
        WiFiService.it.delegates(conn: self, comm: nil).ok()
        MqttService.it.delegates(conn: self, comm: nil).ok()
        
        // Loading setup
        loading(show: !Settings.favorite.isEmpty && autocon)
        
        startLocationManager()
        getAndPrintSSID()
    }

    func startLocationManager() {
        // Verifica se o locationManger já foi criado
        guard locationManger == nil else {
            // Se já existir, solicita permissão para acessar a localização em uso
            locationManger?.requestWhenInUseAuthorization()
            
            // Inicia a atualização da localização
            locationManger?.startUpdatingLocation()
            return
        }
        
        // Se locationManger não existe, cria uma nova instância
        locationManger = CLLocationManager()
        
        // Define o delegado (responsável por receber atualizações de localização) como o próprio objeto que possui esse método
        locationManger?.delegate = self
        
        // Define a precisão desejada para a localização (neste caso, precisão de um quilômetro)
        locationManger?.desiredAccuracy = kCLLocationAccuracyKilometer
        
        // Solicita permissão para acessar a localização em uso
        locationManger?.requestWhenInUseAuthorization()
        
        // Inicia a atualização da localização
        locationManger?.startUpdatingLocation()
    }

    func getAndPrintSSID() {
        NEHotspotNetwork.fetchCurrent { network in
            guard let ssid = network?.ssid else {
                print("Não foi possível obter o SSID da rede PO")
                return
            }
            print("SSID: \(ssid)")
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        // Cancel QoS
        CommandQoS.stopQoS()
        
        // Check user is logged in
        if(Settings.uemail.isEmpty) {
            navigationController?.popToRootViewController(animated: true)
        }
        
        // Assume responses of Services
        BLEService.it.delegates(ble: self, conn: self, comm: nil).ok()
        WiFiService.it.delegates(conn: self, comm: nil).ok()
        MqttService.it.delegates(conn: self, comm: nil).ok()
        
        // Database loading
        refreshTubList()
        
        // Server loading
        RequestManager.it.loadTubRequest(delegate: self)
        
        // Init update timer
        mTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] (timer) in
            scanCounter += 1
            //print("scanCounter: \(scanCounter)")
            if(scanCounter == 1) {
                BLEService.it.startScan()
            }
            if(scanCounter == 3) {
                BLEService.it.stopScan()
                lstTubs.reloadData()
            }
            if(scanCounter == 20) {
                RequestManager.it.loadTubRequest(delegate: self)
                shouldShowConn.removeAll()
                scanCounter = 0
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        saveTubs(tubs: nil)
        mTimer?.invalidate()
    }
    
    @IBAction func QRTubClick(_ sender: Any) {
        viwQRCode.isHidden = false
        viwQRCode.isUserInteractionEnabled = true
        viwQRScan.startScanning()
    }
    
    @IBAction func QRCancel(_ sender: Any) {
        viwQRScan.stopScanning()
    }
    
    @IBAction func AddTubClick(_ sender: Any) {
        if(BLEService.it.ble_enabled == true) {
            performSegue(withIdentifier: "TubAdd", sender: nil)
        } else {
            Utils.toast(vc: self, message: "Ligue o Bluetooth e tente novamente!")
        }
    }
    
    // Lista de opcaos
    @IBAction func configBtnClick(_ sender: UIButton) {
        let alert = UIAlertController(title: "Opções", message: "Escolha uma das opções:", preferredStyle: .actionSheet)
        
        // Adiciona opções na lista de opções
        alert.addAction(UIAlertAction(title: "Configuração de conta", style: .default, handler: { [self] _ in
            // Código para lidar com a seleção da opção 1
            
            performSegue(withIdentifier: "AConfig", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "QRCode", style: .default, handler: { [self] _ in
            // Código para lidar com a seleção da opção 2
            viwQRCode.isHidden = false
            viwQRCode.isUserInteractionEnabled = true
            viwQRScan.startScanning()
        }))
        
        alert.addAction(UIAlertAction(title: "Configuração de notificação", style: .default, handler: { [self] _ in
            // Código para lidar com a seleção da opção 3
            performSegue(withIdentifier: "AConfigNotif", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        // Configura o popoverPresentationController para iPad
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        // Exibe a lista de opções
        present(alert, animated: true, completion: nil)
    }
    
    func loading(show: Bool) {
        viwLoading?.isHidden = show
        viwLoading?.isUserInteractionEnabled = show
    }
    
    // Método que retorna a quantidade de itens na seção da collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return added_lst.count
    }

    // Método que retorna a altura da célula para um determinado indexPath
    func collectionView(
    _ collectionView: UICollectionView,
    heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat {
        // Obtém a largura da célula, que é baseada na largura da lista de tubos
        let h = lstTubs.frame.width
        // Chama o método privado estimateHeight para obter a altura estimada da célula
        return estimateHeight(ref: h, for: indexPath.row)
    }
    
    // Método privado que estima a altura da célula com base na largura de referência e no índice da linha
    private func estimateHeight(ref: CGFloat, for row: Int) -> CGFloat {
        // Inicializa a variável total com zero
        var total: CGFloat = 0
        // Obtém o nome do tubo da lista de tubos e calcula a largura da célula
        let tubname = added_lst[row].tub_name
        let w_cell = (ref/2) - 32

        // Adiciona a altura do texto do nome do tubo à variável total, levando em consideração a largura da célula
        let sz_text = tubname.size(withAttributes:[.font: UIFont.systemFont(ofSize: 17.0, weight: .bold)])
        total += 120
        total += w_cell <= sz_text.width ? (sz_text.height+8) * 2 : (sz_text.height+8)

        // Adiciona a altura das margens superior e inferior da célula
        total += 40

        // Adiciona a altura do botão de conexão, se o índice da linha estiver contido no array shouldShowConn
        total += shouldShowConn.contains(row) ? 40 : 0
        
        // Retorna a altura total estimada da célula
        return total
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ATub", for: indexPath) as! ATubViewCell
        
        
        // View principal da célula
        cell.layout_celula_view.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(cell.layout_celula_view)

        // Configurar gradienteLayer com altura adicional na parte inferior
        let gradientLayer = CAGradientLayer()
        let gradientFrame = CGRect(x: 0, y: 0, width: cell.layout_celula_view.bounds.width, height: cell.layout_celula_view.bounds.height + 40)
        gradientLayer.frame = gradientFrame

        gradientLayer.colors = [
            UIColor(red: 0, green: 0.2, blue: 0.4, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 0.4, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        cell.layout_celula_view.layer.addSublayer(gradientLayer)

            
        
        cell.layout_celula_view.layer.cornerRadius = 30
        cell.layout_celula_view.layer.borderWidth = 4
        cell.layout_celula_view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0.4, alpha: 1).cgColor


        NSLayoutConstraint.activate([
            cell.layout_celula_view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            cell.layout_celula_view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            cell.layout_celula_view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            cell.layout_celula_view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
        ])
        
        //Logo banheira da celula
        cell.logo_tub.translatesAutoresizingMaskIntoConstraints = false
        cell.layout_celula_view.addSubview(cell.logo_tub)
        
        cell.logo_tub.contentMode = .center
        cell.logo_tub.clipsToBounds = true
        
        cell.logo_tub.widthAnchor.constraint(equalToConstant: 80).isActive = true
        cell.logo_tub.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        //let logo = UIImage(named: "bathtub")
        //cell.logo_tub.image = logo
        cell.logo_tub.contentMode = .scaleAspectFit
        
        cell.logo_tub.topAnchor.constraint(equalTo: cell.layout_celula_view.topAnchor, constant: 10).isActive = true
        cell.logo_tub.centerXAnchor.constraint(equalTo: cell.layout_celula_view.centerXAnchor).isActive = true
        
        
        //Nome da banheira
        cell.tubname_txt.translatesAutoresizingMaskIntoConstraints = false
        cell.layout_celula_view.addSubview(cell.tubname_txt)
        
        cell.tubname_txt.contentMode = .center
        cell.tubname_txt.clipsToBounds = true
        cell.tubname_txt.textColor = .white


        //cell.tubname_txt.topAnchor.constraint(equalTo: cell.logo_tub.bottomAnchor, constant: 5).isActive = true
        cell.tubname_txt.centerXAnchor.constraint(equalTo: cell.layout_celula_view.centerXAnchor).isActive = true
        cell.tubname_txt.centerYAnchor.constraint(equalTo: cell.layout_celula_view.centerYAnchor).isActive = true
        
        //Dual button
        cell.stack_view.translatesAutoresizingMaskIntoConstraints = false
        cell.layout_celula_view.addSubview(cell.stack_view)
        
        cell.stack_view.widthAnchor.constraint(equalToConstant: 120).isActive = true
        cell.stack_view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        cell.stack_view.topAnchor.constraint(equalTo: cell.tubname_txt.bottomAnchor, constant: 10).isActive = true
        cell.stack_view.centerXAnchor.constraint(equalTo: cell.layout_celula_view.centerXAnchor).isActive = true
        
        //button conexao
        cell.conn_btn.translatesAutoresizingMaskIntoConstraints = false
        cell.stack_view.addSubview(cell.conn_btn)

        //button delete
        cell.del_btn.translatesAutoresizingMaskIntoConstraints = false
        cell.stack_view.addSubview(cell.del_btn)

        NSLayoutConstraint.activate([
            cell.conn_btn.leadingAnchor.constraint(equalTo: cell.stack_view.leadingAnchor),
            cell.del_btn.trailingAnchor.constraint(equalTo: cell.stack_view.trailingAnchor),
            cell.conn_btn.topAnchor.constraint(equalTo: cell.stack_view.topAnchor),
            cell.del_btn.topAnchor.constraint(equalTo: cell.stack_view.topAnchor)
        ])
        
        //Tipos de conexoes view
        cell.conn_viw.translatesAutoresizingMaskIntoConstraints = false
        cell.layout_celula_view.addSubview(cell.conn_viw)
        
        cell.conn_viw.widthAnchor.constraint(equalToConstant: 140).isActive = true

        cell.conn_viw.bottomAnchor.constraint(equalTo: cell.layout_celula_view.bottomAnchor, constant: -20).isActive = true
        cell.conn_viw.centerXAnchor.constraint(equalTo: cell.layout_celula_view.centerXAnchor).isActive = true
        
        
        let tub = added_lst[indexPath.row]
        cell.tubname_txt.text = tub.tub_name

        let ble_up = BLEService.it.ble_enabled &&
        BLEService.it.discoveredPeripherals.contains(where: { $0.name == tub.BTid })
        cell.ble_ico.tintColor = ble_up == true ? UIColor.init(named: "Conection_ON") : UIColor.init(named: "Conection_OFF")

        let wifi_up = tub.wifi_state == "2" &&
            Utils.getWiFiNetworkName() != nil &&
            Utils.getWiFiNetworkName() == tub.ssid
        cell.wifi_ico.tintColor = wifi_up == true ? UIColor.init(named: "Conection_ON") : UIColor.init(named: "Conection_OFF")

        let mqtt_up = tub.mqtt_state == "1" &&
            tub.online &&
            Utils.isNetworkReachable()
        cell.mqtt_ico.tintColor = mqtt_up == true ? UIColor.init(named: "Conection_ON") : UIColor.init(named: "Conection_OFF")
        
        cell.conn_btn.tintColor = ble_up || wifi_up || mqtt_up ? UIColor.init(named: "Conection_ON") : UIColor.init(named: "Conection_OFF")
        
        cell.conn_hgt.constant = shouldShowConn.contains(indexPath.row) ? 32 : 0

        cell.conn_btn.tag = indexPath.row
        cell.conn_btn.addTarget(self, action: #selector(showTubConn), for: .touchUpInside)
        
        let is_fav = Settings.favorite == tub.BTid
        _ = is_fav ? #imageLiteral(resourceName: "star_on") : #imageLiteral(resourceName: "star_off")
        if(is_fav && autocon) {
            autocon = false
            selected = indexPath.row
            _ = connect(sel_tub: tub)
        }
        //cell.fav_btn.setImage(fav_ico, for: .normal)
        //cell.fav_btn.tag = indexPath.row
        //cell.fav_btn.addTarget(self, action: #selector(favoriteTub), for: .touchUpInside)
        
        cell.del_btn.tag = indexPath.row
        cell.del_btn.addTarget(self, action: #selector(deleteTub), for: .touchUpInside)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(lstAddedLongPress))
        cell.del_btn.addGestureRecognizer(longPressGesture)
            
        // Configurando as tags dos ícones BLE, WiFi e MQTT da célula de acordo com o índice da linha da tabela
        cell.ble_ico.tag = (indexPath.row+1) * 17
        cell.wifi_ico.tag = (indexPath.row+1) * 19
        cell.mqtt_ico.tag = (indexPath.row+1) * 23

        // Adicionando um alvo para cada ícone que executará o método 'forceConnect' quando for tocado
        cell.ble_ico.addTarget(self, action: #selector(forceConnect), for: .touchUpInside)
        cell.wifi_ico.addTarget(self, action: #selector(forceConnect), for: .touchUpInside)
        cell.mqtt_ico.addTarget(self, action: #selector(forceConnect), for: .touchUpInside)
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        selected = indexPath.row
        let sel_tub = added_lst[selected]
        
        print("AQUIIIIII \(added_lst[selected])")
        
        Utils.disconnect()

        return connect(sel_tub: sel_tub)
    }
    
    private func connect(sel_tub: Tub, force: Int = -1) -> Bool {
        Settings.tubname = sel_tub.tub_name
        Settings.tub_pswd1 = sel_tub.tub_pswd1
        Settings.BTid = sel_tub.BTid
        
        let mqtt_up = sel_tub.mqtt_state == "1" &&
            sel_tub.online &&
            Utils.isNetworkReachable()
        if(force < 0 || force == 2){
            if(mqtt_up) {
                if let tubid = Utils.getMqttId(pub: sel_tub.mqtt_pub, sub: sel_tub.mqtt_sub) {
                    MqttService.it.connect(BTid: sel_tub.BTid, tubid: tubid)
                    print("BTID = \(sel_tub.BTid)")
                    //viwLoading?.backgroundColor = UIColor.cyan
                    autocon = false
                    return true
                }
            }
        }
        
        let ble_up = BLEService.it.ble_enabled &&
        BLEService.it.discoveredPeripherals.contains(where: { $0.name == sel_tub.BTid })
        if(force < 0 || force == 0) {
            if(ble_up) {
                BLEService.it.connect(BTid: sel_tub.BTid)
                print("BTID = \(sel_tub.BTid)")
                //viwLoading.backgroundColor = UIColor.red
                autocon = false
                return true
            }
        }

        let wifi_up = sel_tub.wifi_state == "2" &&
            Utils.getWiFiNetworkName() != nil &&
            Utils.getWiFiNetworkName() == sel_tub.ssid
        if(force < 0 || force == 1) {
            if(wifi_up) {
                //viwLoading.backgroundColor = UIColor.green
                WiFiService.it.setNetwork(BTid: sel_tub.BTid, ip: sel_tub.ip).connect()
                autocon = false
                return true
            }
        }
        
        selected = -1
        Settings.resetAll()
        Utils.toast(vc: self, message: "A banheira \(sel_tub.tub_name) parece estar fora de alcance no momento")
        return false
    }

    @objc func lstAddedLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: lstTubs)
        let indexPath = lstTubs.indexPathForItem(at: p)
        if indexPath == nil {
            return
        } else if longPressGesture.state == UIGestureRecognizer.State.ended {
            RequestManager.it.deleteTubRequest(tub_id: added_lst[indexPath!.row].BTid, delegate: self)
            
            if let db = RealmDB.it {
                do {
                    try db.write {
                        let mac = added_lst[indexPath!.row].mqtt_sub
                        db.delete(added_lst[indexPath!.row])
                        
                        added_lst.remove(at: indexPath!.row)
                        
                        Notifications.unsubscribeToRemoteNotifications(topic: Utils.getMqttId(pub: mac, sub: mac) ?? "")
                        
                        Utils.toast(vc: self, message: "Banheira deletada com sucesso!", type: 1)
                        
                        refreshTubList()
                    }
                } catch { }
            } else {
                Utils.toast(vc: self, message: "Erro ao deletar banheira", type: 2)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "TubAdd") {
            if let nextVC = segue.destination as? TubAddViewController {
                nextVC.delegate = self
            }
            return
        }
        if(segue.identifier == "AccOpt") {
            return
        }
    }
    
    @objc func favoriteTub(sender: UIButton) {
        autocon = false
        let BTid = added_lst[sender.tag].BTid
        let fav = Settings.favorite != BTid ? BTid : ""
        Settings.saveFavTub(BT_id: fav)
        refreshTubList(reloadTubs: false)
    }
    
    @objc func showTubConn(sender: UIButton) {
        if(!shouldShowConn.contains(sender.tag)) {
            shouldShowConn.append(sender.tag)
        } else {
            shouldShowConn.removeAll(where: { $0 == sender.tag })
        }
        refreshTubList(reloadTubs: false)
    }
    
    @objc func forceConnect(sender: UIButton) {
        let tag = sender.tag
        if(tag % 17 == 0) {
            selected = (tag/17) - 1
            _ = connect(sel_tub: added_lst[selected], force: 0)
            return
        }
        if(tag % 19 == 0) {
            selected = (tag/19) - 1
            _ = connect(sel_tub: added_lst[selected], force: 1)
            return
        }
        if(tag % 23 == 0) {
            selected = (tag/23) - 1
            _ = connect(sel_tub: added_lst[selected], force: 2)
        }
    }
    
    @objc func deleteTub(sender: UIButton) {
        Utils.toast(vc: self, message: "Segure o botão para confirmar a exclusão")
    }
    
    private func saveTubs(tubs: [Tub]?) {
        if let db = RealmDB.it {
            do {
                try db.write {
                    if let t = tubs {
                        db.add(t, update: .modified)
                    } else {
                        db.add(added_lst, update: .modified)
                    }
                }
            } catch { }
        }
    }
    
    private func refreshTubList(reloadTubs: Bool = true) {
        if(reloadTubs) {
            added_lst.removeAll()
            if let db = RealmDB.it {
                let tubs = db.objects(Tub.self)
                added_lst.append(contentsOf: tubs)
            }
            
            if(added_lst.isEmpty) {
                txtAddedTitle.text = "Não há banheiras adicionadas.\nPara adicionar uma banheira, utilize os botões abaixo."
            } else {
                txtAddedTitle.text = "Selecione a banheira que deseja conectar-se"
            }
        }
        
        lstTubs.reloadData()
    }
    
    private func layoutTubList(){
        // Cria um gradiente com as 3 cores desejadas
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor,
                                UIColor(red: 93/255, green: 143/255, blue: 250/255, alpha: 1).cgColor,
                                UIColor(red: 39/255, green: 54/255, blue: 131/255, alpha: 1).cgColor]
        
        // Define o plano de fundo da view com o gradiente
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.bringSubviewToFront(viwQRCode)

        
        //ToolBar View
        view_tool_bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(view_tool_bar)
        let guide = view.safeAreaLayoutGuide

        
        NSLayoutConstraint.activate([
            view_tool_bar.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            view_tool_bar.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            view_tool_bar.topAnchor.constraint(equalTo: guide.topAnchor),
            view_tool_bar.heightAnchor.constraint(equalToConstant: 44.0),
            view_tool_bar.widthAnchor.constraint(equalToConstant: 50.0)
        ])
        
        //Logo dentro da view toolbar
        logo_bar.translatesAutoresizingMaskIntoConstraints = false
        view_tool_bar.addSubview(logo_bar)
        
        NSLayoutConstraint.activate([
            logo_bar.widthAnchor.constraint(equalToConstant: 50.0),
            logo_bar.heightAnchor.constraint(equalToConstant: 50.0),
            logo_bar.centerXAnchor.constraint(equalTo: view_tool_bar.centerXAnchor),
            logo_bar.centerYAnchor.constraint(equalTo: view_tool_bar.centerYAnchor),
        ])
        
        //Bunton Config dentro da view toolbar
        configBtn.translatesAutoresizingMaskIntoConstraints = false
        view_tool_bar.addSubview(configBtn)
        
        
        NSLayoutConstraint.activate([
            configBtn.centerYAnchor.constraint(equalTo: view_tool_bar.centerYAnchor),
            configBtn.trailingAnchor.constraint(equalTo: view_tool_bar.trailingAnchor),
        ])
        
        configBtn.setTitle("", for: .normal)
        
        //Configuracao do titulo
        txtAddedTitle.adjustsFontSizeToFitWidth = true
        txtAddedTitle.minimumScaleFactor = 1 // ou qualquer outro valor que desejar
        txtAddedTitle.textAlignment = .center
        
        txtAddedTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(txtAddedTitle)
        
        NSLayoutConstraint.activate([
            // Centralizar a label horizontalmente
            txtAddedTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // txt_email a parte superior da label com a parte inferior do texto email
            txtAddedTitle.topAnchor.constraint(equalTo: view_tool_bar.bottomAnchor),
        ])
        
        //View Botton Menu
        view_botton_menu.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(view_botton_menu)
        
        NSLayoutConstraint.activate([
            // Define a margem esquerda do objeto lstTubs para ser igual à margem esquerda da safe area
            view_botton_menu.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            // Define a margem direita do objeto lstTubs para ser igual à margem direita da safe area
            view_botton_menu.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Defina a margem inferior do lstTubs para ser igual à margem inferior da view
            view_botton_menu.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            // Adicione a restrição de altura à view
            view_botton_menu.heightAnchor.constraint(equalToConstant: 50.0),
        ])
        
        //Button add dentro da view botton menu
        // Desative a tradução automática das máscaras de layout
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addBtn)

        let buttonSize: CGFloat = 50.0

        NSLayoutConstraint.activate([
            addBtn.centerXAnchor.constraint(equalTo: view_botton_menu.centerXAnchor),
            addBtn.centerYAnchor.constraint(equalTo: view_botton_menu.centerYAnchor),
            addBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            addBtn.heightAnchor.constraint(equalToConstant: buttonSize)
        ])
        
        // List View
        lstTubs.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lstTubs)
        
        // Ativa as restrições de layout
        NSLayoutConstraint.activate([
            // Define a margem esquerda do objeto lstTubs para ser igual à margem esquerda da safe area
            lstTubs.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            // Define a margem direita do objeto lstTubs para ser igual à margem direita da safe area
            lstTubs.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Defina a margem superior do lstTubs para ser igual à margem superior da view
            lstTubs.topAnchor.constraint(equalTo: txtAddedTitle.bottomAnchor, constant: 20),
            // Defina a margem inferior do lstTubs para ser igual à margem inferior da view
            lstTubs.bottomAnchor.constraint(equalTo: view_botton_menu.topAnchor)
        ])
        

        
        view.addSubview(viwQRCode)
    }
    
}

extension TubListViewController: BluetoothLEProtocol, ConnectingProtocol, DataBackProtocol {
    func retrieveData(data: Any) {
        let tub = data as! Tub
        
        RequestManager.it.addTubRequest(tub: tub, delegate: self)
        
        saveTubs(tubs: [tub])
        refreshTubList()
        
        Settings.resetAll()
    }
    
    func didStartScan() {
        
    }
    
    func didFoundTub(BTid: String) {
        
    }
    
    func didStartConnectingTub() {
        if(selected == -1) { return }
        loading(show: true)
    }
    
    func didConnectTub() {
        if(selected == -1) {
            if(BLEService.it.state == Connection.State.CONNECTED) {
                BLEService.it.disconnect()
            }
        } else {
            performSegue(withIdentifier: "Connected", sender: nil)
            loading(show: false)
        }
        txtAddedTitle.text = "Selecione a banheira que deseja conectar-se"
        selected = -1
        
    }
    
    func didDisconnectTub() {
        loading(show: false)
        selected = -1
    }
    
    func didFail() {
        Utils.toast(vc: self, message: "A banheira parece estar fora de alcance no momento")
        loading(show: false)
        selected = -1
    }
}

extension TubListViewController: RequestProtocol {
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) {
        DispatchQueue.main.async {
            if(code < 400) {
                switch source {
                case "GET_TUB":
                    var updated: [Tub] = []
                    if(self.added_lst.isEmpty) {
                        for resp in response {
                            let tub = Tub()
                            tub.initFromDict(dict: resp)
                            updated.append(tub)
                        }
                    } else {
                        for resp in response {
                            for atub in self.added_lst {
                                if(resp["BTid"] as! String == atub.BTid) {
                                    let tub = Tub()
                                    tub.initFromDict(dict: resp)
                                    let dFormatter = ISO8601DateFormatter()
                                    dFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                                    let wtDate = dFormatter.date(from: tub.date) ?? Date()
                                    let ltDate = dFormatter.date(from: atub.date) ?? Date()
                                    //print("--- name: \(tub.tub_name)/ \(atub.date)~\(tub.date) - atual: \(ltDate) < nova: \(wtDate) = \(ltDate < wtDate)")
                                    if(ltDate < wtDate) {
                                        tub.tub_name = atub.tub_name
                                        updated.append(tub)
                                    } else {
                                        if let db = RealmDB.it {
                                            do {
                                                try db.write {
                                                    atub.online = tub.online
                                                }
                                            } catch { }
                                        }
                                        updated.append(atub)
                                    }
                                }
                            }
                        }
                    }
                    
                    self.saveTubs(tubs: updated)
                    self.refreshTubList()
                    
                    RequestManager.it.sendPendingRequest()
                case "POST_TUB":
                    break
                case "DELETE_TUB":
                    break
                default:
                    return
                }
            } else if(code < 500) {
                if(code == 401) {
                    Settings.logout()
                    
                    Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { (timer) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                Utils.handleHTTPError(vc: nil, code: code)
            }
        }
    }
    
    func onError(code: Int, error: Error, source: String) {
        DispatchQueue.main.async {
            //print(error)
            Utils.handleHTTPError(vc: nil, code: code)
        }
    }
    
}

extension TubListViewController: QRCodeProtocol {
    func qrScanningDidFail() {
        Utils.toast(vc: self, message: "Falha ao ler QRCode do BLUE", type: 2)
    }
    
    func qrScanningSucceededWithCode(_ str: String?) {
        guard str != nil else {
            return
        }
        
        if let tub = Tub.initFromString(tubstr: str!) {
            RequestManager.it.addTubRequest(tub: tub, delegate: self)
            
            saveTubs(tubs: [tub])
            refreshTubList()
            
            Utils.toast(vc: self, message: "Banheira remota adicionada com sucesso", type: 1)
            return
        }
        Utils.toast(vc: self, message: "QRCode lido não é um código válido", type: 2)
    }
    
    func qrScanningDidStop() {
        viwQRCode.isHidden = true
        viwQRCode.isUserInteractionEnabled = false
    }
}

extension TubListViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        if status == .authorizedWhenInUse {
            print("SSID: \(Utils.getWiFiNetworkName() ?? "SSID error")")
        } else {
            Utils.toast(vc: self, message: "Sem a permissão de localização, a conexão Wi-Fi não será detectada", type: 0)
        }
    }
}
