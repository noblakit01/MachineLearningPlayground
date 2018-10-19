//
//  MobileNetModelTests.swift
//  ObjectDetectionWithCoreMLTests
//
//  Created by luantran on 10/17/18.
//  Copyright © 2018 mowede. All rights reserved.
//

import XCTest
@testable import ObjectDetectionWithCoreML

class MobileNetModelTests: XCTestCase {
    
    let model = MobileNet()
    
    var dogImages = [UIImage]()
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: type(of: self))
        let imageNames = ["dog_0", "dog_1", "dog_2"]
        for imageName in imageNames {
            guard let image = UIImage(named: imageName, in: bundle, compatibleWith: nil) else {
                continue
            }
            dogImages.append(image)
        }
    }
    
    func testDog() {
        for image in dogImages {
            let scaledImage = ImageProcessor.scale(image: image, to: CGSize(width: 224, height: 224))
            let attactment = XCTAttachment(image: scaledImage)
            attactment.lifetime = .keepAlways
            add(attactment)
            guard let cgImage = scaledImage.cgImage else {
                continue
            }
            guard let pixelBuffer = ImageProcessor.pixelBuffer(forImage: cgImage) else {
                continue
            }
            do {
                let output = try model.prediction(image: pixelBuffer)
                print("Ahaha \(output.classLabel)")
            } catch {
                print(error)
            }
        }
    }
    
}
