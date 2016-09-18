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
        return Data.objects(Vehicle.self)
    }()
    var notificationToken: NotificationToken? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        let region = Location.manager.region
        mapView.region = mapView.regionThatFits(MKCoordinateRegionMakeWithDistance(region.center, region.radius * 2, region.radius * 2))
        mapView.delegate = self
        
        notificationToken = unfilteredDataSource.addNotificationBlock { [weak self] changes in
            guard let mapView = self?.mapView else {
                return
            }
            switch changes {
            case .Initial:
                break
//                tableView.reloadData()
            case .Update(_, let deletions, let insertions, let modifications):
                self?.updateAnnotations()
                break
            case .Error(let error):
                print(error)
            }
        }
        updateAnnotations()
    }
    
    func dataSource() -> [Vehicle] {
        return unfilteredDataSource.filter { vehicle -> Bool in
            Location.manager.region.containsCoordinate(vehicle.location)
        }
    }
    
    func updateAnnotations() {
        for vehicle in unfilteredDataSource {
            let annotation: VehicleAnnotation
            if let existing = annotationForVehicle(vehicle) {
                annotation = existing
            }
            else {
                annotation = VehicleAnnotation(id: vehicle.id)
                mapView.addAnnotation(annotation)
            }
            UIView.animateWithDuration(Vehicle.pollingInterval) {
                annotation.coordinate = vehicle.location
                let annotationView = self.mapView.viewForAnnotation(annotation)
                annotationView?.transform = CGAffineTransformMakeRotation(vehicle.bearing.toRadians() - (CGFloat(M_PI) / 2))
            }
        }
    }
    
    func annotationForVehicle(vehicle: Vehicle) -> VehicleAnnotation? {
        let vehicleAnnotations = mapView.annotations.flatMap { $0 as? VehicleAnnotation }
        return vehicleAnnotations.filter { $0.vehicleId == vehicle.id }.first
    }
    
}

extension TrimetMapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case let vehicleAnnotation as VehicleAnnotation:
            let annotationView: VehicleAnnotationView
            if let existing = mapView.dequeueReusableAnnotationViewWithIdentifier("annotation") as? VehicleAnnotationView {
                annotationView = existing
            }
            else {
                annotationView = VehicleAnnotationView(annotation: vehicleAnnotation, reuseIdentifier: "annotation")
            }
            if let vehicle = Data.objectForPrimaryKey(Vehicle.self, key: vehicleAnnotation.vehicleId) {
                if let route = vehicle.route {
                    annotationView.labelText = route.compactLabel
                    annotationView.routeType = route.routeType
                }
            }
            return annotationView
        default:
            break
        }
        return nil
    }
}