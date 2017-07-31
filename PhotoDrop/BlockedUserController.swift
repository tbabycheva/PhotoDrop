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
    
   
    func pushBlockedUser(blockedUsername: String, blockedRecordID: CKRecordID, blockerUsername: String, blockerRecordID: CKRecordID) {
        
        CKContainer.default().fetchUserRecordID { (blockedCloudKitRecordID, error) in
            
            guard let blockedCloudKitRecordID = blockedCloudKitRecordID else { return }
            self.blockedCloudKitRecordID = blockedCloudKitRecordID
            
            let blockedUser = BlockedUser(blockedUsername: blockedUsername, blockedRecordID: blockedRecordID, blockerUsername: blockerUsername, blockerRecordID: blockerRecordID)
            
            blockedUser.push()
        }
    }
}
