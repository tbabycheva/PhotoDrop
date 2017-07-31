//
//  User.swift
//  PhotoDrop
//
//  Created by Micah Bunting on 7/25/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CloudKit

class PhotoDropUser: CloudKitSyncable {
    var username: String
    //cloudKit userID
    var userRecordId: CKRecordID
    
    /* points */
    var numberOfRecievedDropLikes: Int
    var numberOfGivenDropLikes: Int
    var numberOfDrops: Int
    
    init(
        username: String,
        userRecordId: CKRecordID,
        numberOfRecievedDropLikes: Int = 0,
        numberOfGivenDropLikes: Int = 0,
        numberOfDrops: Int = 0
        ) {
        self.username = username
        self.userRecordId = userRecordId
        self.numberOfRecievedDropLikes = numberOfRecievedDropLikes
        self.numberOfGivenDropLikes = numberOfGivenDropLikes
        self.numberOfDrops = numberOfDrops
    }
    
    /* CloudKitSyncable */
    var record: CKRecord?
    
    static let recordType = "User"
    
    static let database: CKDatabase = CKContainer.default().publicCloudDatabase
    
    private struct Keys {
        static let username = "username"
        static let userRecordId = "userRecordId"
        static let numberOfRecievedDropLikes = "numberOfRecievedDropLikes"
        static let numberOfGivenDropLikes = "numberOfGivenDropLikes"
        static let numberOfDrops = "numberOfDrops"
    }
    
    var recordDictionary: [String: CKRecordValue] {
        return [
            PhotoDropUser.Keys.username: username as CKRecordValue,
            PhotoDropUser.Keys.userRecordId: CKReference(recordID: userRecordId, action: CKReferenceAction.deleteSelf),
            PhotoDropUser.Keys.numberOfRecievedDropLikes: numberOfRecievedDropLikes as CKRecordValue,
            PhotoDropUser.Keys.numberOfGivenDropLikes: numberOfGivenDropLikes as CKRecordValue,
            PhotoDropUser.Keys.numberOfDrops: numberOfDrops as CKRecordValue,
        ]
    }
    
    convenience required init?(record: CKRecord) {
        guard
            let username = record[PhotoDropUser.Keys.username] as? String,
            let userRecord = record[PhotoDropUser.Keys.userRecordId] as? CKReference,
            let numberOfRecievedDropLikes = record[PhotoDropUser.Keys.numberOfRecievedDropLikes] as? Int,
            let numberOfGivenDropLikes = record[PhotoDropUser.Keys.numberOfGivenDropLikes] as? Int,
            let numberOfDrops = record[PhotoDropUser.Keys.numberOfDrops] as? Int
            else {
                return nil
        }
        self.init(
            username: username,
            userRecordId: userRecord.recordID,
            numberOfRecievedDropLikes: numberOfRecievedDropLikes,
            numberOfGivenDropLikes: numberOfGivenDropLikes,
            numberOfDrops: numberOfDrops
        )
    }
}
