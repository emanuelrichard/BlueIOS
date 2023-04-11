//
//  BluetoothLEProtocol.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation

protocol BluetoothLEProtocol {
    
    func didStartScan()
    
    func didFoundTub(BTid: String)
    
}
