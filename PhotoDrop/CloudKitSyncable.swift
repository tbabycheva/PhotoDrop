import Foundation
import CloudKit

protocol CloudKitSyncable: class {
  var record: CKRecord? { get set }

  static var recordType: String { get }
  static var database: CKDatabase { get }

  var recordDictionary: [String: CKRecordValue] { get }

  init?(record: CKRecord)
}

extension CloudKitSyncable {
  func getRecord() -> CKRecord {
    let record = self.record ?? CKRecord(recordType: Self.recordType)

    for (key, value) in recordDictionary {
      record[key] = value
    }

    self.record = record
    return record
  }

  func push(completion: ((_ records: [CKRecord]?, _ error: Error?) -> Void)? = nil) {
    let operation = CKModifyRecordsOperation(recordsToSave: [self.getRecord()], recordIDsToDelete: nil)
    operation.savePolicy = .changedKeys
    operation.queuePriority = .high
    operation.qualityOfService = .userInteractive
    operation.modifyRecordsCompletionBlock = {
      (records, recordIDs, error) -> Void in
      if let error = error {
        NSLog("error \(error.localizedDescription)")
      }
      completion?(records, error)
    }

    Self.database.add(operation)
  }

  func delete(completion: ((_ records: [CKRecord]?, _ error: Error?) -> Void)? = nil) {
    let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [self.getRecord().recordID])
    operation.queuePriority = .high
    operation.qualityOfService = .userInteractive
    operation.modifyRecordsCompletionBlock = {
      (records, recordIDs, error) -> Void in
      completion?(records, error)
    }

    Self.database.add(operation)
  }

  static func pull(
    predicate: NSPredicate = NSPredicate(value: true),
    objectsPerPage: Int = CKQueryOperationMaximumResults,
    pulledObject: ((_ record: Self) -> Void)?,
    pageFinished: @escaping (_ pullNextPage: () -> Void) -> Void = { $0() },
    completion: ((_ records: [Self]?, _ error: Error?) -> Void)?
  ) {
    var pulledObjects: [Self] = []

    let query = CKQuery(recordType: Self.recordType, predicate: predicate)
    let queryOperation = CKQueryOperation(query: query)

    let perObjectBlock = { (fetchedRecord: CKRecord) -> Void in
      guard let record = Self(record: fetchedRecord) else {
        return
      }
      record.record = fetchedRecord
      pulledObjects.append(record)
      pulledObject?(record)
    }

    var queryCompletionBlock: (CKQueryCursor?, Error?) -> Void = { (_, _) in }
    queryCompletionBlock = { (queryCursor: CKQueryCursor?, error: Error?) -> Void in

      if let queryCursor = queryCursor {
        pageFinished{
          let continuedQueryOperation = CKQueryOperation(cursor: queryCursor)
          continuedQueryOperation.resultsLimit = objectsPerPage
          continuedQueryOperation.recordFetchedBlock = perObjectBlock
          continuedQueryOperation.queryCompletionBlock = queryCompletionBlock

          Self.database.add(continuedQueryOperation)
        }
      } else {
        completion?(pulledObjects, error)
      }
    }

    queryOperation.resultsLimit = objectsPerPage
    queryOperation.recordFetchedBlock = perObjectBlock
    queryOperation.queryCompletionBlock = queryCompletionBlock

    Self.database.add(queryOperation)
  }
}
