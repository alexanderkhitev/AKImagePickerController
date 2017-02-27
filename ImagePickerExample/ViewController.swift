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
    
    // MARK: - IBOutlet
    
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    
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
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        button.addTarget(self, action: #selector(presentImagePickerSheet(_:)), for: .touchUpInside)
    }
    
    // MARK: - Other Methods
    
    
    func presentImagePickerSheet(_ gestureRecognizer: UITapGestureRecognizer) {

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

// MARK: - ImagePickerSheetControllerDelegate
extension ViewController: ImagePickerControllerDelegate {

    func imagePickerController(_ image: UIImage, with cropRect: CGRect, angle: Int) {
        debugPrint("imagePickerController", image, "cropRect", cropRect)
        avatarImageView.image = image 
    }
    
}
