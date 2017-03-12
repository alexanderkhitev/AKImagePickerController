//
//  ImagePickerControllerDelegate.swift
//  ImagePickerController
//
//  Created by Alexsander Khitev on 2/27/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import Foundation
import Photos

@objc public protocol AKImagePickerControllerDelegate {
    
    @objc optional func akImagePickerController(_ image: UIImage, with cropRect: CGRect, angle: Int)
    
    // MARK: - Lifecycle 
    
    @objc optional func akImagePickerControllerDidDisappear()
    @objc optional func akImagePickerControllerWillDisappear()

    
}
