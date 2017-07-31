//
//  BlockedUser.swift
//  PhotoDrop
//
//  Created by handje on 7/27/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CloudKit

class BlockedUser: CloudKitSyncable {
    
    var blockedUsername: String
    var blockedRecordID: CKRecordID
    
    var blockerUsername: String
    var blockerRecordID: CKRecordID
    
    init(blockedUsername: String, blockedRecordID: CKRecordID, blockerUsername: String, blockerRecordID: CKRecordID) {
        self.blockedUsername = blockedUsername
        self.blockedRecordID = blockedRecordID
        self.blockerUsername = blockerUsername
        self.blockerRecordID = blockerRecordID
    }
    
    /* CloudKitSyncable */
    var record: CKRecord?
    
    static let recordType = "BlockedUser" 
    
    static let database: CKDatabase = CKContainer.default().publicCloudDatabase
    
    private struct Keys {
        static let blockedUsername = "blockedUsername"
        static let blockedRecordID = "blockedRecordID"
        static let blockerUsername = "blockerUsername"
        static let blockerRecordID = "blockerRecordID"
    }
    
    var recordDictionary: [String : CKRecordValue] {
        return [
            BlockedUser.Keys.blockedUsername: blockedUsername as CKRecordValue,
            BlockedUser.Keys.blockedRecordID: CKReference(recordID: blockedRecordID, action: CKReferenceAction.deleteSelf),
            BlockedUser.Keys.blockerUsername: blockerUsername as CKRecordValue,
            BlockedUser.Keys.blockerRecordID: CKReference(recordID: blockerRecordID, action: CKReferenceAction.deleteSelf)
        ]
    }
    
    convenience required init?(record: CKRecord) {
        guard let blockedUsername = record[BlockedUser.Keys.blockedUsername] as? String,
            let blockedUserRecord = record[BlockedUser.Keys.blockedRecordID] as? CKReference,
            let blockerUsername = record[BlockedUser.Keys.blockerUsername] as? String,
            let blockerUserRecord = record[BlockedUser.Keys.blockerRecordID] as? CKReference else { return nil }
        
        self.init(blockedUsername: blockedUsername, blockedRecordID: blockedUserRecord.recordID, blockerUsername: blockerUsername, blockerRecordID: blockerUserRecord.recordID)
    }
}
