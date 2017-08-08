//
//  LoadingViewController.swift
//  PhotoDrop
//
//  Created by handje on 8/8/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import UIKit

class LoadingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ActivityIndiactor().showActivityIndicatory(uiView: self.view)
        
        PhotoDropUserController.shared.pullCurrentUser() { (currentUser) in
            if let currentPhotoDropUser = currentUser {
                
                PhotoDropUserController.shared.currentPhotoDropUser = currentPhotoDropUser
                
                DispatchQueue.main.async{
                    
                    self.performSegue(withIdentifier: "toMapView", sender: self)
                }
                
            } else {
                
                DispatchQueue.main.async{
                    
                    self.performSegue(withIdentifier: "toWelcomeView", sender: self)
                }
            }
        }
    }
}

