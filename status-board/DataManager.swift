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
}
