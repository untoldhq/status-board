//
//  DataManager.swift
//  status-board
//
//  Created by Sam Ingle on 9/6/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import RealmSwift

struct DataManager {
    static let sharedInstance = DataManager()
    
    init() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            schemaVersion: 6,
            migrationBlock: { migration, oldSchemaVersion in
                
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        print(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString)
    }
    
    //MARK: - Main Methods
    func context() -> Realm {
        return try! Realm() // We'll crash if we fail to create a realm instance (should only happen in situations where something is misconfigured, not at runtime)
    }
    
//    // swiftlint:disable force_try
//    let realm = try! Realm()
//    // swiftlint:enable force_try
    
    func write(inContext realm: Realm, block: ()->()) {
//        manager.write(block)
        do {
            try realm.write {
                block()
            }
        }
        catch {
            print("Critical: Failed to write")
        }
    }
    
//    func write(_ block: ()->()) {
//        do {
//            try realm.write(block)
//        }
//        catch {
//            print(error)
//        }
//    }
    
    func add(inContext realm: Realm, object: Object) {
        let type = type(of: object)
        realm.add(object, update: type.primaryKey() != nil)
    }
    
    func delete(inContext realm: Realm, object: Object) {
        realm.delete(object)
    }
    
    func objects<T : Object>(inContext realm: Realm, ofType type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    func object<T : Object, K>(inContext realm: Realm, ofType type: T.Type, forPrimaryKey key: K) -> T? {
        return realm.object(ofType: type, forPrimaryKey: key)
    }
    
    static func context() -> Realm {
        return sharedInstance.context()
    }
    
    static func write(inContext realm: Realm, block: () -> ()) {
        sharedInstance.write(inContext: realm, block: block)
    }
    
    static func add(inContext realm: Realm, object: Object) {
        sharedInstance.add(inContext: realm, object: object)
    }
    
    static func delete(inContext realm: Realm, object: Object) {
        sharedInstance.delete(inContext: realm, object: object)
    }
    
    static func objects<T : Object>(inContext realm: Realm, ofType type: T.Type) -> Results<T> {
        return sharedInstance.objects(inContext: realm, ofType: type)
    }
    
    static func object<T : Object, K>(inContext realm: Realm, ofType type: T.Type, forPrimaryKey key: K) -> T? {
        return sharedInstance.object(inContext: realm, ofType: type, forPrimaryKey: key)
    }
    
    static func guaranteedObject<T : Object, K>(inContext realm: Realm, ofType type: T.Type, forPrimaryKey key: K) -> T {
        return DataManager.guaranteedObject(inContext: realm, ofType: type, forPrimaryKey: key)
    }
    func guaranteedObject<T : Object, K>(inContext realm: Realm, ofType type: T.Type, forPrimaryKey key: K) -> T {
        if let object = self.object(inContext: realm, ofType: type, forPrimaryKey: key) {
            return object
        }
        let object = type.init()
        object.setValue(key, forKey: type.primaryKey()!)
        self.add(inContext: realm, object: object)
        return object
    }
    

    
    // must be called from a write block
//    static func guaranteedObject<T : RealmSwift.Object, K>(ofType type: T.Type, forPrimaryKey key: K) -> T {
//        return manager.guaranteedObject(ofType: type, forPrimaryKey: key)
//    }
//    func guaranteedObject<T : RealmSwift.Object, K>(ofType type: T.Type, forPrimaryKey key: K) -> T {
//        if let object = self.object(ofType: type, forPrimaryKey: key) {
//            return object
//        }
//        let object = type.init()
//        object.setValue(key, forKey: type.primaryKey()!)
//        self.add(object)
//        return object
//    }
//
    
    //    static func object<T : RealmSwift.Object, K>(ofType type: T.Type, forPrimaryKey key: K) -> T? {
    //        return manager.object(ofType: type, forPrimaryKey: key)
    //    }
    //
    //    func object<T : RealmSwift.Object, K>(ofType type: T.Type, forPrimaryKey key: K) -> T? {
    //        return realm.object(ofType: type, forPrimaryKey: key)
    //    }
    
    
//    static func objects<T: Object>(ofType type: T.Type) -> Results<T> {
//        return manager.objects(ofType: type)
//    }
//    func objects<T: Object>(ofType type: T.Type) -> Results<T> {
//        return realm.objects(type)
//    }
//    
//    static func add(_ object: Object, update: Bool = false) {
//        manager.add(object, update: update)
//    }
//    func add(_ object: Object, update: Bool = false) {
//        realm.add(object, update: update)
//    }
//    
//    static func delete(_ object: Object) {
//        manager.delete(object)
//    }
//    func delete(_ object: Object) {
//        realm.delete(object)
//    }
}
