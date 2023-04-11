//
//  ConnectingProtocol.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation

protocol ConnectingProtocol {
    
    func didStartConnectingTub()
    
    func didConnectTub()
    
    func didDisconnectTub()
    
    func didFail()
    
}
