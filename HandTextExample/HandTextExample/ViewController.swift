//
//  ViewController.swift
//  HandTextExample
//
//  Created by luantran on 10/19/18.
//  Copyright © 2018 mowede. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let signatureViewController = SignatureDrawingViewController()
    
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var detectButton: UIBarButtonItem!
    
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
        
    }
}

extension ViewController: SignatureDrawingViewControllerDelegate {
    
    func signatureDrawingViewControllerIsEmptyDidChange(controller: SignatureDrawingViewController, isEmpty: Bool) {
        resetButton.isEnabled = !isEmpty
        detectButton.isEnabled = !isEmpty
    }
    
    
}

