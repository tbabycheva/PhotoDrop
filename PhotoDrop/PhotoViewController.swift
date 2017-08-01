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
        
//        guard let drop = drop else { return }
//        
//        var likerUserID: CKRecordID?
//        var dropID: CKRecordID?
//        
//        let dispatchGroup = DispatchGroup()
//        
//        dispatchGroup.enter()
//        DropLikeController.shared.pullDropLike(for: drop) { (dropLike) in
//            dropID = dropLike?.dropId
//            dispatchGroup.leave()
//        }
//        
//        dispatchGroup.notify(queue: DispatchQueue.main) {
//            guard let likerUserID = likerUserID, let dropID = dropID else { return }
//            DropLikeController.shared.createDropLike(for: dropID)
//        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
