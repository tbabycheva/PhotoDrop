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
    
    func blockAlert(dropUser: String) {
        
        guard let drop = drop,
            let dropUser = drop.dropperUserName
            else { return }
        
        let blockAlert = UIAlertController(title: "Block User: \(dropUser)?", message: "", preferredStyle: .alert)
        blockAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            BlockedUserController.shared.blockUser(of: drop)
        }))
        blockAlert.addAction(UIAlertAction(title: "NO!", style: .cancel, handler: nil))
        self.present(blockAlert, animated: true, completion: nil)
    }
    
    // MARK: Action Functions
    
    @IBAction func blockUserButtonTapped(_ sender: Any) {
    
        guard let drop = drop,
            let dropUser = drop.dropperUserName
            else { return }
        
        blockAlert(dropUser: dropUser)
    }
    
    @IBAction func dropLikeButtonTapped(_ sender: Any) {
        dropLikeButton.isEnabled = false
        guard let drop = drop else { return }
        guard let hasLiked = drop.hasLiked else { return }
        
        if hasLiked {
            DropLikeController.shared.deleteDropLike(for: drop, completion: {
                DispatchQueue.main.async {
                    self.dropLikeButton.isEnabled = true
                }
            })
            drop.hasLiked = false
        } else {
            _ = DropLikeController.shared.createDropLike(for: drop, completion: { 
                DispatchQueue.main.async {
                    self.dropLikeButton.isEnabled = true
                }
            })
            drop.hasLiked = true
        }
        updateLikeGem()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
