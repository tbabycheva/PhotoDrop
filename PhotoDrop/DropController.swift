//
//  DropController.swift
//  PhotoDrop
//
//  Created by handje on 7/25/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CloudKit
import UIKit
import MapKit

class DropController {
    
    let shared = DropController()
    var drops = [Drop]()
    let dropsPullNotification = Notification.Name(rawValue: "dropPullNotifiaction")
    
    init() {
        
    }
    
    func createDropWith(title: String, timestamp: Date, location: CLLocationCoordinate2D, image: UIImage, completion: ((Drop) -> Void)?) {
        let drop = Drop(title: title, dropperUserId: CKRecordID(recordName: "currentUser"), timestamp: timestamp, numberOfLikes: 0, location: location, image: image)
        drop.push()
    }
    
    func pullDropsWith(region: MKCoordinateRegion) {
        let maxLong = region.center.longitude + region.span.longitudeDelta / 2
        let minLong = region.center.longitude - region.span.longitudeDelta / 2
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2
        let minLat = region.center.latitude + region.span.latitudeDelta / 2
        
        drops = []
        let predicateMinLong = NSPredicate(format: "min <= %@", minLong)
        let predicateMaxLong = NSPredicate(format: "max >= %@", maxLong)
        let predicateMinLat = NSPredicate(format: "min <= %@", minLat)
        let predicateMaxLat = NSPredicate(format: "max >= %@", maxLat)
        
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [predicateMinLong, predicateMaxLong, predicateMinLat, predicateMaxLat])
        
        Drop.pull(predicate: predicate, objectsPerPage: 10, pulledObject: { (drop) in
            self.drops.append(drop)
        }, pageFinished: { _ in NotificationCenter.default.post(name: self.dropsPullNotification, object: self) }, completion: nil)
    }
    
    func hasLikedDrop() {
        
    }
    
    func hasReportedDrop() {
        
    }
}
