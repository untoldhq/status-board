//
//  Stop.swift
//  status-board
//
//  Created by Sam Ingle on 9/16/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
import Decodable

class Stop: Object {
    fileprivate dynamic var latitudeInternal = 0.0
    fileprivate dynamic var longitudeInternal = 0.0
    dynamic var directionality = ""
    dynamic var id = 0
    dynamic var name = ""
    let routes = List<Route>()
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["location"]
    }

    var location: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitudeInternal, longitude: longitudeInternal)
        }
        set (value) {
            latitudeInternal = value.latitude
            longitudeInternal = value.longitude
        }
    }
    
    static func fetch() {
        API.manager.request(.stops(parameters: nil)) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let value):
                let context = DataManager.context()
                parse(value, inContext: context)
            }
        }
    }
    
    static func parse(_ json: Any, inContext context: Realm) {
        DataManager.write(inContext: context) {
            do {
                let array = try json => "resultSet" => "location"
                _ = try [Stop].decode(array)
            }
            catch let error {
                print(error)
            }
        }
    }
    
}

extension Stop: Decodable {
    
    static func decode(_ json: Any) throws -> Self {
        let context = DataManager.context()
        let stop = DataManager.guaranteedObject(inContext: context, ofType: self, forPrimaryKey: try json => "locid")
        stop.directionality = try json => "dir"
        stop.location = CLLocationCoordinate2D(latitude: try json => "lat", longitude: try json => "lng")
        stop.name = try json => "desc"
        if let routesJson = try json =>? "route" {
            let routes = try [Route].decode(routesJson)
            for route in routes {
                route.connectStop(stop)
            }
        }
        return stop
    }
}
