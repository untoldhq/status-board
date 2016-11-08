//
//  DataManager.swift
//  status-board
//
//  Created by Sam Ingle on 9/6/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import RealmSwift

struct Data {
    static let manager = Data()
    
    static func configure() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            schemaVersion: 6,
            migrationBlock: { migration, oldSchemaVersion in
                // migration template
                //                if oldSchemaVersion < 1 {
                //
                //                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

    }
    
    // swiftlint:disable force_try
    let realm = try! Realm()
    // swiftlint:enable force_try
    
    static func write(_ block: ()->()) {
        manager.write(block)
    }
    func write(_ block: ()->()) {
        do {
            try realm.write(block)
        }
        catch {
            print(error)
        }
    }
    
    static func object<T : RealmSwift.Object, K>(ofType type: T.Type, forPrimaryKey key: K) -> T? {
        return manager.object(ofType: type, forPrimaryKey: key)
    }
    
    func object<T : RealmSwift.Object, K>(ofType type: T.Type, forPrimaryKey key: K) -> T? {
        return realm.object(ofType: type, forPrimaryKey: key)
    }
    
    // must be called from a write block
    static func guaranteedObject<T : RealmSwift.Object, K>(ofType type: T.Type, forPrimaryKey key: K) -> T {
        return manager.guaranteedObject(ofType: type, forPrimaryKey: key)
    }
    func guaranteedObject<T : RealmSwift.Object, K>(ofType type: T.Type, forPrimaryKey key: K) -> T {
        if let object = self.object(ofType: type, forPrimaryKey: key) {
            return object
        }
        let object = type.init()
        object.setValue(key, forKey: type.primaryKey()!)
        self.add(object)
        return object
    }
    
    
    
    static func objects<T: Object>(ofType type: T.Type) -> Results<T> {
        return manager.objects(ofType: type)
    }
    func objects<T: Object>(ofType type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    static func add(_ object: Object, update: Bool = false) {
        manager.add(object, update: update)
    }
    func add(_ object: Object, update: Bool = false) {
        realm.add(object, update: update)
    }
    
    static func delete(_ object: Object) {
        manager.delete(object)
    }
    func delete(_ object: Object) {
        realm.delete(object)
    }
}
