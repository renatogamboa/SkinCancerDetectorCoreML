//
//  ViewController.swift
//  SkinCancerDetectorApp
//
//  Created by Renato Gamboa on 10/22/18.
//  Copyright © 2018 RenatoGamboa. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet var cameraView: UIView!
    
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var textLabel2: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        
        
        previewLayer.frame = self.cameraView.layer.bounds
        previewLayer.contentsGravity = kCAGravityCenter
        
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        
        self.cameraView.layer.addSublayer(previewLayer)
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.addOutput(dataOutput)
        
        
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //print(Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: SkinCancerDetectionV3().model) else { return }
        
        let request = VNCoreMLRequest(model: model) {
            (finishedReq, err) in
            
            //print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            
            DispatchQueue.main.async {
                let snippet = firstObservation.identifier
                
                /*
                if let range = snippet.range(of: " ") {
                    let trimmedText = snippet[range.upperBound...]
                    
                    self.textLabel.text = "\(trimmedText)"
                    
                }
 
 */
                
                self.textLabel.text = "\(snippet)"
                
                
                self.textLabel2.text = "\(Double(firstObservation.confidence * 100).roundTo2f())%"
                
            }
 
        }
        
        
        
        
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    

    


}

extension Double {
    func roundTo2f() -> NSString
    {
        return NSString(format: "%.2f", self)
    }
}

