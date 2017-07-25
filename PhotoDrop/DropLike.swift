//
//  DropLikes.swift
//  PhotoDrop
//
//  Created by Micah Bunting on 7/25/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CloudKit

class DropLike: CloudKitSyncable {
  var likerUserId: CKRecordID
  var dropId: CKRecordID

  init(
    likerUserId: CKRecordID,
    dropId: CKRecordID
  ) {
    self.likerUserId = likerUserId
    self.dropId = dropId
  }

  /* CloudKitSyncable */
  var record: CKRecord?

  static let recordType = "DropLike"

  static let database: CKDatabase = CKContainer.default().privateCloudDatabase

  private struct Keys {
    static let likerUserId = "likerUserId"
    static let dropId = "dropId"
  }

  var recordDictionary: [String: CKRecordValue] {
    return [
      DropLike.Keys.likerUserId: CKReference(recordID: likerUserId, action: CKReferenceAction.deleteSelf),
      DropLike.Keys.dropId: CKReference(recordID: dropId, action: CKReferenceAction.deleteSelf),
    ]
  }

  convenience required init?(record: CKRecord) {
    guard
      let likerUserId = record[DropLike.Keys.likerUserId] as? CKReference,
      let dropId = record[DropLike.Keys.dropId] as? CKReference
    else {
      return nil
    }
    self.init(
      likerUserId: likerUserId.recordID,
      dropId: dropId.recordID
    )
  }
}
