//
//  CameraViewControllerDelegate.swift
//  ImagePickerController
//
//  Created by Alexsander Khitev on 2/28/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import Foundation

@objc protocol CameraViewControllerDelegate {
    
    @objc optional func didCapturePhoto(_ cameraViewController: CameraViewController, photo: UIImage)
    @objc optional func willHide()

    
}
