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
    var blockedCloudKitRecordID: CKRecordID?
    var blockedUser: BlockedUser?
    var blockedUsers: [BlockedUser]?
    
   
    func pushBlockedUser(blockedRecordID: CKRecordID, blockerRecordID: CKRecordID) {
        
        CKContainer.default().fetchUserRecordID { (blockedCloudKitRecordID, error) in
            
            guard let blockedCloudKitRecordID = blockedCloudKitRecordID else { return }
            self.blockedCloudKitRecordID = blockedCloudKitRecordID
            
            let blockedUser = BlockedUser(blockedRecordID: blockedRecordID, blockerRecordID: blockerRecordID)
            
            blockedUser.push()
        }
    }
    
    func pullBlockedUsers(completion: @escaping ([BlockedUser]?) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (blockerCloudKitRecordID, error) in
            
            guard let blockerCloudKitRecordID = blockerCloudKitRecordID else { return }
            
            let blockerUserReference = CKReference(recordID: blockerCloudKitRecordID, action: .deleteSelf)
            
            let predicate = NSPredicate(format: "blockerRecordID", blockerUserReference)
            
            BlockedUser.pull(predicate: predicate, completion: { (blockedUsers, error) in
                self.blockedUsers = blockedUsers
                completion(blockedUsers) 
            })
        }
    }
}
