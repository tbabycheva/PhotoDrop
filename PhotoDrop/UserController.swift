//
//  UserController.swift
//  PhotoDrop
//
//  Created by handje on 7/26/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    static let shared = UserController()
    let usersPullNotification = Notification.Name(rawValue: "userPullNotifiaction")
    var currentUser: User?
    let records = [CKRecord]() 
    
    init() {
        
    }
    
    func createUserNameWith(username: String, userRecordID: CKRecordID, defaultUserRecordID: CKReference) {
        let user = User(username: username, userRecordId: userRecordID, defaultUserRecordID: defaultUserRecordID) 
        user.push()
    }
    
    func changeUserName(user: User, username: String) {
        user.username = username
        user.push()
    }
    
    func pullUserWith(predicate: NSPredicate, userRecordID: CKRecordID, completion: @escaping (User?) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (defaultUsersRecordID, error) in
            
            if let error = error { print(error.localizedDescription) }
            
            guard let defaultUsersRecordID = defaultUsersRecordID else { return }
            
            let defaultUserReference = CKReference(recordID: defaultUsersRecordID, action: .deleteSelf)
            
            let predicate = NSPredicate(format: "defaultUserRecordID == %@", defaultUserReference)
            
            self.pullUserWith(predicate: predicate, userRecordID: userRecordID, completion: { (user) in
                guard let currentUserRecord = self.records.first else { completion(nil); return }
                
                let currentUser = User(record: currentUserRecord)
                completion(currentUser)
            })
        }
    }
    
    func pullCurrentUser() {
        
    }
    
    func pushUser() {
        
        let store = CKRecord(recordType: "Users")
        
        store.setObject(currentUser?.defaultUserRecordID, forKey: "defaultUserRecordID")
        
        currentUser?.push()
        
    }
    
    
}
