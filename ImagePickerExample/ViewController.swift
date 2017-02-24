//
//  ViewController.swift
//  ImagePickerExample
//
//  Created by Alexsander Khitev on 2/23/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import UIKit
import ImagePickerController
import Photos

class ViewController: UIViewController {
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .system)
        button.setTitle("Tap Me!", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 150).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.addTarget(self, action: #selector(presentImagePickerSheet(_:)), for: .touchUpInside)
    }
    
    // MARK: - Other Methods
    
    
    func presentImagePickerSheet(_ gestureRecognizer: UITapGestureRecognizer) {
        let presentImagePickerController: (UIImagePickerControllerSourceType) -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            var sourceType = source
            if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                sourceType = .photoLibrary
            }
            controller.sourceType = sourceType
            
            self.present(controller, animated: true, completion: nil)
        }
        
        let imagePickerController = ImagePickerController(mediaType: .image)
        imagePickerController.delegate = self
        
//        imagePickerController.addAction(ImagePickerAction(title: NSLocalizedString("Choose Photo", comment: "Action Title"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title") as NSString, $0) as String}, handler: { _ in
//            presentImagePickerController(.photoLibrary)
//        }, secondaryHandler: { _, numberOfPhotos in
//            
//        }))
        
        
        imagePickerController.addAction(ImagePickerAction(title: "Choose Photo", style: .photoLibrary))
        
        imagePickerController.addAction(ImagePickerAction(cancelTitle: NSLocalizedString("Cancel", comment: "Action Title")))
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ImagePickerSheetControllerDelegate
extension ViewController: ImagePickerControllerDelegate {
    
    func controllerWillEnlargePreview(_ controller: ImagePickerController) {
        print("Will enlarge the preview")
    }
    
    func controllerDidEnlargePreview(_ controller: ImagePickerController) {
        print("Did enlarge the preview")
    }
    
    func controller(_ controller: ImagePickerController, willSelectAsset asset: PHAsset) {
        print("Will select an asset")
    }
    
    func controller(_ controller: ImagePickerController, didSelectAsset asset: PHAsset) {
        print("Did select an asset")
    }
    
    func controller(_ controller: ImagePickerController, willDeselectAsset asset: PHAsset) {
        print("Will deselect an asset")
    }
    
    func controller(_ controller: ImagePickerController, didDeselectAsset asset: PHAsset) {
        print("Did deselect an asset")
    }
    
}
