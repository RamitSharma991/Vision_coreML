//
//  CameraVC.swift
//  VisionApp
//
//  Created by Ramit sharma on 06/08/18.
//  Copyright © 2018 Ramit sharma. All rights reserved.
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
    
    //Outlets
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    var flashControlState: FlashState = .off
    var speechSynth = AVSpeechSynthesizer()
    
    @IBOutlet weak var captureImgview: RoundedImageView!
    @IBOutlet weak var flashOutlet: RoundedButtons!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var roundedLblView: RoundedShadowView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
        speechSynth.delegate = self
        spinner.isHidden = true
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
                captureSession.canAddOutput(cameraOutput!)
                
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer!)
                captureSession.startRunning()
            }
        } catch  {
            debugPrint(error)
        }
    }
    
    @objc func didTapCameraView() {
        
        self.cameraView.isUserInteractionEnabled = false
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        
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
        //change lbl txt
        
        guard let results = request.results as? [VNClassificationObservation] else {return}
        
        for classification in results {
                if classification.confidence < 0.5 {
                let unknownObjectMessage = "Not sure about this. Try again"
                self.identificationLbl.text = unknownObjectMessage
                    synthSpeech(fromString: unknownObjectMessage)
                self.confidenceLbl.text = ""
                break
            } else {
                var identification = classification.identifier
                var confidence = Int(classification.confidence * 100)
                self.identificationLbl.text = identification
                self.confidenceLbl.text = "CONFIDENCE: \(confidence)%"
                let completeSentence = "This looks like a \(identification) and i'm \(confidence) perscent sure"
                    synthSpeech(fromString: completeSentence)
                break
            }
        }
    }
    
    func synthSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynth.speak(speechUtterance)
        
    }
    
    @IBAction func flashBtn(_ sender: Any) {
        switch flashControlState {
        case .off:
            flashOutlet.setTitle("Flash On", for: .normal)
            flashControlState = .on
        case .on:
            
            flashOutlet.setTitle("Flash Off", for: .normal)
            flashControlState = .off
            
        
        }
    
    }
    
    
}


extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        }else{
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
            self.captureImgview.image = image
            
        }
        
        
    }
    
}


extension CameraVC: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        self.cameraView.isUserInteractionEnabled = true
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
        
    }
}



























