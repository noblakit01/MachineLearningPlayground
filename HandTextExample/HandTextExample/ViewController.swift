//
//  ViewController.swift
//  HandTextExample
//
//  Created by luantran on 10/19/18.
//  Copyright © 2018 mowede. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    private let signatureViewController = SignatureDrawingViewController()
    
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var detectButton: UIBarButtonItem!
    @IBOutlet weak var classificationLabel: UILabel!
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: MNIST().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .scaleFit
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        signatureViewController.delegate = self
        addChild(signatureViewController)
        view.addSubview(signatureViewController.view)
        signatureViewController.didMove(toParent: self)
    }
    
    @IBAction func reset() {
        signatureViewController.reset()
    }
    
    @IBAction func detect() {
        guard let image = signatureViewController.fullSignatureImage else {
            return
        }
        updateClassifications(for: image)
    }
    
    func updateClassifications(for image: UIImage) {
        classificationLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create \(CIImage.self) from \(image).")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.classificationLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
}

extension ViewController: SignatureDrawingViewControllerDelegate {
    
    func signatureDrawingViewControllerIsEmptyDidChange(controller: SignatureDrawingViewController, isEmpty: Bool) {
        resetButton.isEnabled = !isEmpty
        detectButton.isEnabled = !isEmpty
    }
    
    
}

