//
//  ConnectionStateDefs.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation

class Connection {
    
    enum State: Int {
        case DISCONNECTED, CONNECTING, CONNECTED, DISCONNECTING, FAILED
    }
    
}
