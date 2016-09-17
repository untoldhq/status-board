//
//  DataManager.swift
//  status-board
//
//  Created by Sam Ingle on 9/6/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

struct Data {
    static let manager = Data()
    
    static func configure() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                // migration template
                //                if oldSchemaVersion < 1 {
                //
                //                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

    }

    let location = CLLocationCoordinate2D(latitude: 45.5202644, longitude: -122.6744711)
    
    // swiftlint:disable force_try
    let realm = try! Realm()
    // swiftlint:enable force_try
    
    static func write(block: ()->()) {
        manager.write(block)
    }
    func write(block: ()->()) {
        do {
            try realm.write(block)
        }
        catch {
            print(error)
        }
    }
    
    static func objectForPrimaryKey<T: Object>(type: T.Type, key: AnyObject?) -> T? {
        return manager.objectForPrimaryKey(type, key: key)
    }
    
    func objectForPrimaryKey<T: Object>(type: T.Type, key: AnyObject?) -> T? {
        return realm.objectForPrimaryKey(type, key: key)
    }
    
    // must be called from a write block
    static func guaranteedObjectForPrimaryKey<T: Object>(type: T.Type, key: AnyObject?) -> T {
        return manager.guaranteedObjectForPrimaryKey(type, key: key)
    }
    func guaranteedObjectForPrimaryKey<T: Object>(type: T.Type, key: AnyObject?) -> T {
        if let object = objectForPrimaryKey(type, key: key) {
            return object
        }
        let object = type.init()
        object.setValue(key, forKey: type.primaryKey()!)
        self.add(object)
        return object
    }
    
    
    
    static func objects<T: Object>(type: T.Type) -> Results<T> {
        return manager.objects(type)
    }
    func objects<T: Object>(type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    static func add(object: Object, update: Bool = false) {
        manager.add(object, update: update)
    }
    func add(object: Object, update: Bool = false) {
        realm.add(object, update: update)
    }
    
    static func delete(object: Object) {
        manager.delete(object)
    }
    func delete(object: Object) {
        realm.delete(object)
    }
}
