//
//  RequestManager.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation

class RequestManager {
    
    static let it = RequestManager()
    
    //private static let API_ADDRESS = "http://ec2-18-210-17-121.compute-1.amazonaws.com:8090/api/"
    //private let API_ADDRESS = "http://blueeasy-102203163.sa-east-1.elb.amazonaws.com/api/"
    private let API_ADDRESS = "https://server.opportunitysys.com.br/api/"
    
    private var delegate: RequestProtocol? = nil
    
    var resending = false
    
    // MARK: Health Check Request
    func healthCheckRequest(delegate: RequestProtocol?) {
        self.delegate = delegate
        
        let request = requestBuilder(route: "test", method: "GET", body: nil)
        performRequest(it: request, source: "GET_HEALTH", obj_id: "")
    }
    
    // MARK: Login Requests
    func loginRequest(email: String, pswd: String, delegate: RequestProtocol?) {
        self.delegate = delegate
        
        let params = ["email": email, "password": pswd] as Dictionary<String, String>
        
        let request = requestBuilder(route: "login", method: "POST", body: params)
        performRequest(it: request, source: "POST_LOGIN", obj_id: "")
    }
    
    func logoutRequest(delegate: RequestProtocol?) {
        self.delegate = delegate
        
        let request = requestBuilder(route: "login", method: "DELETE", body: nil)
        performRequest(it: request, source: "DELETE_LOGIN", obj_id: "")
    }
    
    // MARK: User Requests
    func addUserResquest(user: User, delegate: RequestProtocol?) {
        self.delegate = delegate
        
        let params = [
            "name": user.name,
            "email": user.email,
            "password": user.pswd,
            "os": user.os
        ] as Dictionary<String, String>
        
        let request = requestBuilder(route: "user", method: "POST", body: params)
        performRequest(it: request, source: "POST_USER", obj_id: user.email)
    }
    
    func userForgotRequest(email: String, delegate: RequestProtocol?) {
        self.delegate = delegate
        
        let params = [
            "email": email,
        ] as Dictionary<String, String>
        
        let request = requestBuilder(route: "user/forgot", method: "POST", body: params)
        performRequest(it: request, source: "USER_FORGOT", obj_id: email)
    }
    
    func updateUserRequest(name: String?, password: String?, delegate: RequestProtocol?) {
        self.delegate = delegate
        
        var params: Dictionary<String, String> = [:]
        if name != nil {
            params["newname"] = name
        }
        if password != nil {
            params["newpassword"] = password
        }
        
        let request = requestBuilder(route: "user", method: "PUT", body: params)
        performRequest(it: request, source: "PUT_USER", obj_id: "")
    }
    
    func deleteUserRequest(delegate: RequestProtocol?) {
        self.delegate = delegate
        
        let request = requestBuilder(route: "user", method: "DELETE", body: nil)
        performRequest(it: request, source: "DELETE_USER", obj_id: "")
    }
    
    // MARK: Tub Requests
    func addTubRequest(tub: Tub, delegate: RequestProtocol?) {
        self.delegate = delegate
        
        let params = [
            "BTid": tub.BTid,
            "tubname": tub.tub_name,
            "pswd1": tub.tub_pswd1,
            "pswd2": tub.tub_pswd2,
            "pswd3": tub.tub_pswd3,
            "pswd4": tub.tub_pswd4,
            "wifi_state": String(tub.wifi_state),
            "mqtt_state": String(tub.mqtt_state),
            "ip": tub.ip,
            "ssid": tub.ssid,
            "mqtt_pub": tub.mqtt_pub,
            "mqtt_sub": tub.mqtt_sub,
            "latitude": tub.latitude,
            "longitude": tub.longitude
        ] as Dictionary<String, String>
        
        let request = requestBuilder(route: "tubs", method: "POST", body: params)
        performRequest(it: request, source: "POST_TUB", obj_id: tub.BTid)
    }
    
    func loadTubRequest(delegate: RequestProtocol?) {
        self.delegate = delegate
        
        let request = requestBuilder(route: "tubs", method: "GET", body: nil)
        performRequest(it: request, source: "GET_TUB", obj_id: "")
    }
    
    func updateTubRequest(tub: Tub, delegate: RequestProtocol?) {
        self.delegate = delegate
        
        let params = [
            "BTid": tub.BTid,
            "tubname": tub.tub_name,
            "pswd1": tub.tub_pswd1,
            "pswd2": tub.tub_pswd2,
            "pswd3": tub.tub_pswd3,
            "pswd4": tub.tub_pswd4,
            "wifi_state": String(tub.wifi_state),
            "mqtt_state": String(tub.mqtt_state),
            "ip": tub.ip,
            "ssid": tub.ssid
        ] as Dictionary<String, String>
        
        let request = requestBuilder(route: "tubs", method: "PUT", body: params)
        performRequest(it: request, source: "PUT_TUB", obj_id: tub.BTid)
    }
    
    func deleteTubRequest(tub_id: String, delegate: RequestProtocol?) {
        self.delegate = delegate
        
        let params = [
            "BTid": tub_id
        ] as Dictionary<String, String>
        
        let request = requestBuilder(route: "tubs", method: "DELETE", body: params)
        performRequest(it: request, source: "DELETE_TUB", obj_id: tub_id)
    }
    
