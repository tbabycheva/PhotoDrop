//
//  UserController.swift
//  PhotoDrop
//
//  Created by handje on 7/26/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CloudKit

class PhotoDropUserController {
    
    static let shared = PhotoDropUserController()
    var cloudKitUserID: CKRecordID?
    var currentPhotoDropUser: PhotoDropUser?
    
    init() {
        
    }
    
    func createCurrentUserWith(username: String) {

        CKContainer.default().fetchUserRecordID { (cloudKitUserID, error) in
          guard let cloudKitUserID = cloudKitUserID else { return }
          self.cloudKitUserID = cloudKitUserID
          let user = PhotoDropUser(username: username, userRecordId: cloudKitUserID)
          user.push()
        }
    }
    
    func changeUserName(username: String) {
        currentPhotoDropUser?.username = username
        currentPhotoDropUser?.push()
    }
    
    func pullUserWith(userRecordID: CKRecordID, completion: @escaping (PhotoDropUser?) -> Void) {
        PhotoDropUser.database.fetch(withRecordID: userRecordID) { (record, error) in
            guard let record = record else {
              completion(nil)
              return
            }
            completion(PhotoDropUser(record: record))
        }
    }
    
    func pullCurrentUser(completion: @escaping (PhotoDropUser?) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (userRecordID, error) in
            
            if let error = error { print(error.localizedDescription) }
            
            guard let userRecordID = userRecordID else { return }
            
            self.cloudKitUserID = userRecordID
            
            let userReference = CKReference(recordID: userRecordID, action: .deleteSelf)
            
            let predicate = NSPredicate(format: "userRecordId == %@", userReference)
            
            
            PhotoDropUser.pull(predicate: predicate, objectsPerPage: 1, completion: { (user, error) in
                self.currentPhotoDropUser = user?.first
                completion(user?.first)
            })
        }
    }
}
