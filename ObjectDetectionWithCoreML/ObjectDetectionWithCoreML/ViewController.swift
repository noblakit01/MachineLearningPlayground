//
//  ViewController.swift
//  ObjectDetectionWithCoreML
//
//  Created by luantran on 10/17/18.
//  Copyright © 2018 mowede. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
  
  var session: AVCaptureSession!
  var input: AVCaptureInput?
  var output: AVCaptureVideoDataOutput!
  
  var cameraQueue: DispatchQueue!
  
  @IBOutlet weak var previewView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    DispatchQueue(label: "CameraInitialize").async { [weak self] in
      self?.initializeCamera()
    }
  }
  
  private func initializeCamera() {
    session = AVCaptureSession()
    
    initializeInput()
    initializeOutput()
  }
  
  private func initializeInput() {
    do {
      if let captureDevice = AVCaptureDevice.default(for: .video) {
        input = try AVCaptureDeviceInput(device: captureDevice)
        
        if let input = input {
          session?.addInput(input)
        }
      }
    } catch {
      print(error)
    }
  }
  
  private func initializeOutput() {
    output = AVCaptureVideoDataOutput()
    output.alwaysDiscardsLateVideoFrames = true
    
    cameraQueue = DispatchQueue(label: "CameraQueue")
    output.setSampleBufferDelegate(self, queue: cameraQueue)
    
    if session.canAddOutput(output) {
      session.addOutput(output)
    }
  }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    let bufferIsValid = CMSampleBufferIsValid(sampleBuffer)
    guard bufferIsValid else {
      print("ALERT!!! ALERT!!! Buffer is not valid!")
      return
    }
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      print("ALERT!!! ALERT!!! Can't get image buffer")
      return
    }
    let ciImage = CIImage(cvImageBuffer: imageBuffer)
    let image = UIImage(ciImage: ciImage)
    DispatchQueue.main.async { [weak self] in
      self?.previewView.image = image
    }
  }
  
}


