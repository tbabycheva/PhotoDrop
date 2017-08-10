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
import AVFoundation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties and Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var inRangeButton: UIButton!
    
    var isWaitingToCenterOnLocation = true
    let centerOnLocationSpan = MKCoordinateSpanMake(0.01, 0.01)
    
    var sightCircle: MKCircle? {
        willSet {
            guard let sightCircle = sightCircle else {
                return
            }
            DispatchQueue.main.async {
                self.mapView.remove(sightCircle)
            }
        }
        didSet {
            guard let sightCircle = sightCircle else {
                return
            }
            DispatchQueue.main.async {
                self.mapView.add(sightCircle)
            }
        }
    }
    
    var sourceLocation: CLLocationCoordinate2D?{
        didSet {
            showRoute()
        }
    }
    
    var destinationLocation: Drop? {
        willSet {
            destinationLocation?.subtitle = nil
        }
        didSet {
            showRoute()
        }
    }
    
    var route: MKRoute?
    
    var annotationSelected: Drop?
    
    let systemSoundID: SystemSoundID = 1107
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.showsUserLocation = true
        
        centerOnLocation()
        showInRangeButton()
        
        // Show current user location
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLocaiton),
                                               name: CurrentLocationController.shared.locationUpdatedNotification,
                                               object: nil
        )
        
        // Show / hide inRange button
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showInRangeButton),
                                               name: DropController.shared.dropsInRangeWereUpdatedNotification,
                                               object: nil)
        
        // Tap map to clear route
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        singleTapRecognizer.delegate = self
        singleTapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTapRecognizer)
    }
    
    func updateLocaiton() {
        guard let location = CurrentLocationController.shared.location else {
            return
        }
        sightCircle = MKCircle(center: location, radius: 200)
        sourceLocation = location
        
        if isWaitingToCenterOnLocation {
            isWaitingToCenterOnLocation = false
            
            let region = MKCoordinateRegionMake(location, centerOnLocationSpan)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func showInRangeButton() {
        DispatchQueue.main.async {
            if DropController.shared.dropsInRange.count >= 1 {
                if self.inRangeButton.isHidden == true {
                    self.inRangeButton.isHidden = false
                    AudioServicesPlaySystemSound (self.systemSoundID)
                    self.animateButton()
                } else {
                    self.inRangeButton.isHidden = false
                }
            } else {
                self.inRangeButton.isHidden = true
            }
        }
    }
    
    func centerOnLocation() {
        isWaitingToCenterOnLocation = true
        updateLocaiton()
    }
    
    func mapTapped() {
        if annotationSelected == nil {
            destinationLocation = nil
        } else {
            annotationSelected = nil
        }
    }
}


// MARK: - Creating and Displaying Gems

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
            annotationView?.image = UIImage(named: "diamond-gold-shadow")
            
            // Pin thumbnail - Left Detail
            let showDistanceButton = UIButton(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
            showDistanceButton.setImage(UIImage(named: "directions-button"), for: .normal)
            showDistanceButton.addTarget(self, action: #selector(showDistanceButtonTapped), for: .touchUpInside)
            annotationView?.leftCalloutAccessoryView = showDistanceButton
            
            // Pin thumbnail - Right Detail
            let detailPhotoViewButton = UIButton(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
            detailPhotoViewButton.setImage(UIImage(named: "photo-detail-button"), for: .normal)
            detailPhotoViewButton.setImage(#imageLiteral(resourceName: "photo-detail-not-available"), for: .disabled)
            detailPhotoViewButton.addTarget(self, action: #selector(photoDetailButtonTapped), for: .touchUpInside)
            annotationView?.rightCalloutAccessoryView = detailPhotoViewButton
            
            // prevent taps on annotationView from triggering tap on map
            let TapRecognizer = UITapGestureRecognizer()
            annotationView?.addGestureRecognizer(TapRecognizer)
        }
        
        // Photo detail access
        if let detailPhotoViewButton = annotationView?.rightCalloutAccessoryView as? UIButton {
            if let annotationSelected = annotation as? Drop {
                if DropController.shared.dropsInRange.contains(where: {annotationSelected.getRecord().recordID.recordName == $0.getRecord().recordID.recordName}) {
                    detailPhotoViewButton.isEnabled = true
                } else {
                    detailPhotoViewButton.isEnabled = false
                }
            }
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
        directionRequest.transportType = .walking
        
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
            measurementFormatter.unitStyle = .short
            let distanceString = measurementFormatter.string(from: distance)
            self.destinationLocation?.subtitle = distanceString
        }
    }
}


// MARK: - Action Functions

extension MapViewController {
    
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        centerOnLocation()
    }
    
    func showDistanceButtonTapped() {
        destinationLocation = annotationSelected
    }
    
    func photoDetailButtonTapped() {
        guard let annotationSelected = annotationSelected else {
            return
        }
        guard let destination = UIStoryboard.init(name: "Photo", bundle: nil).instantiateInitialViewController() as? PhotoViewController else {
            return
        }
        DropController.shared.pullDetailDropWith(for: annotationSelected) {
            (drop) in
            destination.drop = drop
            self.present(destination, animated: true, completion: nil)
        }
    }
    
    // Gem tapped
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let drop = view.annotation as? Drop else { return }
        annotationSelected = drop
        guard let destinationLocation = destinationLocation else { return }
        if destinationLocation === drop {
            return
        }
        
        // remove the route to the previous annotation
        self.destinationLocation = nil
    }
    
    
    // Display gems based on location
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        DropController.shared.pullDrops(at: mapView.region, amount: 10) {
            [weak self] drops in
            guard let annotations = mapView.annotations.filter({$0 is Drop}) as? [Drop] else { return }
            update( annotations,
                    to: drops,
                    equals: {
                        $0.getRecord().recordID.recordName == $1.getRecord().recordID.recordName
            },
                    remove: { drop in
                        DispatchQueue.main.async {
                            self?.mapView.removeAnnotation(drop)
                        }
            },
                    add: { drop in
                        DispatchQueue.main.async {
                            self?.mapView.addAnnotation(drop)
                        }
            }
            )
        }
    }
}

// MARK: - Overlays
extension MapViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Display the route
        if let overlay = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 4.0
            return renderer
        }
            
        // Display inRange circle
        else if let overlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.cyan.withAlphaComponent(0.75)
            renderer.lineWidth = 2.0
            return renderer
        }
        return MKOverlayRenderer()
    }
}


// MARK: - Gesture Recognition - Displaying / Dismissing Routes and Bubbles
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

// MARK: - Animations
extension MapViewController {
    func animateButton() {
       // AudioServicesPlaySystemSound(bubbleSound)
        inRangeButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 5.5,
                       options: .allowUserInteraction,
                       animations: { [weak self] in
                        self?.inRangeButton.transform = .identity
        },
                       completion: nil
        )
    }
}











