//
//  CameraVC.swift
//  Identify
//
//  Created by Dan Lindsay on 2017-11-06.
//  Copyright © 2017 Dan Lindsay. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {
    
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var itemImageView: RoundedShadowImageView!
    @IBOutlet weak var flashOffBtn: RoundedShadowButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var roundedShadowView: RoundedShadowView!
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer!)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
        } catch {
            debugPrint(error)
        }
    }
    
    @objc func didTapCameraView() {
        let settings = AVCapturePhotoSettings()

        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
        
    }

    @IBAction func flashOffBtnWasPressed(_ sender: Any) {
        
    }
}

extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            let image = UIImage(data: photoData!)
            self.itemImageView.image = image
            
        }
    }
}

