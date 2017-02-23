//
//  ImagePickerLiveCameraCollectionCell.swift
//  SwiftChats
//
//  Created by Alexsander Khitev on 2/7/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePickerLiveCameraCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupViewSettings()
        setupUIHierarchy()
    }


    private func setupUIHierarchy() {
        containerView.bringSubview(toFront: imageView)
        imageView.layer.zPosition = 2
    }
    
}


extension ImagePickerLiveCameraCollectionCell {
    
    fileprivate func setupViewSettings() {
        containerView.layer.cornerRadius = 7
        containerView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 7
        contentView.layer.masksToBounds = true
    }
    
}
