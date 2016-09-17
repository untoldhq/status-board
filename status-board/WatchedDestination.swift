//
//  WatchedDestination.swift
//  status-board
//
//  Created by Sam Ingle on 9/16/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import RealmSwift
import Decodable

class WatchedDestination: Object {
    private dynamic var routeInternal: Route?
    private dynamic var stopInternal: Stop?
    dynamic var id = NSUUID().UUIDString
    dynamic var nextArrival: NSDate? = nil
    
    static var timer: NSTimer? = nil
    
    var route: Route {
        return routeInternal!
    }
    var stop: Stop {
        return stopInternal!
    }
    
    static func startWatching() {
        timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    static func tick() {
        guard Data.objects(self).count > 0 else {
            return
        }
        let stopIds = Data.objects(self).map { String($0.stop.id) }
        let stops = stopIds.joinWithSeparator(",")
        API.manager.request(.Arrivals(parameters: ["locIDs": stops])) { result in
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
                let array = try json => "resultSet" => "arrival"
                let arrivals = try [Arrival].decode(array)
                for arrival in arrivals {
                    if let route = Data.objectForPrimaryKey(Route.self, key: arrival.routeId),
                        stop = Data.objectForPrimaryKey(Stop.self, key: arrival.stopId),
                        destination = self.destinationForRoute(route, stop: stop),
                        arrival = arrival.arrivalTime {
                        destination.nextArrival = arrival
                    }
                }
            }
            catch let error {
                print(error)
            }
        }
    }
    
    static func isWatched(route: Route, stop: Stop) -> Bool {
        return destinationForRoute(route, stop: stop) != nil
    }
    
    static func destinationForRoute(route: Route, stop: Stop) -> WatchedDestination? {
        return Data.objects(self).filter { $0.route == route && $0.stop == stop }.first
    }
    static func destinationsForRoute(route: Route) -> [WatchedDestination] {
        return Data.objects(self).filter { $0.route == route }
    }
    
    static func watch(route: Route, stop: Stop) {
        let destination = WatchedDestination()
        destination.routeInternal = route
        destination.stopInternal = stop
        Data.write {
            Data.add(destination)
        }
    }
    
    static func unWatch(route: Route, stop: Stop) {
        if let destination = destinationForRoute(route, stop: stop) {
            Data.write {
                Data.delete(destination)
            }
        }
    }
}

struct Arrival {
    static let dateFormatter: NSDateFormatter = {
        $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return $0
    }(NSDateFormatter())

    let routeId: Int
    let stopId: Int
    let arrivalTime: NSDate?
}

extension Arrival: Decodable {
    static func decode(json: AnyObject) throws -> Arrival {
        let estimated: String = try json =>? "estimated" ?? ""
        return try Arrival(
            routeId: json => "route",
            stopId: json => "locid",
            arrivalTime: Arrival.dateFormatter.dateFromString(estimated)
        )
    }
}
