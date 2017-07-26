//
//  CurrentLocationController.swift
//  PhotoDrop
//
//  Created by Micah Bunting on 7/26/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CoreLocation

class CurrentLocationController {

  static let shared = CurrentLocationController()

  let locationManager = CLLocationManager()

  var location: CLLocationCoordinate2D? {
    return locationManager.location?.coordinate
  }

  private init() {
  }
}
