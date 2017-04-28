//
//  Location.swift
//  status-board
//
//  Created by Sam Ingle on 9/17/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationManager {
    static let manager = LocationManager()
    let location = CLLocationCoordinate2D(latitude: 45.5202644, longitude: -122.6744711)
    let region : CLCircularRegion
    init() {
        region = CLCircularRegion(center: location, radius: 804.67, identifier: "defaultMapRegion") // one half mile = 804.67 meters
    }
}
