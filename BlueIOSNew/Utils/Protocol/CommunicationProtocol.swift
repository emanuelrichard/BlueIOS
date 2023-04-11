//
//  CommunicationProtocol.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation

protocol CommunicationProtocol {
    
    func didReceiveFeedback(about: String, value: Int)
    
    func didReceiveFeedback(about: String, text: String)
    
}
