//
//  DropLikeController.swift
//  PhotoDrop
//
//  Created by handje on 7/27/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CloudKit
import UIKit
import MapKit

class DropLikeController {
    
    static let shared = DropLikeController()  
    
    func pullDropLike(for drop: Drop, completion: @escaping (DropLike?) -> Void) {
        
        let dropRecord = drop.getRecord()
        let dropReference = CKReference(recordID: dropRecord.recordID, action: .deleteSelf)
        let dropPredicate = NSPredicate(format: "dropId == %@", dropReference)
        
        guard let user = PhotoDropUserController.shared.currentPhotoDropUser else { return }
        let userRecord = user.getRecord()
        let userReference = CKReference(recordID: userRecord.recordID, action: .deleteSelf)
        let userPredicate = NSPredicate(format: "likerUserId  == %@", userReference)
        
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [dropPredicate, userPredicate])
        
        DropLike.pull(predicate: predicate, objectsPerPage: 1, completion: { (dropLike, error) in
            completion(dropLike?.first)
        })
    }
    
    func createDropLike(for drop: Drop, completion: (() -> Void)? = nil) -> DropLike? {
        guard let user = PhotoDropUserController.shared.currentPhotoDropUser else { return nil }
        let userRecord = user.getRecord()
        let dropLike = DropLike(likerUserId: userRecord.recordID, dropId: drop.getRecord().recordID)
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        dropLike.push { (_, _) in
            dispatchGroup.leave()
        }
        
        
        dispatchGroup.enter()
        user.numberOfGivenDropLikes += 1
        user.numberOfRecievedDropLikes += 1
        user.push { (_, _) in
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        drop.numberOfLikes += 1
        drop.push { (_, _) in
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: DispatchQueue.global()) { 
            completion?() 
        }
        
        return dropLike
    }
    
    func deleteDropLike(for drop: Drop, completion: (() -> Void)? = nil) {
        guard let user = PhotoDropUserController.shared.currentPhotoDropUser else { return }
        pullDropLike(for: drop) { (dropLike) in
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            dropLike?.delete(completion: { (_, _) in
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            user.numberOfGivenDropLikes -= 1
            user.numberOfRecievedDropLikes -= 1
            user.push(completion: { (_, _) in
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            drop.numberOfLikes -= 1
            drop.push(completion: { (_, _) in
                dispatchGroup.leave()
            })
            
            dispatchGroup.notify(queue: DispatchQueue.global(), execute: { 
                completion?()
            })
        }
    }
}
