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
import protocol Decodable.Decodable

class WatchedDestination: Object {
    @objc fileprivate dynamic var routeInternal: Route?
    @objc fileprivate dynamic var stopInternal: Stop?
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var nextArrival: Date? = nil
    
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
    
    @objc static func tick() {
        guard Data.objects(inContext: Data.context(), ofType: self).count > 0 else {
            return
        }
        let stopIds = Data.objects(inContext: Data.context(), ofType: self).map { String($0.stop.id) }
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
        Data.write(inContext: Data.context()) {
            do {
                let array = try json => "resultSet" => "arrival"
                var arrivals = try [Arrival].decode(array)
                arrivals = arrivals.flatMap { $0.arrivalTime != nil ? $0 : nil } // filter out arrivals with no arrival time
                arrivals = arrivals.filter { arrival in
                    let otherStopArrivals: [Arrival] = arrivals.filter { $0.routeId == arrival.routeId && $0.stopId == arrival.stopId && arrival.arrivalTime != $0.arrivalTime }
                    let soonestOtherArrival = otherStopArrivals.min {
                         $0.arrivalTime! < $1.arrivalTime!
                    }
                    if let soonest = soonestOtherArrival {
                        return arrival.arrivalTime! < soonest.arrivalTime!
                    }
                    return true // no other arrival times, so this one is the soonest.
                }
                for arrival in arrivals {
                    if let route = Data.object(inContext: Data.context(), ofType: Route.self, forPrimaryKey: arrival.routeId),
                        let stop = Data.object(inContext: Data.context(), ofType: Stop.self, forPrimaryKey: arrival.stopId),
                        let destination = self.destinationForRoute(route, stop: stop){
                        destination.nextArrival = arrival.arrivalTime
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
        return Data.objects(inContext: Data.context(), ofType: self).filter { $0.route == route && $0.stop == stop }.first
    }
    
    static func destinationsForRoute(_ route: Route) -> [WatchedDestination] {
        return Data.objects(inContext: Data.context(), ofType: self).filter { $0.route == route }
    }
    
    static func watch(_ route: Route, stop: Stop) {
        let destination = WatchedDestination()
        destination.routeInternal = route
        destination.stopInternal = stop
        Data.write(inContext: Data.context()) {
            Data.add(inContext: Data.context(), destination)
        }
    }
    
    static func unWatch(_ route: Route, stop: Stop) {
        if let destination = destinationForRoute(route, stop: stop) {
            Data.write(inContext: Data.context()) {
                Data.delete(inContext: Data.context(), destination)
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
    let arrivalTime: Date! // I hate this, but this is working around a shortcoming in Decodable (can't partially fail an array initializer)
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
