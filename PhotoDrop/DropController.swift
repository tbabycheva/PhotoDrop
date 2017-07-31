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
    
    static let shared = DropController()
    let dropsPullNotification = Notification.Name(rawValue: "dropPullNotifiaction")
    var drops = [Drop]()
    
    init() {
        
    }
    
    func createDropWith(title: String, timestamp: Date, location: CLLocationCoordinate2D, image: UIImage, completion: ((Drop) -> Void)?) {
        let drop = Drop(title: title, dropperUserId: CKRecordID(recordName: "currentUser"), timestamp: timestamp, numberOfLikes: 0, location: location, image: image)
        drop.push()
    }
    
    func pullDrops(at region: MKCoordinateRegion, amount: Int , completion: @escaping ([Drop]) -> Void) {
        let maxLong = region.center.longitude + region.span.longitudeDelta / 2
        let minLong = region.center.longitude - region.span.longitudeDelta / 2
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2
        let minLat = region.center.latitude - region.span.latitudeDelta / 2
        
        var drops: [Drop] = []
        let predicateMinLong = NSPredicate(format: "longitude >= %@", NSNumber(value: minLong))
        let predicateMaxLong = NSPredicate(format: "longitude <= %@", NSNumber(value: maxLong))
        let predicateMinLat = NSPredicate(format: "latitude >= %@", NSNumber(value: minLat))
        let predicateMaxLat = NSPredicate(format: "latitude <= %@", NSNumber(value: maxLat))
        
        let predicate = NSCompoundPredicate.init(
            andPredicateWithSubpredicates: [
                predicateMinLong,
                predicateMaxLong,
                predicateMinLat,
                predicateMaxLat,
            ]
        )
        
        Drop.pull(
            predicate: predicate,
            objectsPerPage: amount,
            pulledObject: { (drop) in
              drops.append(drop)
            },
            pageFinished: { _ in
              completion(drops)
            }, completion: { _ in
              completion(drops)
            }
        )
    }
    
    func pullDetailDropWith(for drop: Drop, completion: @escaping (Drop) -> Void) {
        if drop.hasDetailDrop {
            completion (drop)
        }
        
        //image
//        let image = drop.recordDictionary.get
        
//        //hasLiked
        DropLikeController.shared.pullDropLike(for: drop) { (dropLike) in

        }
//
//        //dropperUsername
        PhotoDropUserController.shared.pullUserWith(userRecordID: drop.dropperUserId) { (dropperUserName) in
            <#code#>
        }
        
    }
}

