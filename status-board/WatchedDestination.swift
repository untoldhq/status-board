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
    fileprivate dynamic var routeInternal: Route?
    fileprivate dynamic var stopInternal: Stop?
    dynamic var id = UUID().uuidString
    dynamic var nextArrival: Date? = nil
    
    static var timer: Timer? = nil
    
    var route: Route {
        return routeInternal!
    }
    
    var stop: Stop {
        return stopInternal!
    }
    
    static func startWatching() {
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    static func tick() {
        guard Data.objects(ofType: self).count > 0 else {
            return
        }
        let stopIds = Data.objects(ofType: self).map { String($0.stop.id) }
        let stops = stopIds.joined(separator: ",")
        API.manager.request(.arrivals(parameters: ["locIDs": stops])) { result in
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
                let array = try json => "resultSet" => "arrival"
                let arrivals = try [Arrival].decode(array)
                for arrival in arrivals {
                    if let route = Data.object(ofType: Route.self, forPrimaryKey: arrival.routeId),
                        let stop = Data.object(ofType: Stop.self, forPrimaryKey: arrival.stopId),
                        let destination = self.destinationForRoute(route, stop: stop),
                        let arrival = arrival.arrivalTime {
                        destination.nextArrival = arrival
                    }
                }
            }
            catch let error {
                print(error)
            }
        }
    }
    
    static func isWatched(_ route: Route, stop: Stop) -> Bool {
        return destinationForRoute(route, stop: stop) != nil
    }
    
    static func destinationForRoute(_ route: Route, stop: Stop) -> WatchedDestination? {
        return Data.objects(ofType: self).filter { $0.route == route && $0.stop == stop }.first
    }
    
    static func destinationsForRoute(_ route: Route) -> [WatchedDestination] {
        return Data.objects(ofType: self).filter { $0.route == route }
    }
    
    static func watch(_ route: Route, stop: Stop) {
        let destination = WatchedDestination()
        destination.routeInternal = route
        destination.stopInternal = stop
        Data.write {
            Data.add(destination)
        }
    }
    
    static func unWatch(_ route: Route, stop: Stop) {
        if let destination = destinationForRoute(route, stop: stop) {
            Data.write {
                Data.delete(destination)
            }
        }
    }
}

struct Arrival {
    static let dateFormatter: DateFormatter = {
        $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return $0
    }(DateFormatter())

    let routeId: Int
    let stopId: Int
    let arrivalTime: Date?
}

extension Arrival: Decodable {
    static func decode(_ json: Any) throws -> Arrival {
        let maybeEstimated: String? = try json =>? "estimated"
        let estimated: String = maybeEstimated ?? ""
        return try Arrival(
            routeId: json => "route",
            stopId: json => "locid",
            arrivalTime: Arrival.dateFormatter.date(from: estimated)
        )
    }
}
