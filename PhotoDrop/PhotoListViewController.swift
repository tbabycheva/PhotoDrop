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
    
    var drops: [Drop] = [] {
        didSet {
            // Pull drop detail data from iCloud
            let group = DispatchGroup()
            group.notify(queue: DispatchQueue.main) {
                self.photoListTableView.reloadData()
            }
            for drop in drops {
                group.enter()
                DropController.shared.pullDetailDropWith(for: drop, completion:{ (drop) in
                    group.leave()
                })
            }
            
            group.notify(queue: DispatchQueue.main) {
                self.photoListTableView.reloadData()
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove separator lines (make them clear)
        // photoListTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // Populate the table with 20 drops
        guard let location = CurrentLocationController.shared.location else { return }
        
        DropController.shared.pullDrops(
            at: MKCoordinateRegionMake(location,
                MKCoordinateSpan( latitudeDelta: GeoFenceController.shared.dropRange / 111000.0 /* degrees to meters for latitude */,
                    longitudeDelta: GeoFenceController.shared.dropRange / 111000.0 * cos(Double.pi * location.latitude / 180.0))),
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
    
    // Lock tableview in portrait mode
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
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
        
        cell.drop = drop
        
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
