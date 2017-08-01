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
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var previewImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self

        titleTextField.text = dropViewController?.photoTitle
        previewImage.image = image?.fixOrientation()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        guard let savedPic = previewImage.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(savedPic, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        let savedAlert = UIAlertController(title: "Saved to Photo Library!", message: "", preferredStyle: .alert)
        savedAlert.addAction(UIAlertAction(title: "Dope!", style: .cancel, handler: nil))
        self.present(savedAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dropViewController?.photoTitle = titleTextField.text
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        
        guard let text = titleTextField.text,
            let location = CurrentLocationController.shared.location
            else { return }
        
        if titleTextField.text != "" {
            
            guard let droppedImage = image?.fixOrientation() else { return }
            
            DropController.shared.createDropWith(title: text, timestamp: Date(), location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), image: droppedImage, completion: nil)
            
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "Title Required", message: "You must enter a title for the picture.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        titleTextField.resignFirstResponder()
        return true
    }
    
}

extension UIImage {
    
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalImage
    }
    
}
