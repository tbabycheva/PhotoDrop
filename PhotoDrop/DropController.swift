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
        guard let currentPhotoDropUser = PhotoDropUserController.shared.currentPhotoDropUser else { return }
        let drop = Drop(title: title, dropperUserId: currentPhotoDropUser.getRecord().recordID, timestamp: timestamp, numberOfLikes: 0, location: location, image: image)
        drop.push()
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
        if drop.hasDetailDrop {
            completion (drop)
        }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        //hasLiked
        DropLikeController.shared.pullDropLike(for: drop) { (dropLike) in
            drop.hasLiked = dropLike != nil
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        
        //dropperUsername
        PhotoDropUserController.shared.pullUserWith(userRecordID: drop.dropperUserId) { (photoDropUser) in
            guard let photoDropUser = photoDropUser else { dispatchGroup.leave(); return }
            drop.dropperUserName = photoDropUser.username
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(drop)
        }
    }
}

