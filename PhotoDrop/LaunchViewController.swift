//
//  LaunchViewController.swift
//  PhotoDrop
//
//  Created by handje on 7/27/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PhotoDropUserController.shared.pullCurrentUser() { (currentUser) in
            if let currentPhotoDropUser = currentUser {
                
                PhotoDropUserController.shared.currentPhotoDropUser = currentPhotoDropUser
                
                self.performSegue(withIdentifier: "toMapView", sender: self)
            
            } else {
            
                self.performSegue(withIdentifier: "toWelcomeView", sender: self)
            }
        }
    }
}
