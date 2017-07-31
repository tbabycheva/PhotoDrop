//
//  MapViewController.swift
//  PhotoDrop
//
//  Created by Kenny Peterson on 7/24/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    var drops: [Drop] = [] {
        didSet {
            showGems()
        }
    }

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    
    var locationManager: CLLocationManager!
    
    var sourceLocation: CLLocationCoordinate2D?{
        didSet {
            showRoute()
        }
    }
    
    var destinationLocation: MKAnnotation?{
        didSet {
            showRoute()
        }
    }
    
    var route: MKRoute?
    
    var annotationSelected: MKAnnotation?
        
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsUserLocation = true
        
        // Show current user location
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // Tap map to clear route
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        singleTapRecognizer.delegate = self
        singleTapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTapRecognizer)
    }
    
    // MARK: Gesture Recognition - Displaying / Dismissing Routes and Bubbles
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return false}
        if view.isKind(of: MKAnnotationView.self) {
            return false
        } else {
            return true
        }
    }
    
    func mapTapped() {
        if annotationSelected == nil {
            destinationLocation = nil
        } else {
            annotationSelected = nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else { return }
        annotationSelected = annotation
        guard let destinationLocation = destinationLocation else { return }
        if destinationLocation === annotation {
            return
        }
        
        // remove the route to the previous annotation
        self.destinationLocation = nil
    }
    
    // MARK: Action Functions
    
    func showDistanceButtonTapped() {
        destinationLocation = annotationSelected
    }

    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
}


// MARK: Current User Location

extension MapViewController {
    
    // Get current user location coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let sourceLocation = manager.location?.coordinate else { return }
        self.sourceLocation = sourceLocation
        
        let span = MKCoordinateSpanMake(1.2, 1.2)
        let region = MKCoordinateRegionMake(sourceLocation, span)
        mapView.setRegion(region, animated: true)
        
        manager.stopUpdatingLocation()
    }
}


// MARK: Creating and Displaying Gems

extension MapViewController {
    
    func showGems() {

        // Annotation = pin
        let annotations: [MKPointAnnotation] = drops.map {

            let annotation = MKPointAnnotation()
            annotation.title = $0.title

            annotation.coordinate =  $0.location
            return annotation
        }

        DispatchQueue.main.async {
            // show pins on the map
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        }
    }
}

// MARK: - Customizing Gems

extension MapViewController {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyGem"
        
        // exclude the annotation for current user location
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        var annotationView:MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "gold")
            
            // Pin thumbnail setup
            let showDistanceButton = UIButton(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
            showDistanceButton.setImage(UIImage(named: "directions-icon"), for: .normal)
            showDistanceButton.addTarget(self, action: #selector(showDistanceButtonTapped), for: .touchUpInside)
            annotationView?.leftCalloutAccessoryView = showDistanceButton
        }
        
        return annotationView
    }
}

// MARK: Creating and Displaying Routes

extension MapViewController {
    
    func showRoute() {
        
        guard let sourceLocation = sourceLocation else { return }
        
        if let route = route {
            self.mapView.remove(route.polyline)
        }
        
        guard let destinationLocation = destinationLocation else { return }
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation.coordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
       
        // Compute the route
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            // The region is set so both locations will be visible
            self.route = response.routes[0]
            self.mapView.add(response.routes[0].polyline, level: MKOverlayLevel.aboveRoads)
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    // Return the renderer object which will be used to draw the route on the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        DropController.shared.pullDrops(at: mapView.region, amount: 10) {
          [weak self] drops in
          self?.drops = drops
        }
    }
}

