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
    private dynamic var latitudeInternal = 0.0
    private dynamic var longitudeInternal = 0.0
    dynamic var directionality = ""
    dynamic var id = 0
    dynamic var stopDescription = ""
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
        API.manager.request(.Stops(parameters: nil)) { result in
            switch result {
            case .Failure(let error):
                print(error)
            case .Success(let value):
                parse(value)
            }
        }
    }
    
    static func parse(json: AnyObject) {
        Data.write {
            do {
                let array = try json => "resultSet" => "location"
                try [Stop].decode(array)
            }
            catch let error {
                print(error)
            }
        }
    }
    
}

extension Stop: Decodable {
    static func decode(json: AnyObject) throws -> Self {
        let stop = Data.guaranteedObjectForPrimaryKey(self, key: try json => "locid")
        stop.directionality = try json => "dir"
        stop.location = CLLocationCoordinate2D(latitude: try json => "lat", longitude: try json => "lng")
        stop.stopDescription = try json => "desc"
        if let routesJson = try json =>? "route" {
            let routes = try [Route].decode(routesJson)
            for route in routes {
                route.connectStop(stop)
            }
        }
        return stop
    }
}
