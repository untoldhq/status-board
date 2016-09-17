//
//  Route.swift
//  status-board
//
//  Created by Sam Ingle on 9/16/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import RealmSwift
import Decodable

class Route: Object {
    
    enum RouteType: Int {
        case Bus
        case LightRail
    }
    
    dynamic var id = 0
    dynamic var routeDescription: String = ""
    private var routeTypeInternal = 0
    let stops = List<Stop>()
    
    override static func primaryKey() -> String {
        return "id"
    }

    var routeType: RouteType = .Bus {
        didSet {
            routeTypeInternal = routeType.rawValue
        }
    }
    
    func connectStop(stop: Stop) {
        if !stops.contains(stop) {
            stops.append(stop)
        }
        if !stop.routes.contains(self) {
            stop.routes.append(self)
        }
    }
}

extension Route: Decodable {
    static func decode(json: AnyObject) throws -> Self {
        let route = Data.guaranteedObjectForPrimaryKey(self, key: try json => "route")
        let routeTypeCode: String = try json => "type"
        if routeTypeCode == "B" {
            route.routeType = .Bus
        }
        else {
            route.routeType = .LightRail
        }
        route.routeDescription = try json => "desc"
        return route
    }
}
