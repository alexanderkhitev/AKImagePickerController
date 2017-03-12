//
//  SheetPreviewCollectionViewCell.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class SheetPreviewCollectionViewCell: SheetCollectionViewCell {
    
    var collectionView: UICollectionView? {
        willSet {
            if let collectionView = collectionView {
                collectionView.removeFromSuperview()
            }
            
            if let collectionView = newValue {
                collectionView.translatesAutoresizingMaskIntoConstraints = false
                addSubview(collectionView)
            }
        }
    }
    
    // MARK: - Flags
    
    private var isDidSetupConstraints = false
    
    // MARK: - Other Methods
    
    override func prepareForReuse() {
        isDidSetupConstraints = false 
        collectionView = nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUIElementsPositions()
//        collectionView?.frame = UIEdgeInsetsInsetRect(bounds, backgroundInsets)
    }
    
    private func setupUIElementsPositions() {
        if isDidSetupConstraints == false {
            collectionView?.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            collectionView?.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            collectionView?.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            collectionView?.heightAnchor.constraint(equalToConstant: 100).isActive = true
            isDidSetupConstraints = true
        }
    }
    
}
