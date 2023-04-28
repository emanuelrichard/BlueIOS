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
    // Objeto Singleton da classe RealmDB
    static let it = getDB()

    // Retorna uma instância do Realm para uso em threads diferentes da thread principal
    static func forThread() -> Realm? {
        return getDB()
    }

    // Método privado que retorna uma instância do Realm
    private static func getDB() -> Realm? {
        // Cria uma nova configuração para o Realm
        let config = Realm.Configuration(
            // Caminho do arquivo Realm
            fileURL: URL(fileURLWithPath: RLMRealmPathForFile("default.realm"), isDirectory: false), //default file URL provided by Realm doc; need to import Realm
            inMemoryIdentifier: nil,
            syncConfiguration: nil,
            encryptionKey: nil,
            readOnly: false,
            // Versão do esquema do banco de dados
            schemaVersion: 1,
            migrationBlock: nil,
            // Deleta o banco de dados em caso de falha na migração (somente durante o desenvolvimento)
            deleteRealmIfMigrationNeeded: true,
            shouldCompactOnLaunch: nil,
            objectTypes: nil
        )
        
        do {
            // Cria uma nova instância do Realm com a configuração definida
            let myRealm = try Realm(configuration: config)
            return myRealm
        } catch {
            // Em caso de erro, retorna nulo e imprime o erro
            //print(error.localizedDescription)
            return nil
        }
    }
}
