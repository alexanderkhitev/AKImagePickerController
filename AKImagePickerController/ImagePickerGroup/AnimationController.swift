//
//  AnimationController.swift
//  ImagePickerSheet
//
//  Created by Alexsander Khitev on 2/23/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import UIKit

class AnimationController: NSObject {
    
    let imagePickerSheetController: AKImagePickerController
    let presenting: Bool
    
    // MARK: - Initialization
    
    init(imagePickerSheetController: AKImagePickerController, presenting: Bool) {
        self.imagePickerSheetController = imagePickerSheetController
        self.presenting = presenting
    }
    
    // MARK: - Animation
    
    fileprivate func animatePresentation(_ context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        containerView.addSubview(imagePickerSheetController.view)
        
        let sheetOriginY = imagePickerSheetController.sheetCollectionView.frame.origin.y
        imagePickerSheetController.sheetCollectionView.frame.origin.y = containerView.bounds.maxY
        imagePickerSheetController.backgroundView.alpha = 0
        
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, options: .curveEaseOut, animations: { () -> Void in
            self.imagePickerSheetController.sheetCollectionView.frame.origin.y = sheetOriginY
            self.imagePickerSheetController.backgroundView.alpha = 1
        }, completion: { _ in
            context.completeTransition(true)
        })
    }
    
    fileprivate func animateDismissal(_ context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, options: .curveEaseIn, animations: { () -> Void in
            self.imagePickerSheetController.sheetCollectionView.frame.origin.y = containerView.bounds.maxY
            self.imagePickerSheetController.backgroundView.alpha = 0
        }, completion: { _ in
            self.imagePickerSheetController.view.removeFromSuperview()
            context.completeTransition(true)
        })
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning
extension AnimationController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            animatePresentation(transitionContext)
        }
        else {
            animateDismissal(transitionContext)
        }
    }
    
}
