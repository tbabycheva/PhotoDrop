//
//  User.swift
//  PhotoDrop
//
//  Created by Micah Bunting on 7/25/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CloudKit

class User: CloudKitSyncable {
  var username: String
  var userRecordId: CKRecordID

  /* points */
  var numberOfRecievedDropLikes: Int
  var numberOfGivenDropLikes: Int
  var numberOfDrops: Int

  init(
    username: String,
    userRecordId: CKRecordID,
    numberOfRecievedDropLikes: Int,
    numberOfGivenDropLikes: Int,
    numberOfDrops: Int
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

  static let database: CKDatabase = CKContainer.default().privateCloudDatabase

  private struct Keys {
    static let username = "username"
    static let userRecordId = "userRecordId"
    static let numberOfRecievedDropLikes = "numberOfRecievedDropLikes"
    static let numberOfGivenDropLikes = "numberOfGivenDropLikes"
    static let numberOfDrops = "numberOfDrops"
  }

  var recordDictionary: [String: CKRecordValue] {
    return [
      User.Keys.username: username as CKRecordValue,
      User.Keys.userRecordId: CKReference(recordID: userRecordId, action: CKReferenceAction.deleteSelf),
      User.Keys.numberOfRecievedDropLikes: numberOfRecievedDropLikes as CKRecordValue,
      User.Keys.numberOfGivenDropLikes: numberOfGivenDropLikes as CKRecordValue,
      User.Keys.numberOfDrops: numberOfDrops as CKRecordValue,
    ]
  }

  convenience required init?(record: CKRecord) {
    guard
      let username = record[User.Keys.username] as? String,
      let userRecord = record[User.Keys.userRecordId] as? CKReference,
      let numberOfRecievedDropLikes = record[User.Keys.numberOfRecievedDropLikes] as? Int,
      let numberOfGivenDropLikes = record[User.Keys.numberOfGivenDropLikes] as? Int,
      let numberOfDrops = record[User.Keys.numberOfDrops] as? Int
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
