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
    
    var blockedRecordID: CKRecordID
    var blockerRecordID: CKRecordID
    
    init(blockedRecordID: CKRecordID, blockerRecordID: CKRecordID) {
        self.blockedRecordID = blockedRecordID
        self.blockerRecordID = blockerRecordID
    }
    
    /* CloudKitSyncable */
    var record: CKRecord?
    
    static let recordType = "BlockedUser"
    
    static let database: CKDatabase = CKContainer.default().publicCloudDatabase
    
    private struct Keys {
        static let blockedRecordID = "blockedRecordID"
        static let blockerRecordID = "blockerRecordID"
    }
    
    var recordDictionary: [String : CKRecordValue] {
        return [
            BlockedUser.Keys.blockedRecordID: CKReference(recordID: blockedRecordID, action: CKReferenceAction.deleteSelf),
            BlockedUser.Keys.blockerRecordID: CKReference(recordID: blockerRecordID, action: CKReferenceAction.deleteSelf)
        ]
    }
    
    convenience required init?(record: CKRecord) {
       guard let blockedUserRecord = record[BlockedUser.Keys.blockedRecordID] as? CKReference,
        let blockerUserRecord = record[BlockedUser.Keys.blockerRecordID] as? CKReference else { return nil } 
        
        self.init(blockedRecordID: blockedUserRecord.recordID, blockerRecordID: blockerUserRecord.recordID)
    }
}
