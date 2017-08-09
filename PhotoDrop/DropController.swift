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
    let dropsInRangeWereUpdatedNotification = Notification.Name(rawValue: "dropsInRangeWereUpdatedNotification")
    private(set) var dropsInRange: [Drop] = []
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateInRangeDrops), name: CurrentLocationController.shared.locationUpdatedNotification, object: nil)
    }
    
    func createDropWith(title: String, timestamp: Date, location: CLLocationCoordinate2D, image: UIImage, completion: ((Drop) -> Void)?) {
        guard let currentPhotoDropUser = PhotoDropUserController.shared.currentPhotoDropUser else { return }
        let drop = Drop(title: title, dropperUserId: currentPhotoDropUser.getRecord().recordID, timestamp: timestamp, numberOfLikes: 0, location: location, image: image)
        drop.push()
        currentPhotoDropUser.numberOfDrops += 1
        currentPhotoDropUser.push() 
    }
    
    func pullDrops(at region: MKCoordinateRegion, amount: Int , completion: @escaping ([Drop]) -> Void) {
        
        BlockedUserController.shared.pullBlockedUsers { (blockedUsers) in
            let blockedUsersToExclude = blockedUsers?.map({ $0.blockedRecordID })
            guard let blockedUserPredicates = blockedUsersToExclude?.map({
                NSPredicate(
                    format: "dropperUserId != %@", CKReference(recordID: $0, action: .deleteSelf)
                )
            }) else { return }
            let blockedUsersPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: blockedUserPredicates)
            
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
                    blockedUsersPredicate
                ]
            )
            
            Drop.pull(
                predicate: predicate,
                desiredKeys: [
                    "title",
                    "dropperUserId",
                    "timestamp",
                    "numberOfLikes",
                    "latitude",
                    "longitude",
                ],
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
    }
    
    func pullDetailDropWith(for drop: Drop, completion: @escaping (Drop) -> Void) {
        if !dropsInRange.contains(drop) {
          if let drop = dropsInRange.first(where: {drop.getRecord().recordID.recordName == $0.getRecord().recordID.recordName}) {
            pullDetailDropWith(for: drop, completion: completion)
            return
          }
        }

        if drop.hasDetailDrop {
            completion (drop)
            return
        }

        let dispatchGroup = DispatchGroup()
        
        
        //hasLiked
        dispatchGroup.enter()
        DropLikeController.shared.pullDropLike(for: drop) { (dropLike) in
            drop.hasLiked = dropLike != nil
            dispatchGroup.leave()
        }
        
        
        //dropperUsername
        dispatchGroup.enter()
        PhotoDropUserController.shared.pullUserWith(userRecordID: drop.dropperUserId) { (photoDropUser) in
            guard let photoDropUser = photoDropUser else { dispatchGroup.leave(); return }
            drop.dropperUserName = photoDropUser.username
            dispatchGroup.leave()
        }

        
        //image
        dispatchGroup.enter()
        Drop.database.fetch(withRecordID: drop.getRecord().recordID) {
            (record, error) in
            defer {
                dispatchGroup.leave()
            }

            guard let record = record else {
                return
            }

            guard let imageAsset = record[Drop.Keys.image] as? CKAsset else {
                return
            }

            drop.imageAsset = imageAsset

            guard
                let data = NSData(contentsOf: imageAsset.fileURL),
                let image = UIImage(data: data as Data)
            else {
                return
            }

            drop.image = image
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(drop)
        }
    }

    private var currentlyUpdating = false
    @objc func updateInRangeDrops() {
        guard PhotoDropUserController.shared.currentPhotoDropUser != nil else { return }
        guard let currentLocation = CurrentLocationController.shared.location else {
          print("updateInRagneDrops in guard")
            return
        }

        if currentlyUpdating {
            return
        }
        currentlyUpdating = true

        let region = MKCoordinateRegion(center: currentLocation, span: MKCoordinateSpan(
            latitudeDelta: GeoFenceController.shared.spanRadius / 111000.0 /* degrees to meters for latitude */,
            longitudeDelta: GeoFenceController.shared.spanRadius / 111000.0 * cos(Double.pi * currentLocation.latitude / 180.0)
        ))
        var dropsInRange = [Drop]()
        pullDrops(at: region, amount: 20) { (drops) in
            let group = DispatchGroup()
            for drop in drops {
                group.enter()
                DropController.shared.pullDetailDropWith(for: drop, completion:{
                    (drop) in
                    dropsInRange.append(drop)
                    group.leave()
                })
            }
            
            group.notify(queue: DispatchQueue.main) {
                self.dropsInRange = dropsInRange 
                self.currentlyUpdating = false
                NotificationCenter.default.post(name: self.dropsInRangeWereUpdatedNotification, object: nil)
            }
        }
    }
}

