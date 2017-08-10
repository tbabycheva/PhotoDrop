//
//  DropPreviewViewController.swift
//  PhotoDrop
//
//  Created by Kenny Peterson on 7/25/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit
import  MapKit
import Photos

class DropPreviewViewController: UIViewController, UITextFieldDelegate {
    
    var dropViewController: DropViewController?
    var image: UIImage?
    var frontUsed = false
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self

        titleTextField.text = dropViewController?.photoTitle
        previewImage.image = image
        if frontUsed == true {
            
            previewImage.transform = previewImage.transform.rotated(by: CGFloat(135.1))
        }
    }
    
    // MARK: - Action Functions
    
    // Post your photo
    @IBAction func postButtonTapped(_ sender: Any) {
        
        guard let text = titleTextField.text,
            let location = CurrentLocationController.shared.location
            else { return }
        
        if titleTextField.text != "" {
            guard let droppedImage = image else { return }
            
            DropController.shared.createDropWith(title: text, timestamp: Date(),
                                                 location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                                                 image: droppedImage, completion: nil)

            UIImageWriteToSavedPhotosAlbum(droppedImage, self, nil, nil)
            
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Title Required", message: "Please enter the title first 🙃", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // Back to camera
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dropViewController?.photoTitle = titleTextField.text
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Sliding keyboard

extension DropPreviewViewController {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: 120)
        postButton.isHidden = true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 120)
        postButton.isHidden = false
    }
    
    func animateViewMoving (up: Bool, moveValue: CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        titleTextField.resignFirstResponder()
        return 
    }
}
