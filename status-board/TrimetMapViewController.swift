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
    
    var unfilteredDataSource: Results<Vehicle>! = {
        let context = DataManager.context()
        return DataManager.objects(inContext: context, ofType: Vehicle.self)
    }()
    
    var notificationToken: NotificationToken? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        let region = LocationManager.manager.region
        mapView.region = mapView.regionThatFits(MKCoordinateRegionMakeWithDistance(region.center, region.radius * 2, region.radius * 2))
        mapView.delegate = self
        
        notificationToken = unfilteredDataSource.addNotificationBlock { [weak self] changes in
            guard (self?.mapView) != nil else {
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
        updateAnnotations()
    }
    
    func dataSource() -> [Vehicle] {
        return unfilteredDataSource.filter { vehicle -> Bool in
            LocationManager.manager.region.contains(vehicle.location)
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
                updatePosition(for: vehicle, with: annotation)
            }
            UIView.animate(withDuration: Vehicle.pollingInterval) {
                annotation.coordinate = vehicle.location
                let annotationView = self.mapView.view(for: annotation)
                annotationView?.transform = CGAffineTransform(rotationAngle: vehicle.bearing.toRadians() - (CGFloat(M_PI) / 2))
            }
        }
    }
    
    func annotationForVehicle(_ vehicle: Vehicle) -> VehicleAnnotation? {
        let vehicleAnnotations = mapView.annotations.flatMap { $0 as? VehicleAnnotation }
        return vehicleAnnotations.filter { $0.vehicleId == vehicle.id }.first
    }
    
    func updatePosition(for vehicle: Vehicle, with annotation: VehicleAnnotation) {
        let currentTime = Date().timeIntervalSince1970 * 1000.0
        if currentTime < vehicle.expiringTime {
            mapView.addAnnotation(annotation)
        }
        else {
            mapView.removeAnnotation(annotation)
        }
    }
    
}

extension TrimetMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case let vehicleAnnotation as VehicleAnnotation:
            let annotationView: VehicleAnnotationView
            let context = DataManager.context()
            if let existing = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation") as? VehicleAnnotationView {
                annotationView = existing
            }
            else {
                annotationView = VehicleAnnotationView(annotation: vehicleAnnotation, reuseIdentifier: "annotation")
            }
            
            if let vehicle = DataManager.object(inContext: context, ofType: Vehicle.self, forPrimaryKey: vehicleAnnotation.vehicleId) {
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
