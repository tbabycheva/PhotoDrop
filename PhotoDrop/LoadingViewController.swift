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
            if currentUser != nil {
                NotificationCenter.default.addObserver(self, selector: #selector(self.dropsInRangeWereUpdated), name: DropController.shared.dropsInRangeWereUpdatedNotification, object: nil)
                DropController.shared.updateInRangeDrops()
            } else {
                DispatchQueue.main.async{
                    self.performSegue(withIdentifier: "toWelcomeView", sender: self)
                }
            }
        }
    }
    
    // MARK: - Appearance
    // Lock tableview in portrait mode
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }

    func dropsInRangeWereUpdated() {
        NotificationCenter.default.removeObserver(self)
        DispatchQueue.main.async{
            self.performSegue(withIdentifier: "toMapView", sender: self)
        }
    }
}

