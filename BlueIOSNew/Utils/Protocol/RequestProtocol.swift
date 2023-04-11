//
//  RequestProtocol.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation

protocol RequestProtocol {
    
    func onSuccess(code: Int, response: [Dictionary<String, AnyObject>], source: String)
    
    func onError(code: Int, error: Error, source: String)
    
}
