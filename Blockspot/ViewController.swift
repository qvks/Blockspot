//
//  ViewController.swift
//  Blockspot
//
//  Created by Alessandro Bonardi on 15/10/2016.
//  Copyright © 2016 Alessandro Bonardi. All rights reserved.
//

import Cocoa
import MapKit

var WorkSpaces: [WorkSpace] = [WorkSpace.init(radius: 200.0, location: CLLocationCoordinate2D(latitude: 53.3843472317644,
                                                                            longitude: -1.4787873210134975), name: "Huxley308"),
                   WorkSpace.init(radius: 100.0, location: CLLocationCoordinate2D(latitude: 53.3793472317644,
                                                                            longitude: -1.485873210134975), name: "LibraryMeeting01")]



class ViewController: NSViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var addWorkspaceButton: NSButton!
    @IBOutlet var changeRadiusSlider: NSSlider!
    @IBOutlet var doneButton: DoneNSButton!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var instructionLabel: NSTextField!
    
    @IBOutlet weak var joinButton: NSButton!
    
    @IBAction func radiusSliderChanged(_ sender: AnyObject) {
        
        mapView.remove(mapView.overlays.last!)
        let circleOverlay = MKCircle(center: (locationManager.location?.coordinate)!, radius: changeRadiusSlider.doubleValue)
        mapView.add(circleOverlay)
        
    }
    
    @IBAction func joinButtonClicked(_ sender: AnyObject) {
        
        joinButton.isHidden = true
        //RUN THE SCRIPT
        
    }
    
    @IBAction func workspaceButtonClicked(_ sender: AnyObject) {
        print("yes!")
        changeRadiusSlider.isHidden = false
        changeRadiusSlider.isEnabled = true
        doneButton.isHidden = false
        doneButton.isEnabled = true
        nameTextField.isHidden = false
        nameTextField.isEnabled = true
        instructionLabel.isHidden = false
        
        let circleOverlay = MKCircle(center: (locationManager.location?.coordinate)!, radius: changeRadiusSlider.doubleValue)
        mapView.add(circleOverlay)
        
    }
    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        
        changeRadiusSlider.isHidden = true
        changeRadiusSlider.isEnabled = false
        doneButton.isHidden = true
        doneButton.isEnabled = false
        nameTextField.isHidden = true
        nameTextField.isEnabled = false
        instructionLabel.isHidden = true

        
        // ADD NEW WORKSPACE
        let workspace = WorkSpace(radius: changeRadiusSlider.doubleValue, location: (locationManager.location?.coordinate)!, name: nameTextField.stringValue)
        WorkSpaces.append(workspace)
        
        mapView.removeOverlays(mapView.overlays)
        drawCircles()
        
    }
    
    
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 500

    override func viewDidLoad() {
        
        
        let WB : WebsiteBlock = WebsiteBlock(list : ["www.zubair.com", "wwww.java.com"])
        WB.rewriteHostFile()
        super.viewDidLoad()
        self.locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        if status == .restricted || status == .denied {
            return
        }
        
        self.mapView.delegate = self
        self.mapView.showsBuildings = true
        locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        centerMapOnLocation(location: locationManager.location!)
        
        
        drawCircles()
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
            centerMapOnLocation(location: manager.location!)
        default:
            break
        }
        
    }
    
    func drawCircles() {
        for workSpace in WorkSpaces {
            print("bubu")
            let circleOverlay = MKCircle(center: workSpace.location, radius: workSpace.radius)
            mapView.add(circleOverlay)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = NSColor.red
        circleRenderer.alpha = 0.1
        return circleRenderer
    }

    override func mouseUp(with event: NSEvent) {
        var clickPoint = event.locationInWindow
        clickPoint.y = mapView.frame.height - clickPoint.y
        let clickCoordinate = mapView.convert(clickPoint, toCoordinateFrom: mapView)
        let clickLocation = CLLocation(latitude: clickCoordinate.latitude, longitude: clickCoordinate.longitude)
        for circle in mapView.overlays as! [MKCircle] {
            //print("ok")
            let centreCoordinate = circle.coordinate
            let centreLocation = CLLocation(latitude: centreCoordinate.latitude, longitude: centreCoordinate.longitude)
            //print(centreLocation)
            //print(clickLocation)
            //print(centreLocation.distance(from: clickLocation))
            if centreLocation.distance(from: clickLocation) < circle.radius {
                let circleRenderer = MKCircleRenderer(overlay: circle)
                circleRenderer.fillColor = NSColor.red
                circleRenderer.alpha = 0.5
                mapView.add(circle)
                print("OLE!!!")
                
                for workspace in WorkSpaces {
                    let workspaceLocation = CLLocation(latitude: workspace.location.latitude, longitude: workspace.location.longitude)
                    print(workspaceLocation)
                    print(centreLocation)
                    if workspace.location.latitude == centreCoordinate.latitude &&
                        workspace.location.longitude == centreCoordinate.longitude {
                        print("haha")
                        var annotation = MKPointAnnotation()
                        annotation.coordinate = workspace.location
                        annotation.title = workspace.name
                        mapView.addAnnotation(annotation)
                        mapView.selectAnnotation(annotation, animated: true)
                    }
                }
                
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //self.mapView.centerCoordinate = (userLocation.location?.coordinate)!
        //centerMapOnLocation(location: self.mapView.userLocation.location!)

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("oleeeee")
        
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let identifier = "annotation"
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            anView?.isEnabled = true
            anView?.canShowCallout = true
            
            joinButton.isHidden = false
            joinButton.isEnabled = true
            
            //let btn = NSButton()
            
            //btn.setButtonType(NSButtonType.momentaryPushIn)
            
            //anView?.rightCalloutAccessoryView = btn
            
        } else {
            anView?.annotation = annotation
        }
        return anView
    }
    

    

    
}
