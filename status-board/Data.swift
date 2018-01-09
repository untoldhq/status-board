//
//  DataManager.swift
//  status-board
//
//  Created by Sam Ingle on 9/6/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import RealmSwift

typealias Context = Realm

struct Data {
    static let manager = Data()
    
    static func configure() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            schemaVersion: 7,
            migrationBlock: { migration, oldSchemaVersion in
                // migration template
                //                if oldSchemaVersion < 1 {
                //
                //                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        print(Realm.Configuration.defaultConfiguration.fileURL!)

    }
    static func context() -> Context {
        return try! Realm()
    }
    static func write(inContext context: Context, block: ()->()) {
        manager.write(inContext: context, block: block)
    }
    func write(inContext context: Context, block: ()->()) {
        if Thread.current == Thread.main {
            print("KNOCK IT OFF – don't write to realm from the main thread")
        }
        do {
            try context.write(block)
        }
        catch {
            print(error)
        }
    }
    
    static func object<T : RealmSwift.Object, K>(inContext context: Context, ofType type: T.Type, forPrimaryKey key: K) -> T? {
        return manager.object(inContext: context, ofType: type, forPrimaryKey: key)
    }
    
    func object<T : RealmSwift.Object, K>(inContext context: Context, ofType type: T.Type, forPrimaryKey key: K) -> T? {
        return context.object(ofType: type, forPrimaryKey: key)
    }
    
    // must be called from a write block
    static func guaranteedObject<T : RealmSwift.Object, K>(inContext context: Context, ofType type: T.Type, forPrimaryKey key: K) -> T {
        return manager.guaranteedObject(inContext: context, ofType: type, forPrimaryKey: key)
    }
    func guaranteedObject<T : RealmSwift.Object, K>(inContext context: Context, ofType type: T.Type, forPrimaryKey key: K) -> T {
        if let object = self.object(inContext: context, ofType: type, forPrimaryKey: key) {
            return object
        }
        let object = type.init()
        object.setValue(key, forKey: type.primaryKey()!)
        self.add(inContext: context, object)
        return object
    }
    
    
    
    static func objects<T: Object>(inContext context: Context, ofType type: T.Type) -> Results<T> {
        return manager.objects(inContext: context, ofType: type)
    }
    func objects<T: Object>(inContext context: Context, ofType type: T.Type) -> Results<T> {
        return context.objects(type)
    }
    
    static func add(inContext context: Context, _ object: Object, update: Bool = false) {
        manager.add(inContext: context, object, update: update)
    }
    func add(inContext context: Context, _ object: Object, update: Bool = false) {
        context.add(object, update: update)
    }
    
    static func delete(inContext context: Context, _ object: Object) {
        manager.delete(inContext: context, object)
    }
    func delete(inContext context: Context, _ object: Object) {
        context.delete(object)
    }
}
