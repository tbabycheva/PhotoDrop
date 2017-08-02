//
//  BlockedUserController.swift
//  PhotoDrop
//
//  Created by handje on 7/27/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CloudKit

class BlockedUserController {
    
    static let shared = BlockedUserController()
    var blockedUsers: [BlockedUser]?
    
    
    func blockUser(of drop: Drop) { 
        
        CKContainer.default().fetchUserRecordID { (blockerCloudKitRecordID, error) in
            guard let blockerCloudKitRecordID = blockerCloudKitRecordID else { return }
            
            let blockedUser = BlockedUser(blockedRecordID: drop.dropperUserId, blockerRecordID: blockerCloudKitRecordID)
            
            blockedUser.push()
            
            self.blockedUsers?.append(blockedUser)
        }
    }
    
    func pullBlockedUsers(completion: @escaping ([BlockedUser]?) -> Void) {
        
        if let blockedUsers = blockedUsers {
            completion(blockedUsers)
            return
        }
        
        CKContainer.default().fetchUserRecordID { (blockerCloudKitRecordID, error) in
            
            guard let blockerCloudKitRecordID = blockerCloudKitRecordID else { return }
            
            let blockerUserReference = CKReference(recordID: blockerCloudKitRecordID, action: .deleteSelf)
            
            let predicate = NSPredicate(format: "blockerRecordID = %@", blockerUserReference)
            
            BlockedUser.pull(predicate: predicate, completion: { (blockedUsers, error) in
                self.blockedUsers = blockedUsers
                completion(blockedUsers)
            })
        }
    }
}
