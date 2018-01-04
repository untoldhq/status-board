//
//  Vehicle.swift
//  status-board
//
//  Created by Sam Ingle on 9/17/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import RealmSwift
import Decodable
import protocol Decodable.Decodable
import CoreLocation

class Vehicle: Object {
    fileprivate dynamic var latitudeInternal = 0.0
    fileprivate dynamic var longitudeInternal = 0.0
    fileprivate dynamic var previousLatitudeInternal = 0.0
    fileprivate dynamic var previousLongitudeInternal = 0.0
    dynamic var id = 0
    dynamic var name = ""
    dynamic var bearing: CGFloat = 0.0
    dynamic var routeId = 0
    
    static var timer: Timer? = nil
    static let pollingInterval = 5.0
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["location", "previousLocation"]
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
    
    var route: Route? {
        return Data.object(ofType: Route.self, forPrimaryKey: routeId)
    }
    
    var previousLocation: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitudeInternal, longitude: longitudeInternal)
        }
        set (value) {
            previousLatitudeInternal = value.latitude
            previousLongitudeInternal = value.longitude
        }
    }
    
    static func startWatching() {
        timer = Timer.scheduledTimer(timeInterval: pollingInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    static func tick() {
        guard Data.objects(ofType: WatchedDestination.self).count > 0 else {
            return
        }
        let routeIds = Data.objects(ofType: WatchedDestination.self).map { String($0.route.id) }
        let routes = routeIds.joined(separator: ",")
        API.manager.request(.vehicles(parameters: ["routes": routes])) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let value):
                parse(value)
            }
        }
    }
    
    static func parse(_ json: Any) {
        Data.write {
            do {
                let array = try json => "resultSet" => "vehicle"
                _ = try [Vehicle].decode(array)
            }
            catch let error {
                print(error)
            }
        }
    }
}

extension Vehicle: Decodable {
    static func decode(_ json: Any) throws -> Self {
        let vehicle = Data.guaranteedObject(ofType: self, forPrimaryKey: try json => "vehicleID")
        vehicle.previousLocation = vehicle.location
        vehicle.location = CLLocationCoordinate2D(latitude: try json => "latitude", longitude: try json => "longitude")
        vehicle.name = try json => "signMessage"
        vehicle.routeId = try json => "routeNumber"
        let bearing: Double = try json => "bearing"
        vehicle.bearing = CGFloat(bearing)
        return vehicle
    }
}
