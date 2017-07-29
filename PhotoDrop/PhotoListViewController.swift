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
    
    @IBOutlet weak var photoListTableView: UITableView!
    
    var drops: [Drop] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let location = CurrentLocationController.shared.location else { return }
        
        DropController.shared.pullDrops(
            at: MKCoordinateRegionMake(
                location,
                MKCoordinateSpan(
                    latitudeDelta: GeoFenceController.shared.dropRange / 111000.0 /* degrees to meters for latitude */,
                    longitudeDelta: GeoFenceController.shared.dropRange / 111000.0 * cos(Double.pi * location.latitude / 180.0)
                )
            ),
            amount: 20
        ) {
            (drops) in
            
            self.drops = drops
            DispatchQueue.main.async{
                self.photoListTableView.reloadData()
            }
        }
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
        
        return drops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as? PhotoTableViewCell else { return UITableViewCell() }
        
        let drop = drops[indexPath.row]
        
        cell.titleLabel.text = drop.title
        cell.usernameLabel.text = drop.dropperUserName
        cell.dateLabel.text = "\(drop.timestamp)"
        cell.pointsLabel.text = "\(drop.numberOfLikes) pts"
        //       cell.gemImageView.image = UIImage(named: "diamond-gold")
        cell.gemImageView.image = drop.image
        
        return cell
    }
}


// MARK: - TableView Delegate

extension PhotoListViewController: UITableViewDelegate {
    
}

// MARK: - Navigation

extension PhotoListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoDetail" {
            guard let indexPath = photoListTableView.indexPathForSelectedRow else { return }
            
            let drop = drops[indexPath.row]
            let detailVC = segue.destination as? PhotoViewController
            
            detailVC?.drop = drop
        }
    }
}











