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
    
    
    
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
    }

}
