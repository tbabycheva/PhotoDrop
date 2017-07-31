//
//  DropViewController.swift
//  PhotoDrop
//
//  Created by Kenny Peterson on 7/24/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit
import AVFoundation

class DropViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - Properties and Outlets
    
    var cameraOutput: AVCapturePhotoOutput!
    var cameraSession: AVCaptureSession!
    var camPreviewLayer: AVCaptureVideoPreviewLayer!
    var photoTitle: String?
    var cameraState: Bool?

    var cameraPosition = AVCaptureDevicePosition.back
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var flashToggle: UIButton!
    @IBOutlet weak var cameraPositionToggle: UIButton!

    
     // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppUtility.lockOrientation(.all)
    }
    
    func cameraLoad() {

        imageView.isHidden = true
        
        cameraSession = AVCaptureSession()
        cameraSession.sessionPreset = AVCaptureSessionPresetPhoto
        cameraOutput = AVCapturePhotoOutput()
        
        let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        if let input = try? AVCaptureDeviceInput(device: camera) {
            if (cameraSession.canAddInput(input)) {
                cameraSession.addInput(input)
                if (cameraSession.canAddOutput(cameraOutput)) {
                    cameraSession.addOutput(cameraOutput)
                    camPreviewLayer = AVCaptureVideoPreviewLayer(session: cameraSession)
                    camPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    camPreviewLayer.frame = cameraView.bounds
                    camPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                    
                    cameraView.layer.addSublayer(camPreviewLayer)
                    cameraSession.startRunning()
                }
            } else {
                print("Could not add input.")
            }
        } else {
            print("An error occurred.")
        }
    }
    
    // MARK: - Action Functions
    
    @IBAction func takePhotoButtonTapped(_ sender: Any) {
        
        let settings = AVCapturePhotoSettings()
        let previewType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewType,
            kCVPixelBufferHeightKey as String: 160,
            kCVPixelBufferWidthKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func flashToggleButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func cameraPositionTogglePressed(_ sender: Any) {

    }
    
    
    // MARK: - Formatting and Saving a Picture

    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("An error has occured: \(error.localizedDescription)")
        }
        if let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size as Any)
            
            guard let dataProvider = CGDataProvider(data: dataImage as CFData),
                let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                else { return }
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            self.imageView.image = image
            
            performSegue(withIdentifier: "toDropPreview", sender: nil)
        }
    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDropPreview" {
            let image = self.imageView.image
            let dropPreviewVC = segue.destination as? DropPreviewViewController
            dropPreviewVC?.image = image
        }
    }
}
