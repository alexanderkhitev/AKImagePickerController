//
//  CameraSliderDelegate.swift
//  ImagePicker
//
//  Created by Alexsander Khitev on 2/23/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import Foundation

@objc protocol CameraSliderDelegate {
    
    @objc optional func didChangeValue(_ value: CGFloat)
    
}
