//
//  RouteLine.swift
//  status-board
//
//  Created by Sam Ingle on 1/5/18.
//  Copyright © 2018 Untold. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SWXMLHash
import CoreLocation

class MaxRouteLine: Object {
    
    var line: MaxLine {
        get {
            return MaxLine(rawValue: internalLine)!
        }
        set {
            internalLine = newValue.rawValue
        }
    }
    @objc dynamic private var internalLine: Int = MaxLine.blue.rawValue
    @objc dynamic private var internalPolyLine: String = ""
    
    var colorCount: Int {
        switch line {
        case .blueRed, .blueGreen, .greenOrange, .greenYellow:
            return 2
        case .blueGreenRed:
            return 3
        case .blueGreenRedYellow:
            return 4
        default:
            return 1
        }
    }
    
    static let trimetBlue = UIColor(red:0.16, green:0.41, blue:0.65, alpha:1.0)
    static let trimetRed = UIColor(red:0.75, green:0.18, blue:0.27, alpha:1.0)
    static let trimetGreen = UIColor(red:0.23, green:0.52, blue:0.34, alpha:1.0)
    static let trimetYellow = UIColor(red:0.97, green:0.78, blue:0.30, alpha:1.0)
    static let trimetOrange = UIColor(red:0.77, green:0.39, blue:0.17, alpha:1.0)
    
    var colors: [UIColor] {
        switch line {
        case .blue:
            return [MaxRouteLine.trimetBlue]
        case .blueGreen:
            return [MaxRouteLine.trimetBlue, MaxRouteLine.trimetGreen]
        case .blueGreenRed:
            return [MaxRouteLine.trimetBlue, MaxRouteLine.trimetGreen, MaxRouteLine.trimetRed]
        case .blueGreenRedYellow:
            return [MaxRouteLine.trimetBlue, MaxRouteLine.trimetGreen, MaxRouteLine.trimetRed, MaxRouteLine.trimetYellow]
        case .blueRed:
            return [MaxRouteLine.trimetBlue, MaxRouteLine.trimetRed]
        case .green:
            return [MaxRouteLine.trimetGreen]
        case .greenOrange:
            return [MaxRouteLine.trimetGreen, MaxRouteLine.trimetOrange]
        case .greenYellow:
            return [MaxRouteLine.trimetGreen, MaxRouteLine.trimetYellow]
        case .orange, .orangeALoopBLoop:
            return [MaxRouteLine.trimetOrange]
        case .red:
            return [MaxRouteLine.trimetRed]
        case .yellow:
            return [MaxRouteLine.trimetYellow]
        }
    }
    
    var polyLine: [CLLocationCoordinate2D] {
        let points = internalPolyLine.components(separatedBy: " ")
        return points.map {
            let coords = $0.components(separatedBy: ",")
            return CLLocationCoordinate2D(latitude: Double(coords[1])!, longitude: Double(coords[0])!)
        }
    }
    
    class func fetchMaxRouteLines() {
        Alamofire.request(API.maxKMLEndpoint).responseData { response in
            switch response.result {
            case .success:
                if let data = response.result.value {
                    DispatchQueue(label: "parser").async {
                        let xml: XMLIndexer = SWXMLHash.lazy(data)
                        parseLines(xml)
                    }
                    
                }
            case .failure(let error):
                print("failed to parse XML \(error)")
            }
        }
    }
    
    class func parseLines(_ xml: XMLIndexer) {
        var routes = [MaxRouteLine]()
        for placemark in xml["kml"]["Document"]["Placemark"].all {
            do {
                let lineNode = try placemark["ExtendedData"]["Data"].withAttribute("name", "line")
                guard let line = lineNode["value"].element?.text else {
                    continue
                }
                guard MaxLine.lines.contains(line) else {
                    continue
                }
                guard let polyLine = placemark["LineString"]["coordinates"].element?.text else {
                    continue
                }
                guard let maxLine = MaxLine.forString(string: line) else {
                    continue
                }
                let routeLine = MaxRouteLine()
                routeLine.line = maxLine
                routeLine.internalPolyLine = polyLine
                routes.append(routeLine)
            } catch {
                print(error)
            }
        }
        saveRoutes(routes)
    }
    class func saveRoutes(_ routes: [MaxRouteLine]) {
        autoreleasepool {
            let context = Data.context()
            let oldRoutes = Data.objects(inContext: context, ofType: MaxRouteLine.self)
            Data.write(inContext: context) {
                context.delete(oldRoutes)
                context.add(routes)
            }
        }
    }
}

enum MaxLine: Int, EnumCollection {
    case blue
    case green
    case yellow
    case red
    case orange
    case blueGreen
    case blueGreenRed
    case blueGreenRedYellow
    case blueRed
    case greenOrange
    case greenYellow
    case orangeALoopBLoop
    
    static var lines: [String] {
        return allValues.map {
            $0.stringValue
        }
    }
    
    var stringValue: String {
        switch self {
        case .blue:
            return "B"
        case .green:
            return "G"
        case .yellow:
            return "Y"
        case .red:
            return "R"
        case .orange:
            return "O"
        case .blueGreen:
            return "BG"
        case .blueGreenRed:
            return "BGR"
        case .blueGreenRedYellow:
            return "BGRY"
        case .blueRed:
            return "BR"
        case .greenOrange:
            return "GO"
        case .greenYellow:
            return "GY"
        case .orangeALoopBLoop:
            return "O/AL/BL"
        }
    }
    
    static func forString(string: String) -> MaxLine? {
        return allValues.filter {
            $0.stringValue == string
        }.first
    }
}
