//
//  UserController.swift
//  PhotoDrop
//
//  Created by handje on 7/26/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation

class UserController {
    
    static let shared = UserController()
    
    let users = [User]()
    
    
    func changeUserName(user: User, username: String) {
        user.username = username 
    }
    
    func pullUser(user: User, username: String, numberOfRecievedDropLikes: Int, numberOfGivenDropLikes: Int, numberOfDrops: Int) {
        user.username = username
        user.numberOfRecievedDropLikes = numberOfRecievedDropLikes
        user.numberOfGivenDropLikes = numberOfGivenDropLikes
        user.numberOfDrops = numberOfDrops 
    }
}
