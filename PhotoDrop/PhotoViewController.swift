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
    @IBOutlet weak var dropLikeButton: UIButton!
    @IBOutlet weak var blockUserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let drop = drop {
            photoImageView.image = drop.image
            titleLabel.text = drop.title
            dateLabel.text = "Posted \(drop.timestamp.stringValueSpelled())"
            updateLikeGem()
            
            if PhotoDropUserController.shared.currentPhotoDropUser?.username == drop.dropperUserName {
                blockUserButton.isHidden = true
            }
        }
    }
    
    func updateLikeGem() {
        guard let hasLiked = drop?.hasLiked else { return }
        
        if hasLiked {
            dropLikeButton.setImage(#imageLiteral(resourceName: "diamond-gold-like"), for: .normal)
        }else {
            dropLikeButton.setImage(#imageLiteral(resourceName: "diamond-gold-like-inactive"), for: .normal)
        }
    }
    
    func successfulBlockAlert(dropUser: String) {
        
        let blockAlert = UIAlertController(title: "User \(dropUser) has been blocked!", message: "", preferredStyle: .alert)
        blockAlert.addAction(UIAlertAction(title: "Good", style: .cancel, handler: nil))
        self.present(blockAlert, animated: true, completion: nil)
    }
    
    // MARK: Action Functions
    
    @IBAction func blockUserButtonTapped(_ sender: Any) {
        
        guard let drop = drop,
        let dropUser = drop.dropperUserName
            else { return }
        
        BlockedUserController.shared.blockUser(of: drop)
        successfulBlockAlert(dropUser: dropUser)
    }
    
    @IBAction func dropLikeButtonTapped(_ sender: Any) {
        
        guard let drop = drop else { return }
        guard let hasLiked = drop.hasLiked else { return }
        
        if hasLiked {
            DropLikeController.shared.deleteDropLike(for: drop)
            drop.hasLiked = false
        } else {
            _ = DropLikeController.shared.createDropLike(for: drop)
            drop.hasLiked = true
        }
        updateLikeGem()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
