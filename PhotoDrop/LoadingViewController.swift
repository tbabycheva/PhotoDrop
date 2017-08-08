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
    
    private let dispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()

        ActivityIndiactor().showActivityIndicatory(uiView: self.view)

        var segueIdentifier = ""

        dispatchGroup.enter()

        PhotoDropUserController.shared.pullCurrentUser() { (currentUser) in
            if let currentPhotoDropUser = currentUser {
                PhotoDropUserController.shared.currentPhotoDropUser = currentPhotoDropUser
                segueIdentifier = "toMapView"
            } else {
                segueIdentifier = "toWelcomeView"
            }
            self.dispatchGroup.leave()
        }

        dispatchGroup.enter()
        NotificationCenter.default.addObserver(self, selector: #selector(dropsInRangeWereUpdated), name: DropController.shared.dropsInRangeWereUpdatedNotification, object: nil)

        dispatchGroup.notify(queue: DispatchQueue.main) {
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: segueIdentifier, sender: self)
            }
        }
    }

    func dropsInRangeWereUpdated() {
        NotificationCenter.default.removeObserver(self)
        dispatchGroup.leave()
    }
}

