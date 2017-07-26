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
    
    var dropViewCntroller: DropViewController?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.text = dropViewCntroller?.photoTitle
    }
    
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dropViewCntroller?.photoTitle = titleTextField.text
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        
        DropController.shared.createDropWith(title: titleTextField.text!, timestamp: Date(), location: CLLocationCoordinate2D(latitude: Double(latitudeTextField.text!)!, longitude: Double(longitudeTextField.text!)!) , image: UIImage(), completion: nil)
        
        dismiss(animated: true, completion: nil)
        dropViewCntroller?.dismiss(animated: true, completion: nil)
    }

}
