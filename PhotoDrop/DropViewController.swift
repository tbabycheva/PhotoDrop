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
    var image: UIImage?
    var photoTitle: String?
    var cameraState: Bool?
    var flashSwitch = false

    var cameraPosition = AVCaptureDevicePosition.back
    
    @IBOutlet weak var cameraView: UIView!
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
        image = nil
    }
    
    func updateCamPreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        camPreviewLayer.frame = self.view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection = self.camPreviewLayer.connection {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let camPreviewLayerConnection: AVCaptureConnection = connection
            
            if camPreviewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait:
                    updateCamPreviewLayer(layer: camPreviewLayerConnection, orientation: .portrait)
                case .landscapeRight:
                    updateCamPreviewLayer(layer: camPreviewLayerConnection, orientation: .landscapeLeft)
                case .landscapeLeft:
                    updateCamPreviewLayer(layer: camPreviewLayerConnection, orientation: .landscapeRight)
                case .portraitUpsideDown:
                    updateCamPreviewLayer(layer: camPreviewLayerConnection, orientation: .portraitUpsideDown)
                default:
                    updateCamPreviewLayer(layer: camPreviewLayerConnection, orientation: .portrait)
                }
            }
        }
    }
    
    // Loads or reloads the camera each time it is called
    
    func cameraLoad() {
        
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
    
    // Toggles between the front and back cameras
    
    func toggleCamera() {
        
        guard let input  = cameraSession.inputs[0] as? AVCaptureDeviceInput else { return }
        
        cameraSession.beginConfiguration()
        defer { cameraSession.commitConfiguration() }
        
        var newCamera: AVCaptureDevice?
        if input.device.position == .back {
            newCamera = captureDevice(with: .front)
            turnTorchOff()
        } else {
            newCamera = captureDevice(with: .back)
        }
        
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: newCamera)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        cameraSession.removeInput(input)
        cameraSession.addInput(deviceInput)
        
        if newCamera == captureDevice(with: .front) {
            flashToggle.isHidden = true
        } else {
            flashToggle.isHidden = false
        }
        
    }
    
    // Handles the position of the camera currently being used
    
    func captureDevice(with position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        
        let devices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified).devices
        
        if let devices = devices {
            for device in devices {
                if device.position == position {
                    return device
                }
            }
        }
        return nil
    }
    
    // Toggles the torchMode on the camera
    
    func cameraFlashToggle() {
        
        if flashSwitch == false {
            
            flashSwitch = true
            flashToggle.setImage(#imageLiteral(resourceName: "FlashOn"), for: .normal)
        } else {
            
            flashSwitch = false
            flashToggle.setImage(#imageLiteral(resourceName: "FlashOff"), for: .normal)
        }
    }
    
    // Forces the torchMode to .off
    
    func turnTorchOff() {
        
        guard let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        
        if flashSwitch == true || flashSwitch == false {
            
            do {
            try camera.lockForConfiguration()
            } catch {
                print(error.localizedDescription)
            }
            camera.torchMode = .off
            camera.unlockForConfiguration()
            
            flashSwitch = false
            flashToggle.setImage(#imageLiteral(resourceName: "FlashOff"), for: .normal)
            
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
        
        if flashSwitch == true {
        
            guard let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
            
            do {
                try camera.lockForConfiguration()
            } catch {
                print(error.localizedDescription)
            }
            camera.torchMode = .on
            camera.unlockForConfiguration()
            
        cameraOutput.capturePhoto(with: settings, delegate: self)
            
        
        } else {
            
            cameraOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {

        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func flashToggleButtonPressed(_ sender: Any) {
        
        cameraFlashToggle()
    }
    
    @IBAction func cameraPositionTogglePressed(_ sender: Any) {
        toggleCamera()
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
            
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            if orientation == .portrait {
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
                self.image = image
            } else if orientation == .landscapeLeft {
                let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.up)
                self.image = image
            } else if orientation == .landscapeRight {
                let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.down)
                self.image = image
            } else if orientation == .faceUp {
                let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
                self.image = image
            } else if orientation == .faceDown {
                let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
                self.image = image
            } else if orientation == .portraitUpsideDown {
                let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.left)
                self.image = image
            }
            
            turnTorchOff()
            
            performSegue(withIdentifier: "toDropPreview", sender: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDropPreview" {
            let image = self.image
            let dropPreviewVC = segue.destination as? DropPreviewViewController
            dropPreviewVC?.image = image
        }
    }
}
