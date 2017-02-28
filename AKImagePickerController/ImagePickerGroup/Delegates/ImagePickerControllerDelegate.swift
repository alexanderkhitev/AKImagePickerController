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
    
    @objc optional func controllerWillEnlargePreview(_ controller: AKImagePickerController)
    @objc optional func controllerDidEnlargePreview(_ controller: AKImagePickerController)
    
    @objc optional func controller(_ controller: AKImagePickerController, willSelectAsset asset: PHAsset)
    @objc optional func controller(_ controller: AKImagePickerController, didSelectAsset asset: PHAsset)
    
    @objc optional func controller(_ controller: AKImagePickerController, willDeselectAsset asset: PHAsset)
    @objc optional func controller(_ controller: AKImagePickerController, didDeselectAsset asset: PHAsset)
    
    @objc optional func akImagePickerController(_ image: UIImage, with cropRect: CGRect, angle: Int)
    
}
