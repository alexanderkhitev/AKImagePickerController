//
//  CameraSlider.swift
//  ImagePicker
//
//  Created by Alexsander Khitev on 2/23/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import Foundation
import UIKit

class CameraSlider: UIControl {
    
    // MARK: - Delegates
    
    weak var delegate: CameraSliderDelegate?
    
    // MARK: - Data
    
    var minumValue: CGFloat = 0
    var maximumValue: CGFloat = 0
    
    var value: CGFloat = 1 {
        didSet {
            debugPrint("DidSet", value)
            // call animation
            animationByValue(value)
        }
    }
    
    // MARK: - Position's values
    fileprivate let thumbSizeValue: CGFloat = 25
    fileprivate let thumbY: CGFloat = 7.5
    fileprivate let trackY: CGFloat = 7.5 + 5
    
    fileprivate let trackHeight: CGFloat = 10
    
    fileprivate let underThumbValue: CGFloat = 2
    
    // MARK: - UI Elements
    
    fileprivate let thumb = ThumbView(frame: .zero)
    fileprivate let trackView = TrackView(frame: .zero)
    
    // MARK: - Constraints
    
    fileprivate var thumbXConstraint: NSLayoutConstraint!
    fileprivate var maximumTrackRightConstraint: NSLayoutConstraint!
    
    // MARK: - Hidding
    
    private var timer: Timer!
    
    // MARK: - lifecycle
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        addUIElements()
        setupViewsSettings()
    }
    
    
    // MARK: - UI
    
    private func addUIElements() {
        thumb.translatesAutoresizingMaskIntoConstraints = false
        addSubview(thumb)
        thumb.layer.zPosition = 1
        
        trackView.translatesAutoresizingMaskIntoConstraints = false
        thumb.addSubview(trackView)
        trackView.layer.zPosition = 0
        
        thumb.widthAnchor.constraint(equalToConstant: thumbSizeValue).isActive = true
        thumb.heightAnchor.constraint(equalToConstant: thumbSizeValue).isActive = true
        thumb.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        thumbXConstraint = thumb.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        thumbXConstraint.isActive = true
        
        
        trackView.heightAnchor.constraint(equalToConstant: trackHeight).isActive = true
        trackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        maximumTrackRightConstraint = trackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10)
        maximumTrackRightConstraint.isActive = true
        trackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
    }
    
    private func setupViewsSettings() {
        thumb.backgroundColor = .clear
        thumb.isUserInteractionEnabled = true
        thumb.layer.cornerRadius = thumbSizeValue / 2
        thumb.layer.masksToBounds = false
        thumb.layer.borderColor = UIColor.yellow.cgColor
        thumb.layer.borderWidth = 2
        
        // tracks
        
        trackView.backgroundColor = .clear
        
        
        trackView.maxX = thumbSizeValue
        trackView.maxWidth = UIScreen.main.bounds.width - 30 - thumbSizeValue
        trackView.minWidth = 0
        trackView.setNeedsDisplay()
        trackView.layer.cornerRadius = 5
        trackView.layer.masksToBounds = true
    }
    
    // MARK: - Delegates
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        animation(touch)
        
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        animation(touch)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        guard touch != nil else { return }
        animation(touch!)
    }
    
    // MARK: - Animation
    
    private func animation(_ touch: UITouch) {
        let point = touch.location(in: self)
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            guard self != nil else { return }
            
            // stop timer
            self!.stopHiddingTimer()
            
            if point.x > 0 && point.x < self!.frame.width - self!.thumbSizeValue {
                
                self!.trackView.maxX = point.x + self!.thumbSizeValue
                self!.trackView.maxWidth =  UIScreen.main.bounds.width - 30 - self!.thumbSizeValue - point.x - 2
                self!.trackView.minWidth = point.x + 2 - self!.thumbSizeValue / 2
                self!.trackView.setNeedsDisplay()
                self!.thumbXConstraint.constant = point.x
                
                self!.changeValue(point.x)
                
                // hidding timer
                self?.startHiddingTimer()
            }
        }) { (completion) in
            
        }
    }
    
    private func animationByValue(_ currentValue: CGFloat) {
        let onePercentFrame = (bounds.width - thumbSizeValue) / 100
        let oneValuePercent = (maximumValue - minumValue) / 100
        let currentPercents = currentValue / oneValuePercent - 25 // because minus 1 / 4
        let X = currentPercents * onePercentFrame
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            guard self != nil else { return }
            // stop timer
            self!.stopHiddingTimer()
            
            let checkValue = self!.bounds.width - self!.thumbSizeValue
            debugPrint("X", X, "checkValue", checkValue)
            
            if X <= checkValue  {
                self!.trackView.maxX = X + self!.thumbSizeValue
                self!.trackView.maxWidth =  UIScreen.main.bounds.width - 30 - self!.thumbSizeValue - X - 2
                self!.trackView.minWidth = X + 2 - self!.thumbSizeValue / 2
                self!.trackView.setNeedsDisplay()
                self!.thumbXConstraint.constant = X
                // hidding timer
                self?.startHiddingTimer()
            } else {
                debugPrint("animation NOT perfrom")
            }
        }) { (completion) in
            
        }
    }
    
    private func changeValue(_ pointX: CGFloat) {
        let onePercentFrame = (bounds.width - thumbSizeValue) / 100
        let oneValuePercent = (maximumValue - minumValue) / 100
        let frameValueMultipler = pointX / onePercentFrame
        let result = oneValuePercent * frameValueMultipler + minumValue
        delegate?.didChangeValue?(result)
    }
    
    // MARK: - Hidding functions
    
    private func startHiddingTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { [weak self] (timer) in
            self?.hide()
        })
    }
    
    private func stopHiddingTimer() {
        if timer != nil {
            timer.invalidate()
        }
    }
    
    @objc private func hide() {
        isHidden = true
    }
    
    
}

fileprivate class ThumbView: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
}

fileprivate class TrackView: UIView {
    
    // MARK: - Flags
    
    private var isFirstCall = true
    
    // MARK: - values
    
    var minWidth: CGFloat = 0
    var maxX: CGFloat = 0
    var maxWidth: CGFloat = 0
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !isFirstCall {
            minWidth += 2
        }
        isFirstCall = false
        let color = UIColor.gray.withAlphaComponent(0.3).cgColor
        guard let  minContext = UIGraphicsGetCurrentContext() else { return }
        minContext.setFillColor(color)
        minContext.fill(CGRect(x: 0, y: 0, width: minWidth, height: 10))
        
        guard let  maxContext = UIGraphicsGetCurrentContext() else { return }
        maxContext.setFillColor(color)
        maxX = maxX - 10 - 2
        maxContext.fill(CGRect(x: maxX, y: 0, width: maxWidth, height: 10))
    }
    
}
