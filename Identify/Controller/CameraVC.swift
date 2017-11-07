//
//  CameraVC.swift
//  Identify
//
//  Created by Dan Lindsay on 2017-11-06.
//  Copyright © 2017 Dan Lindsay. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum FlashState {
    case off
    case on
}

class CameraVC: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var itemImageView: RoundedShadowImageView!
    @IBOutlet weak var flashOffBtn: RoundedShadowButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var roundedShadowView: RoundedShadowView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Properties
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    var flashControlState: FlashState = .off
    var speechSynthesizer = AVSpeechSynthesizer()
    
    //MARK: - Main Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confidenceLbl.text = ""
        activityIndicator.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
        speechSynthesizer.delegate = self
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
    
    //MARK: - Custom Methods
    
    @objc func didTapCameraView() {
        self.cameraView.isUserInteractionEnabled = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        let settings = AVCapturePhotoSettings()

        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        
        if flashControlState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        cameraOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    func resultsMethod(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        for classification in results {
            if classification.confidence < 0.5 {
                let unkownObjectMessage = "I'm not sure what this is. Please try again."
                self.itemNameLbl.text = unkownObjectMessage
                synthesizeSpeech(fromString: unkownObjectMessage)
                self.confidenceLbl.text = ""
                break
            } else {
                let identification = classification.identifier
                let confidence = Int(classification.confidence * 100)
                self.itemNameLbl.text = identification
                self.confidenceLbl.text = "CONFIDENCE: \(confidence)%"
                let completeSentence = "This looks like a \(identification) and I am \(confidence) percent sure."
                synthesizeSpeech(fromString: completeSentence)
                break
            }
        }
        
    }
    
    func synthesizeSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterance)
    }
    
    //MARK: - IBActions

    @IBAction func flashOffBtnWasPressed(_ sender: Any) {
        switch flashControlState {
        case .off:
            flashOffBtn.setTitle("FLASH ON", for: .normal)
            flashControlState = .on
        case .on:
            flashOffBtn.setTitle("FLASH OFF", for: .normal)
            flashControlState = .off
        }
    }
}

//MARK: - AVCapturePhotoCaptureDelegate

extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
                
            } catch {
                debugPrint(error)
            }
            
            let image = UIImage(data: photoData!)
            self.itemImageView.image = image
            
        }
    }
}

//MARK: - AVSpeechSynthesizerDelegate

extension CameraVC: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.cameraView.isUserInteractionEnabled = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
}



