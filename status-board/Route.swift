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
    dynamic var name = ""
    private dynamic var routeTypeInternal = 0
    let stops = List<Stop>()
    
    override static func primaryKey() -> String {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["compactLabel"]
    }
    
    var routeType: RouteType {
        get {
            return RouteType(rawValue: routeTypeInternal)!
        }
        set (value) {
            routeTypeInternal = value.rawValue
        }
        
    }
    
    var compactLabel: String {
        switch id {
        case 90:
            return "Red"
        case 100:
            return "Blue"
        case 190:
            return "Yellow"
        case 200:
            return "Green"
        case 290:
            return "Orange"
        case 193:
            return "NS Line"
        case 194:
            return "A Loop"
        case 195:
            return "B Loop"
        default:
            return String(id)
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
        route.name = try json => "desc"
        return route
    }
}