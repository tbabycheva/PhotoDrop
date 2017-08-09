//
//  PhotoTableViewCell.swift
//  PhotoDrop
//
//  Created by Tetiana Babycheva on 7/28/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    // MARK: - Properties and Outlets
    
    var drop: Drop? {
        didSet{
            updateViews()
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var gemImageView: UIImageView!

    // MARK: - Internal Functions
    
    func updateViews() {
        
        guard let drop = drop else { return }
        titleLabel.text = drop.title
        usernameLabel.text = drop.dropperUserName
        dateLabel.text = drop.timestamp.stringValue()
        let numberPointsForLikesRecieved = drop.numberOfLikes * 50
        pointsLabel.text = "\(numberPointsForLikesRecieved) pts"
        // gemImageView.image = // set different gem colors
    }
}

