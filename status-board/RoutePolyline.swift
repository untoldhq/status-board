//
//  RoutePolyline.swift
//  status-board
//
//  Created by Sam Ingle on 1/8/18.
//  Copyright © 2018 Untold. All rights reserved.
//

import Foundation
import MapKit

class RoutePolyline: MKPolyline {
    var routeLine: MaxLine?
    var routePhase: Int = 0 //This will be rendered with offset dashed lines, this value is used to calculate the offset
    var routeColors: [UIColor] = []
}
