//
//  PointsViewController.swift
//  PhotoDrop
//
//  Created by Kenny Peterson on 7/24/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit

class PointsViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var ratedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePtsView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updatePtsView()
    }
    
    // MARK: - Appearance
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    @IBAction func mapButtonTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UpdatePtsView
    
    func updatePtsView() {
       
        PhotoDropUserController.shared.pullCurrentUser { (user) in
            
            guard let user = user else { return }
           
            self.usernameLabel.text = "\(user.username),"
            
            let numberValueLikesRecieved = user.numberOfRecievedDropLikes
            let numberPointsForLikesRecieved = user.numberOfRecievedDropLikes * 50
            self.likesLabel.text = "\(numberValueLikesRecieved) gems"
            let numberValueLikesGiven = user.numberOfGivenDropLikes
            let numberPointsForLikesGiven = user.numberOfGivenDropLikes * 30
            self.ratedLabel.text = "\((numberValueLikesGiven)) rated"
            self.pointsLabel.text = "\((numberPointsForLikesRecieved + numberPointsForLikesGiven)) pts!"
        }
    }
 }
