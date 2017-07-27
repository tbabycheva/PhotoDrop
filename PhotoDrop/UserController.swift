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
    
    init() {
        
    }
    
    func changeUserName(user: User, username: String) {
        user.username = username
        user.push()
    }
    
    func pullUserWith(userRecordID: CKRecordID, completion: @escaping (User?) -> Void) {
        
        let userID = userRecordID
        let recordToMatch = CKReference(recordID: userID, action: .deleteSelf)
        let predicate = NSPredicate(format: "userRecordId == %@", recordToMatch)
        
        var pullUser: User?
        User.pull(predicate: predicate, objectsPerPage: 1, pulledObject: { (user) in pullUser = user
        }, completion: {_ in completion(pullUser)
        })
    }
    
    func pullCurrentUser(completion: @escaping (User?) -> Void) {
        let container = CKContainer.default()
        pullUserWith(userRecordID: container.fetchUserRecordID() {
            recordID, error in
            if error = error {
                print("error")
                return
            } else {
                print("fetched ID \(recordID?.recordName)")
                completion(recordID)
                return
            }
        }, completion: completion)
    }
}
