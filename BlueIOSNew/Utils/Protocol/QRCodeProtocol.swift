//
//  QRCodeProtocol.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation

protocol QRCodeProtocol: AnyObject {
    
    func qrScanningDidFail()
    
    func qrScanningSucceededWithCode(_ str: String?)
    
    func qrScanningDidStop()
    
}
