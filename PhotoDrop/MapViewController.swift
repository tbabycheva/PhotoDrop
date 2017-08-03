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

class MapViewController: UIViewController {

    let centerOnLocationSpan = MKCoordinateSpanMake(0.1, 0.1)

    @IBOutlet weak var mapView: MKMapView!

    var annotations:[Drop:MKPointAnnotation] = [:]
    var drops: [Drop] = [] {
        didSet {
            DispatchQueue.main.async {
                update(
                    oldValue,
                    to: self.drops,
                    equals: {$0.getRecord().recordID.recordName == $1.getRecord().recordID.recordName},
                    remove: {
                        if let annotation = self.annotations[$0] {
                            self.mapView.removeAnnotation(annotation)
                        }
                        self.annotations[$0] = nil
                    },
                    unchanged: {
                        if $0 != $1 {
                            self.annotations[$1] = self.annotations[$0]
                            self.annotations[$0] = nil
                        }
                    },
                    add: {
                        let annotation = MKPointAnnotation()
                        annotation.title = $0.title
                        annotation.coordinate = $0.location
                        self.annotations[$0] = annotation
                        self.mapView.addAnnotation(annotation)
                    }
                )
            }
        }

    }

    var isWaitingToCenterOnLocation = true

    var annotationSelected: MKPointAnnotation?

    var sourceLocation: CLLocationCoordinate2D?{
        didSet {
            showRoute()
        }
    }

    var destinationLocation: MKPointAnnotation? {
        willSet {
            destinationLocation?.subtitle = ""
        }
        didSet {
            showRoute()
        }
    }

    var route: MKRoute?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsUserLocation = true
        
        // Show current user location

        NotificationCenter.default.addObserver(
            self, selector: #selector(updateLocaiton),
            name: CurrentLocationController.shared.locationUpdatedNotification,
            object: nil
        )

        centerOnLocation()


        // Tap map to clear route
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        singleTapRecognizer.delegate = self
        singleTapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTapRecognizer)
    }

    func mapTapped() {
        if annotationSelected == nil {
            destinationLocation = nil
        } else {
            annotationSelected = nil
        }
    }

    func centerOnLocation() {
        isWaitingToCenterOnLocation = true
        updateLocaiton()
    }

    func updateLocaiton() {
        guard let location = CurrentLocationController.shared.location else {
          return
        }

        sourceLocation = location

        if isWaitingToCenterOnLocation {
            isWaitingToCenterOnLocation = false

            let region = MKCoordinateRegionMake(location, centerOnLocationSpan)
            mapView.setRegion(region, animated: true)
        }
    }

    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        centerOnLocation()
    }

    // MARK: Creating and Displaying Routes
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

            let distance = Measurement(value: response.routes[0].distance, unit: UnitLength.meters)
            let measurementFormatter = MeasurementFormatter()
            measurementFormatter.unitStyle = .medium
            let distanceString = measurementFormatter.string(from: distance)
            self.destinationLocation?.subtitle = distanceString
        }
    }
}

extension MapViewController: MKMapViewDelegate {
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

            // prevent taps on annotationView from triggering tap on map
            let TapRecognizer = UITapGestureRecognizer()
            annotationView?.addGestureRecognizer(TapRecognizer)
        }
        
        return annotationView
    }

    func showDistanceButtonTapped() {
        destinationLocation = annotationSelected
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation as? MKPointAnnotation else { return }
        annotationSelected = annotation
        guard let destinationLocation = destinationLocation else { return }
        if destinationLocation === annotation {
            return
        }
        
        // remove the route to the previous annotation
        self.destinationLocation = nil
    }

    // Display route on the map
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


// MARK: Gesture Recognition - Displaying / Dismissing Routes and Bubbles
extension MapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return false}
        if view.isKind(of: MKAnnotationView.self) {
            return false
        } else {
            return true
        }
    }
}
