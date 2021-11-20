//
//  ViewController.swift
//  CameraApp
//
//  Created by William Hahn on 11/20/21.
//

import UIKit
import AVKit
import Foundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Camera time!
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        // Define the camera as a physical device
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        // Create an input through which to capture data from the defined device
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        // Add the new input to the session
        session.addInput(input)
        
        session.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        session.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            // print(finishedRequest.results)
            
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
}
