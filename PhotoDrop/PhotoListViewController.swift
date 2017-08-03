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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: DropController.shared.dropsInRangeWereUpdatedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    func reload() {
        DispatchQueue.main.async{
            self.photoListTableView.reloadData()
        }
    }
    
    // MARK: - Appearance
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
        
        return DropController.shared.dropsInRange.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as? PhotoTableViewCell else { return UITableViewCell() }
        
        let drop = DropController.shared.dropsInRange[indexPath.row]
        
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
            
            let drop = DropController.shared.dropsInRange[indexPath.row]
            let detailVC = segue.destination as? PhotoViewController
            
            detailVC?.drop = drop
        }
    }
}
