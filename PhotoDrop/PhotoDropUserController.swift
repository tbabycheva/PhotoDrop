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
    var currentPhotoDropUser: User?
    
    init() {
        
    }
    
    func createCurrentUserWith(username: String) {
        guard let cloudKitUserID = cloudKitUserID else { return }
        let user = User(username: username, userRecordId: cloudKitUserID)
        user.push()
    }
    
    func changeUserName(username: String) {
        currentPhotoDropUser?.username = username
        currentPhotoDropUser?.push()
    }
    
    func pullUserWith(userRecordID: CKRecordID, completion: @escaping (User?) -> Void) {
        User.database.fetch(withRecordID: userRecordID) { (record, error) in
            guard let record = record else { return }
            completion(User(record: record))
        }
    }
    
    func pullCurrentUser(completion: @escaping (User?) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (userRecordID, error) in
            
            if let error = error { print(error.localizedDescription) }
            
            guard let userRecordID = userRecordID else { return }
            
            self.cloudKitUserID = userRecordID
            
            let userReference = CKReference(recordID: userRecordID, action: .deleteSelf)
            
            let predicate = NSPredicate(format: "userRecordId == %@", userReference)
            
            
            User.pull(predicate: predicate, objectsPerPage: 1, completion: { (user, error) in
                self.currentPhotoDropUser = user?.first
                completion(user?.first)
            })
        }
    }
}
