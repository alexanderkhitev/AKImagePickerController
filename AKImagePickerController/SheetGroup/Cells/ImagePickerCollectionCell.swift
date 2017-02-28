//
//  ImagePickerCollectionCell.swift
//  SwiftChats
//
//  Created by Alexsander Khitev on 2/7/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import UIKit

class ImagePickerCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var representedAssetIdentifier = ""


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupImageViewsSettings()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }

    private func setupImageViewsSettings() {
        photoImageView.layer.cornerRadius = 7
        photoImageView.layer.masksToBounds = true 
    }
    
}
