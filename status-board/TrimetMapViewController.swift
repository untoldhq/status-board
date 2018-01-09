//
//  TrimetMapViewController.swift
//  status-board
//
//  Created by Sam Ingle on 9/17/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import RealmSwift

class TrimetMapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    lazy var unfilteredDataSource: Results<Vehicle>! = {
        return Data.objects(inContext: Data.context(), ofType: Vehicle.self)
    }()
    
    lazy var maxLinesDataSource: Results<MaxRouteLine>! = {
        return Data.objects(inContext: Data.context(), ofType: MaxRouteLine.self)
    }()
    
    var notificationToken: NotificationToken? = nil
    var routeToken: NotificationToken? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        let region = Location.manager.region
        mapView.region = mapView.regionThatFits(MKCoordinateRegionMakeWithDistance(region.center, region.radius * 2, region.radius * 2))
        mapView.delegate = self
        
        notificationToken = unfilteredDataSource.observe { [weak self] changes in
            guard self?.mapView != nil else {
                return
            }
            switch changes {
            case .initial:
                break
//                tableView.reloadData()
            case .update(_, _, _, _):
                self?.updateAnnotations()
                break
            case .error(let error):
                print(error)
            }
        }
        
        routeToken = maxLinesDataSource.observe { [weak self] changes in
            guard self?.mapView != nil else {
                return
            }
            switch changes {
            case .initial:
                break
            //                tableView.reloadData()
            case .update(_, _, _, _):
                self?.updateRouteLines()
                break
            case .error(let error):
                print(error)
            }
        }
        
        updateAnnotations()
    }
    
    func dataSource() -> [Vehicle] {
        return unfilteredDataSource.filter { vehicle -> Bool in
            Location.manager.region.contains(vehicle.location)
        }
    }
    
    func updateRouteLines() {
        for routeLine in maxLinesDataSource {
            for i in 0..<routeLine.colors.count {
                let line = RoutePolyline(coordinates: routeLine.polyLine, count: routeLine.polyLine.count)
                line.routeColors = routeLine.colors
                line.routeLine = routeLine.line
                line.routePhase = i
                mapView.add(line)
            }
        }
    }
    
    func updateAnnotations() {
        for vehicle in unfilteredDataSource {
            guard vehicle.route != nil else {
                continue
            }
            let annotation: VehicleAnnotation
            if let existing = annotationForVehicle(vehicle) {
                annotation = existing
            }
            else {
                annotation = VehicleAnnotation(id: vehicle.id)
                mapView.addAnnotation(annotation)
            }
            UIView.animate(withDuration: Vehicle.pollingInterval) {
                annotation.coordinate = vehicle.location
                let annotationView = self.mapView.view(for: annotation)
                annotationView?.transform = CGAffineTransform(rotationAngle: vehicle.bearing.toRadians() - (CGFloat(Float.pi) / 2))
            }
        }
    }
    
    func annotationForVehicle(_ vehicle: Vehicle) -> VehicleAnnotation? {
        let vehicleAnnotations = mapView.annotations.flatMap { $0 as? VehicleAnnotation }
        return vehicleAnnotations.filter { $0.vehicleId == vehicle.id }.first
    }
    
}

extension TrimetMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case let vehicleAnnotation as VehicleAnnotation:
            let annotationView: VehicleAnnotationView
            if let existing = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation") as? VehicleAnnotationView {
                annotationView = existing
            }
            else {
                annotationView = VehicleAnnotationView(annotation: vehicleAnnotation, reuseIdentifier: "annotation")
            }
            if let vehicle = Data.object(inContext: Data.context(), ofType: Vehicle.self, forPrimaryKey: vehicleAnnotation.vehicleId) {
                if let route = vehicle.route {
                    annotationView.labelText = route.compactLabel
                    annotationView.routeType = route.routeType
                    annotationView.routeColor = route.color
                } else {
                    return nil
                }
                annotationView.tag = vehicle.id
            }
            return annotationView
        default:
            break
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let line = overlay as? RoutePolyline {
            let lineRenderer = MKPolylineRenderer(overlay: overlay)
            lineRenderer.strokeColor = line.routeColors[line.routePhase]
            let gap: Int = 8 * (line.routeColors.count - 1)
            lineRenderer.lineDashPattern = [8, NSNumber(integerLiteral: gap)] // unpainted segment should be 0 for one color, 8 for two colors, 16 for three, and so on
            lineRenderer.lineCap = .butt
            lineRenderer.lineDashPhase = CGFloat(line.routePhase * 8)
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        
        return MKOverlayRenderer()
    }
}
