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
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Properties
    
    var locationManager: CLLocationManager!
    
    var sourceLocation: CLLocationCoordinate2D?{
        didSet {
        }
    }
    
    var destinationLocation: MKAnnotation?{
        didSet {
        }
    }
    
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
        
        showGems()
    }
    
    
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
}

// MARK: Creating and Displaying Gems

extension MapViewController {
    
    func showGems() {
        
        // Mock data
        struct Location {
            let title: String
            let location: CLLocationCoordinate2D
        }
        
        let locations = [
            Location(title: "Pfeifferhorn, UT", location: CLLocationCoordinate2D(latitude: 40.5336, longitude: -111.7060)),
            Location(title: "Donut Falls, UT", location: CLLocationCoordinate2D(latitude: 40.6495, longitude: -111.6590)),
            Location(title: "Antelope Island State Park, UT", location: CLLocationCoordinate2D(latitude: 40.9581, longitude: -112.2146))
        ]
        
        // Annotation = pin
        let annotations: [MKPointAnnotation] = locations.map {
            
            let annotation = MKPointAnnotation()
            annotation.title = $0.title
            
            annotation.coordinate =  $0.location
            return annotation
        }
        
        // show pins on the map
        self.mapView.showAnnotations(annotations, animated: true)
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
        }
        
        return annotationView
    }
}


