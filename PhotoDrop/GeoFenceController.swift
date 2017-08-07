//
//  GeoFenceController.swift
//  PhotoDrop
//
//  Created by Micah Bunting on 7/26/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import MapKit
class GeoFenceController {
  let spanRadius = 1000.0 /* Meters */
  private let distanceToUpdateTrackedDrops = 500.0 /* Meters */
  let dropRange = 200.0 /* Meters */

  static let shared = GeoFenceController()
  /*
  private var lastLocationtrackedDropsWhereUpdated: CLLocationCoordinate2D?

  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated), name: CurrentLocationController.shared.locationUpdatedNotification, object: nil)
  }

  @objc func locationUpdated() {
    guard let location = CurrentLocationController.shared.location else {
      return
    }
    if let lastLocationtrackedDropsWhereUpdated = lastLocationtrackedDropsWhereUpdated {
      let coordinate₀ = CLLocation(
        latitude: lastLocationtrackedDropsWhereUpdated.latitude,
        longitude: lastLocationtrackedDropsWhereUpdated.longitude
      )
      let coordinate₁ = CLLocation(
        latitude: location.latitude,
        longitude: location.longitude
      )
      if coordinate₀.distance(from: coordinate₁) < distanceToUpdateTrackedDrops {
        return
      }
    }
    self.lastLocationtrackedDropsWhereUpdated = location

    DropController.shared.pullDrops(
      at: MKCoordinateRegionMake(
        location,
        MKCoordinateSpan(
          latitudeDelta: spanRadius / 111000.0 /* degrees to meters for latitude */,
          longitudeDelta: spanRadius / 111000.0 * cos(Double.pi * location.latitude / 180.0)
        )
      ),
      amount: 20
    ) {
    (drops) in
      update(
        Array(CurrentLocationController.shared.locationManager.monitoredRegions),
        to: drops.map {
          CLCircularRegion(center: $0.location, radius: self.dropRange, identifier: $0.getRecord().recordID.recordName)
        },
        equals: {$0.identifier == $1.identifier},
        remove: {CurrentLocationController.shared.locationManager.stopMonitoring(for: $0)},
        add: {CurrentLocationController.shared.locationManager.startMonitoring(for: $0)}
      )
    }
  }*/
}
