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
        previewImage.image = image
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

            UIImageWriteToSavedPhotosAlbum(droppedImage, self, #selector(savedImageAlert(_:didFinishSavingWithError:contextInfo:)), nil)
            
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Title Required", message: "Please enter the title first 🙃", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func savedImageAlert(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        let savedAlert = UIAlertController(title: "Saved to Photo Library!", message: "", preferredStyle: .alert)
        savedAlert.addAction(UIAlertAction(title: "Dope!", style: .cancel, handler: nil))
        self.present(savedAlert, animated: true, completion: nil)
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
        animateViewMoving(up: true, moveValue: 135)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 135)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
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
}

// MARK: - Save photos with proper orientation
extension UIImage {
    
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        if self.imageOrientation == UIImageOrientation.down || self.imageOrientation == UIImageOrientation.downMirrored {
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }
        if self.imageOrientation == UIImageOrientation.left || self.imageOrientation == UIImageOrientation.leftMirrored {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
        }
        if self.imageOrientation == UIImageOrientation.right || self.imageOrientation == UIImageOrientation.rightMirrored {
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2.0))
        }
        if self.imageOrientation == UIImageOrientation.upMirrored || self.imageOrientation == UIImageOrientation.downMirrored {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(-1 / 1))
        }
        if self.imageOrientation == UIImageOrientation.leftMirrored || self.imageOrientation == UIImageOrientation.rightMirrored {
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.rotated(by: CGFloat(-1 / 1))
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        if self.imageOrientation == UIImageOrientation.left ||
        self.imageOrientation == UIImageOrientation.leftMirrored ||
        self.imageOrientation == UIImageOrientation.right ||
            self.imageOrientation == UIImageOrientation.rightMirrored {
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        let coreGraphicsImage: CGImage = ctx.makeImage()!
        let imageEnd: UIImage = UIImage(cgImage: coreGraphicsImage)
        
        return imageEnd
        
//        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
//        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
//        let normalImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        
//        return normalImage
    }
}






















