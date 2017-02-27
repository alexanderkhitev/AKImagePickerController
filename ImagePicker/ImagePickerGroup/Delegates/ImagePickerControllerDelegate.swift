//
//  ImagePickerControllerDelegate.swift
//  ImagePickerController
//
//  Created by Alexsander Khitev on 2/27/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import Foundation
import Photos

@objc public protocol ImagePickerControllerDelegate {
    
    @objc optional func controllerWillEnlargePreview(_ controller: ImagePickerController)
    @objc optional func controllerDidEnlargePreview(_ controller: ImagePickerController)
    
    @objc optional func controller(_ controller: ImagePickerController, willSelectAsset asset: PHAsset)
    @objc optional func controller(_ controller: ImagePickerController, didSelectAsset asset: PHAsset)
    
    @objc optional func controller(_ controller: ImagePickerController, willDeselectAsset asset: PHAsset)
    @objc optional func controller(_ controller: ImagePickerController, didDeselectAsset asset: PHAsset)
    
    @objc optional func imagePickerController(_ image: UIImage, with cropRect: CGRect, angle: Int)
    
}