    func saveTubInfoRequest() {
        self.delegate = nil   // We don't require any results
        
        let tubinfo = TubInfo.initFromSettings()
        if let ti = tubinfo {
            let params = [
            "BTid": ti.BTid,
            "pswd1": ti.tub_pswd1,
            "pswd2": ti.tub_pswd2,
            "pswd3": ti.tub_pswd3,
            "pswd4": ti.tub_pswd4,
            "fw": ti.firmware,
            "v": ti.version,
            "qt_bombs": ti.n_bombs,
            "b2Cfg": ti.has_waterEntry,
            "hTemp": ti.has_temp,
            "autoOn": ti.autoOn,
            "hHeater": ti.has_warmer,
            "hRGBA": ti.has_cromo,
            "tOffset": ti.temp_off,
            "tN1": ti.delay_n1,
            "tN2": ti.delay_n2,
            "agDays": ti.ag_days,
            "agHour": ti.ag_hour,
            "agMin": ti.ag_min,
            "agTime": ti.ag_time,
            "wifi_state": ti.wifi_state,
            "pswd": ti.pswd,
            "ssid": ti.ssid,
            "ip": ti.ip,
            "mqtt_state": ti.mqtt_state,
            "mqtt_pub": ti.mqtt_pub,
            "mqtt_sub": ti.mqtt_sub,
            "bklight": ti.backlight,
            "power": ti.power,
            "wTemp": ti.temp,
            "sTemp": ti.desr_temp,
            "warmer": ti.warmer,
            "b1": ti.bomb1,
            "b2": ti.bomb2,
            "b3": ti.bomb3,
            "b4": ti.bomb4,
            "lvl": ti.level,
            "n_spots": ti.n_spot,
            "n_strip": ti.n_strip,
            "spotState": ti.spot_state,
            "spotStatic": ti.spot_static,
            "spotSpeed": ti.spot_speed,
            "spotBright": ti.spot_bright,
            "spotsCMode": ti.spots_cmode,
            "stripState": ti.strip_state,
            "stripStatic": ti.strip_static,
            "stripSpeed": ti.strip_speed,
            "stripBright": ti.strip_bright,
            "stripCMode": ti.strip_cmode
            ] as Dictionary<String, Any>

            let request = requestBuilder(route: "tubinfo", method: "POST", body: params)
            performRequest(it: request, source: "SAVE_TUBINF", obj_id: tubinfo?.BTid ?? "")
        }
    }

}

// MARK: Request Manager Core functions
extension RequestManager {
    
    private func basicAuthGen() -> String {

        let loginString = String(format: "%@:%@", Settings.uemail, Settings.upswd)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        return "Basic \(base64LoginString)"
    }
    
    private func requestBuilder(route: String, method: String, body: Any?) -> URLRequest {
        var request = URLRequest(url: URL(string: API_ADDRESS + route)!)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(basicAuthGen(), forHTTPHeaderField: "Authorization")
        if(method != "GET" && body != nil) {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body!, options: [])
        }
        return request
    }
    
    private func performRequest(it: URLRequest, source: String, obj_id: String) {
        let session = URLSession.shared
        
        let task = session.dataTask(with: it, completionHandler: { data, response, error -> Void in
            let r_code = (response as? HTTPURLResponse)?.statusCode ?? 999
            do {
                if let resp = data, let json = try JSONSerialization.jsonObject(with: resp) as? Dictionary<String, AnyObject> {
                    //print(json)
                    self.delegate?.onSuccess(code: r_code, response: [json], source: source)
                } else if let resp = data, let json = try JSONSerialization.jsonObject(with: resp) as? [Dictionary<String, AnyObject>] {
                    //print(json)
                    self.delegate?.onSuccess(code: r_code, response: json, source: source)
                } else {
                    //print("error: \(error)")
                    self.keepPendingRequest(requestType: source, objectId: obj_id)
                    self.delegate?.onError(code: r_code, error: error!, source: source)
                }
            } catch {
                //print("error: \(error)")
                self.keepPendingRequest(requestType: source, objectId: obj_id)
                self.delegate?.onError(code: r_code, error: error, source: source)
            }
        })

        task.resume()
    }

}

// MARK: Offline request manager

extension RequestManager: RequestProtocol {
    
    func keepPendingRequest(requestType: String, objectId: String) {
        
        guard
            requestType == "DELETE_TUB" ||
            requestType == "PUT_TUB" ||
            requestType == "POST_TUB"
        else { return }
        
        if let db = RealmDB.forThread() {
            let pr = PendingRequest()
            pr.oid = objectId
            pr.typ = requestType
            do {
                try db.write {
                    db.add(pr, update: .modified)
                }
            } catch  { }
        }
    }
    
    func deletePendingRequest() {
        if let db = RealmDB.forThread() {
            do {
                try db.write {
                    if let pr = db.objects(PendingRequest.self).first {
                        db.delete(pr)
                    }
                }
            } catch  { }
        }
    }
    
    func sendPendingRequest() {
        if(RequestManager.it.resending) { return }
        if let db = RealmDB.forThread() {
            if let pr = db.objects(PendingRequest.self).first {
                RequestManager.it.resending = true
                if(pr.typ != "DELETE_TUB") {
                    if let tub = db.object(ofType: Tub.self, forPrimaryKey: pr.oid) {
                        if(pr.typ == "POST_TUB") {
                            RequestManager.it.addTubRequest(tub: tub, delegate: self)
                        } else {
                            RequestManager.it.updateTubRequest(tub: tub, delegate: self)
                        }
                    }
                    return
                }
                RequestManager.it.deleteTubRequest(tub_id: pr.oid, delegate: self)
            }
        }
    }
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String) {
        RequestManager.it.deletePendingRequest()
        RequestManager.it.resending = false
        RequestManager.it.sendPendingRequest()
    }
    
    func onError(code: Int, error: Error, source: String) {
        RequestManager.it.resending = false
        if(code < 500) {
            RequestManager.it.deletePendingRequest()
            RequestManager.it.sendPendingRequest()
        }
    }
    
}
