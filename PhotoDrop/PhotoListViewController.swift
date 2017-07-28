//
//  PhotoListViewController.swift
//  PhotoDrop
//
//  Created by Kenny Peterson on 7/24/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit
import MapKit

class PhotoListViewController: UIViewController {
    
    // Mock data
    struct Photo {
        let title: String
        let username: String
        let dateString: String
        let pointsString: String
    }
    
    let photos = [
        Photo(title: "New Cool Graffiti", username: "robhand23", dateString: "07/24/2017", pointsString: "15pts"),
        Photo(title: "Awesome Mountain View", username: "tanya_mila", dateString: "09/24/2016", pointsString: "250pts"),
        Photo(title: "My First Photo", username: "kenny_man_here", dateString: "07/28/2017", pointsString: "10pts")
    ]
    
@IBOutlet weak var photoListTableView: UITableView!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photoListTableView.reloadData()
    }
    
    // MARK: - Action Functions
    
    @IBAction func mapButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TableView Data Source

extension PhotoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as? PhotoTableViewCell else { return UITableViewCell() }
        
        let photo = photos[indexPath.row]
        
        cell.titleLabel.text = photo.title
        cell.usernameLabel.text = photo.username
        cell.dateLabel.text = photo.dateString
        cell.pointsLabel.text = photo.pointsString
        cell.gemImageView.image = UIImage(named: "diamond-gold")
        
        return cell
    }
}


// MARK: - TableView Delegate

extension PhotoListViewController: UITableViewDelegate {
    
}

// MARK: - Navigation

extension PhotoListViewController {
    
}











