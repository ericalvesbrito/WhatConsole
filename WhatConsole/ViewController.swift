//
//  ViewController.swift
//  WhatConsole
//
//  Created by Eric Alves Brito on 29/10/20.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit
import Vision

final class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelResult: UILabel!
    
    // MARK: - Properties
    lazy var classificationRequest: VNCoreMLRequest = {
        let visionModel = try! VNCoreMLModel(for: Console().model)
        let request = VNCoreMLRequest(model: visionModel) { (request, error) in
            self.processObservation(for: request)
        }
        request.imageCropAndScaleOption = .scaleFit
        return request
    }()
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func showCamera(_ sender: Any) {
        showPicker(sourceType: .camera)
    }
    
    @IBAction func showLibrary(_ sender: Any) {
        showPicker(sourceType: .photoLibrary)
    }
    
    // MARK: - Methods
    func showPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func classify(image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let ciimage = CIImage(image: image)!
            let orientation = CGImagePropertyOrientation(image.imageOrientation)
            let handler = VNImageRequestHandler(ciImage: ciimage, orientation: orientation)
            try! handler.perform([self.classificationRequest])
        }
    }
    
    func processObservation(for request: VNRequest) {
        DispatchQueue.main.async {
            guard let observation = (request.results as? [VNClassificationObservation])?.first else {return}
            let confidence = "\(observation.confidence * 100)%"
            self.labelResult.text = "\(confidence): \(observation.identifier)"
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            classify(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension CGImagePropertyOrientation {
  init(_ orientation: UIImage.Orientation) {
    switch orientation {
    case .up:
        self = .up
    case .upMirrored:
        self = .upMirrored
    case .down:
        self = .down
    case .downMirrored:
        self = .downMirrored
    case .left:
        self = .left
    case .leftMirrored:
        self = .leftMirrored
    case .right:
        self = .right
    case .rightMirrored:
        self = .rightMirrored
    @unknown default:
        fatalError()
    }
  }
}
