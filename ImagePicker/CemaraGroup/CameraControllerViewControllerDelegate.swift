//
//  CameraControllerViewControllerDelegate.swift
//  ImagePickerController
//
//  Created by Alexsander Khitev on 2/23/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import Foundation

@objc protocol CameraControllerViewControllerDelegate {
    
    @objc optional func willHide()
    
}
