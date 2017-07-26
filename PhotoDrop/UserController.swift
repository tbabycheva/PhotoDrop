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
    
    func fetchRecordID(complete: @escaping (_ instance: CKRecordID?, _ error: Error?) -> ()) {
        let container = CKContainer.default()
        container.fetchUserRecordID() {
            recordID, error in
            if error != nil {
                print(error!.localizedDescription)
                complete(nil, error)
            } else {
                print("fetched ID \(recordID?.recordName)")
                complete(recordID, nil)
            }
        }
    }
    
    func pullCurrentUserWith(completion: @escaping (User?) -> Void) {
        let container = CKContainer.default()
        pullUserWith(userRecordID: container .fetchUserRecordID(completionHandler: { (recordID, error) in
            guard let recordID = recordID else {
                if let error = error {
                    print("error")
                    return
                }
                completion(recordID)
                return
            }
            
        }), completion: completion)
        
    }
}
