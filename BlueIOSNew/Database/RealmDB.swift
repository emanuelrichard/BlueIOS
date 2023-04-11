//
//  RealmDB.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation
import Realm
import RealmSwift

class RealmDB {
    
    static let it = getDB()
    
    static func forThread() -> Realm? {
        return getDB()
    }
    
    private static func getDB() -> Realm? {
        let config = Realm.Configuration(
            fileURL: URL(fileURLWithPath: RLMRealmPathForFile("default.realm"), isDirectory: false), //default file URL provided by Realm doc; need to import Realm
            inMemoryIdentifier: nil,
            syncConfiguration: nil,
            encryptionKey: nil,
            readOnly: false,
            schemaVersion: 1,
            migrationBlock: nil,
            deleteRealmIfMigrationNeeded: true,  //only set to true during development.  This will delete the default realm if there are any changes that cause a migration to fail (ie removing a class property or class entirely)
            shouldCompactOnLaunch: nil,
            objectTypes: nil
        )
        
        do {
            let myRealm = try Realm(configuration: config)
            return myRealm
        } catch {
            //print(error.localizedDescription)
            return nil
        }
    }
}
