//
//  PhotoViewController.swift
//  PhotoDrop
//
//  Created by Kenny Peterson on 7/24/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit
import CloudKit

class PhotoViewController: UIViewController {
    
    var drop: Drop?
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let drop = drop {
            photoImageView.image = drop.image
            titleLabel.text = drop.title
            dateLabel.text = "Posted \(drop.timestamp.stringValueSpelled())"
        }
    }
    
    // MARK: Action Functions
    
    @IBAction func blockUserButtonTapped(_ sender: Any) {
        
        guard let drop = drop else { return }
        
        BlockedUserController.shared.blockUser(of: drop) 
    }
    
    @IBAction func dropLikeButtonTapped(_ sender: Any) {
        
        guard let drop = drop else { return }
        guard let hasLiked = drop.hasLiked else { return }
        
        if hasLiked {
            //deleteDropLike
            DropLikeController.shared.deleteDropLike(for: drop) 
        } else {
            //createDropLike
            _ = DropLikeController.shared.createDropLike(for: drop)
            drop.hasLiked = false
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
