//
//  ViewController.swift
//  Blockspot
//
//  Created by Alessandro Bonardi on 15/10/2016.
//  Copyright © 2016 Alessandro Bonardi. All rights reserved.
//

import Cocoa
import MapKit

var WorkSpaces: [WorkSpace]? = nil

class ViewController: NSViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 500


    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .restricted || status == .denied {
            return
        }
        
        //self.locationManager.requestWhenInUseAuthorization()
        
        self.mapView.delegate = self
        self.locationManager.startUpdatingLocation()

        
        self.mapView.isPitchEnabled = true
        self.mapView.showsBuildings = true
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.mapView.showsUserLocation = true

        
        
        if locationManager.location != nil {
            centerMapOnLocation(location: self.mapView.userLocation.location!)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(
            location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorized, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        default:
            break
        }
        
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        self.mapView.centerCoordinate = (userLocation.location?.coordinate)!
    }
}
