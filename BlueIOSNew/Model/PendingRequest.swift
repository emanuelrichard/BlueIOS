//
//  PendingRequest.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import RealmSwift

class PendingRequest: Object {
    @objc dynamic var oid: String = ""
    @objc dynamic var typ: String = ""

    override static func primaryKey() -> String? {
            return "oid"
    }
}
