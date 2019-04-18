//
//  Location.swift
//  status-board
//
//  Created by Sam Ingle on 9/17/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import CoreLocation

struct Location {
    static let manager = Location()
    static let headquartersLocation = CLLocationCoordinate2D(latitude: 45.520171, longitude: -122.671580)
    let region : CLCircularRegion
    init() {
        region = CLCircularRegion(center: Location.headquartersLocation, radius: 804.67, identifier: "defaultMapRegion") // one half mile = 804.67 meters
    }
}
