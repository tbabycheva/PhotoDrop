//
//  DropPreviewViewController.swift
//  PhotoDrop
//
//  Created by Kenny Peterson on 7/25/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit
import  MapKit

class DropPreviewViewController: UIViewController {
    
    var dropViewController: DropViewController?
    var image: UIImage?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var previewImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.text = dropViewController?.photoTitle
        previewImage.image = image
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dropViewController?.photoTitle = titleTextField.text
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        
        DropController.shared.createDropWith(title: titleTextField.text!, timestamp: Date(), location: CLLocationCoordinate2D(latitude: Double(longitudeTextField.text!)!, longitude: Double(longitudeTextField.text!)!) , image: UIImage(), completion: nil)
        
        dismiss(animated: true, completion: nil)
        dropViewController?.dismiss(animated: true, completion: nil)
    }

}
