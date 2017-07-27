//
//  CurrentLocationController.swift
//  PhotoDrop
//
//  Created by Micah Bunting on 7/26/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CoreLocation
import AudioToolbox

class CurrentLocationController: NSObject {

  let locationUpdatedNotification = Notification.Name(rawValue: "locationUpdatedNotification")
  let RegionEnteredNotification = Notification.Name(rawValue: "RegionEnteredNotification")

  static let shared = CurrentLocationController()

  let locationManager = CLLocationManager()

  var location: CLLocationCoordinate2D? {
    return locationManager.location?.coordinate
  }

  private override init() {
    super.init()

    locationManager.requestAlwaysAuthorization()

    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 5.0

    locationManager.delegate = self
    locationManager.startUpdatingLocation()

    enable()
  }

  fileprivate func enable() {
    let status = CLLocationManager.authorizationStatus()
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      if CLLocationManager.locationServicesEnabled() {
        locationManager.startUpdatingLocation()
      } else {
        print("locationServices are not enabled")
      }

      if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
      } else {
        print("Geofencing is not supported on this device!")
        return
      }
    }
  }
}

extension CurrentLocationController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    NotificationCenter.default.post(name: self.locationUpdatedNotification, object: self)
  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    NotificationCenter.default.post(name: self.RegionEnteredNotification, object: self)
  }

  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Monitoring failed for region with identifier: \(region!.identifier)")
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location Manager failed with the following error: \(error)")
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    enable()
  }
}
