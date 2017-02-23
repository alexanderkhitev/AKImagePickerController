//
//  CameraControllerViewController.swift
//  ImagePicker
//
//  Created by Alexsander Khitev on 2/23/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

class CameraControllerViewController: UIViewController {
    
    // MARK: - UI
    
    private let bottomBar = UIView()
    private let topBar = UIView()
    fileprivate let cameraPreviewView = UIView()
    private let shotButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let switchCameraButton = UIButton(type: .system)
    // flash
    fileprivate let flashSwitchImageView = UIImageView()
    fileprivate let flashTouchView = UIView()
    // Flash mode buttons
    fileprivate let flashAutoButton = UIButton(type: .custom)
    fileprivate let flashOnButton = UIButton(type: .custom)
    fileprivate let flashOffButton = UIButton(type: .custom)
    
    // Slider
    
    fileprivate let cameraSlider = CameraSlider(frame: .zero)
    
    // MARK: - Camera
    
    var cameraEngine: CameraEngine!
    
    // MARK: - Flags
    
    fileprivate var areTorchElementsVisibles = false
    
    // MARK: - Data
    
    var startOrientation: UIDeviceOrientation = UIDeviceOrientation(rawValue: 1)!
    
    // MARK: - Images
    
    fileprivate struct FlashImage {
        let turnedOn = UIImage(named: "FlashTurnedOn", in: Bundle(identifier: "com.alexsander-khitev.ImageControllerPicker"), compatibleWith: nil)
        let turnedOff = UIImage(named: "FlashTurnedOff", in: Bundle(identifier: "com.alexsander-khitev.ImageControllerPicker"), compatibleWith: nil)
    }
    
    // MARK: - Managers
    
    fileprivate let coreMotionManager = CMMotionManager()
    
    // MARK: - Enums 
    
    fileprivate enum CurrentOrientation: String {
        case portrait, portraitUpsideDown, landscapeRight, landscapeLeft
    }
    
    // MARK: - Hidding data
    
    fileprivate var hideDurationTime = 0.5
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // settings
        setupSettings()
        // observers
        addObservers()
        // UI
        setupUISettings()
        addUIElements()
        /// orienation
        addCameraLayer(startOrientation)
        setupViewsSettings()
        // Buttons
        setupButtonsSettings()
        setupButtonsTargets()
        // ImageViews
        setupFlashElementsSettings()
        // Camera
        setupFlashMode(.auto)
        // Camera pinch
        addZoomGestureRecognizer()
        // slider
        setupCameraSliderSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateCameraView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("CameraController is deinit")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupUIElementsPositions()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    // MARK: - Settings
    
    private func setupSettings() {
        definesPresentationContext = true
    }
    
    // MARK: - UI
    
    private func setupUISettings() {
        view.backgroundColor = .clear
    }
    
    private func addUIElements() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        cameraPreviewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraPreviewView)
        
        cameraSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraSlider)
        
        // buttons
        shotButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(shotButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(cancelButton)
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(switchCameraButton)
        // flash
        flashSwitchImageView.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(flashSwitchImageView)
        flashTouchView.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(flashTouchView)
        flashAutoButton.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(flashAutoButton)
        flashOnButton.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(flashOnButton)
        flashOffButton.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(flashOffButton)
    }
    
    private func setupUIElementsPositions() {
        bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomBar.heightAnchor.constraint(equalToConstant: 96).isActive = true
        
        topBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        cameraPreviewView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor).isActive = true
        cameraPreviewView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        cameraPreviewView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        cameraPreviewView.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        
        // buttons
        shotButton.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor).isActive = true
        shotButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor).isActive = true
        shotButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        shotButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        cancelButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: bottomBar.leftAnchor, constant: 20).isActive = true
        
        switchCameraButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor).isActive = true
        switchCameraButton.rightAnchor.constraint(equalTo: bottomBar.rightAnchor, constant: -20).isActive = true
        switchCameraButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        switchCameraButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        // Flash
        
        flashSwitchImageView.widthAnchor.constraint(equalToConstant: 13).isActive = true
        flashSwitchImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        flashSwitchImageView.leftAnchor.constraint(equalTo: topBar.leftAnchor, constant: 18).isActive = true
        flashSwitchImageView.centerYAnchor.constraint(equalTo: topBar.centerYAnchor).isActive = true
        
        flashTouchView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        flashTouchView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        flashTouchView.leftAnchor.constraint(equalTo: topBar.leftAnchor, constant: 0).isActive = true
        flashTouchView.centerYAnchor.constraint(equalTo: topBar.centerYAnchor).isActive = true
        
        // mode
        
        flashOnButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor).isActive = true
        flashOnButton.centerXAnchor.constraint(equalTo: topBar.centerXAnchor).isActive = true
        flashOnButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        flashOnButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        flashAutoButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor).isActive = true
        flashAutoButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        flashAutoButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        flashAutoButton.rightAnchor.constraint(equalTo: flashOnButton.leftAnchor, constant: -40).isActive = true
        
        
        flashOffButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor).isActive = true
        flashOffButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        flashOffButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        flashOffButton.leftAnchor.constraint(equalTo: flashOnButton.rightAnchor, constant: 40).isActive = true
        
        
        
        let widthValue = UIScreen.main.bounds.width
        let heightValue = UIScreen.main.bounds.height
        
        cameraSlider.heightAnchor.constraint(equalToConstant: 35).isActive = true
        if widthValue < heightValue {
            cameraSlider.widthAnchor.constraint(equalTo: cameraPreviewView.widthAnchor, multiplier: 1, constant: -30).isActive = true
            
        } else {
            cameraSlider.widthAnchor.constraint(equalTo: cameraPreviewView.heightAnchor, multiplier: 1, constant: -30).isActive = true
        }
        cameraSlider.bottomAnchor.constraint(equalTo: cameraPreviewView.bottomAnchor, constant: -30).isActive = true
        cameraSlider.centerXAnchor.constraint(equalTo: cameraPreviewView.centerXAnchor).isActive = true
    }
    
    // MARK: - UI Elements settings
    
    private func setupViewsSettings() {
        bottomBar.backgroundColor = .black
        topBar.backgroundColor = .black
        cameraPreviewView.backgroundColor = .black
    }
    
    private func setupButtonsSettings() {
        let bundle = Bundle(identifier: "com.alexsander-khitev.ImageControllerPicker")
        let shotImage = UIImage(named: "ShotCameraIcon", in: bundle, compatibleWith: nil)
        shotButton.setImage(shotImage, for: .normal)
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        let switchIcon = UIImage(named: "SwitchCameraIcon", in: bundle, compatibleWith: nil)
        switchCameraButton.setImage(switchIcon, for: .normal)
        switchCameraButton.tintColor = .white
        
        flashOnButton.setTitle("On", for: .normal)
        flashOffButton.setTitle("Off", for: .normal)
        flashAutoButton.setTitle("Auto", for: .normal)
        
        flashOnButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        flashOffButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        flashAutoButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        flashOnButton.isHidden = true
        flashOffButton.isHidden = true
        flashAutoButton.isHidden = true
    }
    
    private func setupButtonsTargets() {
        cancelButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(switchCameraDevice), for: .touchUpInside)
        // torch
        flashOnButton.addTarget(self, action: #selector(onTorchAction), for: .touchUpInside)
        flashOffButton.addTarget(self, action: #selector(offTorchAction), for: .touchUpInside)
        flashAutoButton.addTarget(self, action: #selector(autoTorchAction), for: .touchUpInside)
        shotButton.addTarget(self, action: #selector(shotAction), for: .touchUpInside)
    }
    
    private func setupFlashElementsSettings() {
        flashSwitchImageView.image = FlashImage().turnedOn
        flashSwitchImageView.tintColor = .white
        flashSwitchImageView.contentMode = .scaleAspectFit
        flashSwitchImageView.isUserInteractionEnabled = true
        
        flashTouchView.isUserInteractionEnabled = true
        flashTouchView.backgroundColor = .clear
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(switchFlashModeElements))
        flashTouchView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Notification center
    
    private func addObservers() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(changeUIElementsPositions), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    // MARK: - Rotation
    
    @objc private func changeUIElementsPositions() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            if UIDevice.current.orientation == .landscapeLeft {
                let rotation = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                self?.switchCameraButton.transform = rotation
                self?.flashSwitchImageView.transform = rotation
            }
            if UIDevice.current.orientation == .landscapeRight {
                let transformRotation = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
                self?.switchCameraButton.transform = transformRotation
                self?.flashSwitchImageView.transform = transformRotation
            }
            
            if UIDevice.current.orientation == .portrait {
                let transformRotation = CGAffineTransform(rotationAngle: 0)
                self?.switchCameraButton.transform = transformRotation
                self?.flashSwitchImageView.transform = transformRotation
            }
            
            if UIDevice.current.orientation == .portraitUpsideDown {
                let transformRotation = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                self?.switchCameraButton.transform = transformRotation
                self?.flashSwitchImageView.transform = transformRotation
            }
            
        }) { (completion) in
            
        }
    }
    
}

// MARK: - Camera

extension CameraControllerViewController {
    
    // MARK: - Flash
    
    fileprivate func setupFlashMode(_ mode: AVCaptureFlashMode) {
        cameraEngine.flashMode = mode
    }
    
    @objc fileprivate func switchFlashModeElements() {
        flashOnButton.isHidden = areTorchElementsVisibles
        flashOffButton.isHidden = areTorchElementsVisibles
        flashAutoButton.isHidden = areTorchElementsVisibles
        
        // setup yellow color
        let flashMode: AVCaptureFlashMode = cameraEngine.flashMode
        
        switch flashMode {
        case .auto:
            flashAutoButton.setTitleColor(.yellow, for: .normal)
            flashOnButton.setTitleColor(.white, for: .normal)
            flashOffButton.setTitleColor(.white, for: .normal)
        case .on:
            flashOnButton.setTitleColor(.yellow, for: .normal)
            flashAutoButton.setTitleColor(.white, for: .normal)
            flashOffButton.setTitleColor(.white, for: .normal)
        case .off:
            flashOffButton.setTitleColor(.yellow, for: .normal)
            flashAutoButton.setTitleColor(.white, for: .normal)
            flashOnButton.setTitleColor(.white, for: .normal)
        }
        
        if areTorchElementsVisibles {
            areTorchElementsVisibles = false
        } else {
            areTorchElementsVisibles = true
        }
    }
    
    @objc fileprivate func autoTorchAction() {
        switchFlashModeElements()
        setupFlashMode(.auto)
        flashSwitchImageView.tintColor = .white
        flashSwitchImageView.image = FlashImage().turnedOn
        flashSwitchImageView.contentMode = .scaleAspectFit
    }
    
    @objc fileprivate func onTorchAction() {
        switchFlashModeElements()
        setupFlashMode(.on)
        flashSwitchImageView.tintColor = .yellow
        flashSwitchImageView.image = FlashImage().turnedOn
        flashSwitchImageView.contentMode = .scaleAspectFit
    }
    
    @objc fileprivate func offTorchAction() {
        switchFlashModeElements()
        setupFlashMode(.off)
        flashSwitchImageView.tintColor = .white
        flashSwitchImageView.image = FlashImage().turnedOff
        flashSwitchImageView.contentMode = .scaleAspectFill
    }
    
    
    @objc fileprivate func switchCameraDevice() {
        cameraSlider.isHidden = true
        cameraEngine.switchCurrentDevice()
    }
    
    @objc fileprivate func shotAction() {
        cameraEngine.capturePhoto { (image, error) -> (Void) in
            if error == nil {
                debugPrint("Here is an image")
            } else {
                debugPrint("error", error!.localizedDescription)
            }
        }
    }
    
    // MARK: - Zoom
    
    fileprivate func addZoomGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchCameraZoom(_:)))
        cameraPreviewView.addGestureRecognizer(pinchGestureRecognizer)
        cameraPreviewView.isUserInteractionEnabled = true
    }
    
    @objc private func pinchCameraZoom(_ gesture: UIPinchGestureRecognizer) {
        if cameraEngine.currentDevice == .back {
            let pinchVelocityDividerFactor: CGFloat = 5 // 5
            let desiredZoomFactor: CGFloat = cameraEngine.cameraZoomFactor + CGFloat(atan2f(Float(gesture.velocity), Float(pinchVelocityDividerFactor)))
            
            let maxZoomFactor: CGFloat = 5
            
            let zoomFactor = max(1, min(desiredZoomFactor, maxZoomFactor))
            
            changeSliderValue(zoomFactor)
            cameraEngine.cameraZoomFactor = zoomFactor
        }
    }
    
    fileprivate func setupCameraSliderSettings() {
        cameraSlider.minumValue = 1
        cameraSlider.maximumValue = 5
        cameraSlider.delegate = self
        cameraSlider.isHidden = true
    }
    
    // MARK: - Slider
    
    private func changeSliderValue(_ value: CGFloat) {
        cameraSlider.value = value
        cameraSlider.isHidden = false
    }
    
}

// MARK: - Camera Slider

extension CameraControllerViewController: CameraSliderDelegate {
    
    func didChangeValue(_ value: CGFloat) {
        cameraEngine.cameraZoomFactor = value
    }
    
}

// MARK: - Orientation 

extension CameraControllerViewController {
    
    fileprivate func detectHideOrientation() {
        coreMotionManager.accelerometerUpdateInterval = 0.1
        //  Using main queue is not recommended. So create new operation queue and pass it to startAccelerometerUpdatesToQueue.
        //  Dispatch U/I code to main thread using dispach_async in the handler.
        
        coreMotionManager.startAccelerometerUpdates(to: OperationQueue()) { [weak self] accelerometerData, _ in
            guard accelerometerData != nil else { return }
            
            let currentOrientation = abs(accelerometerData!.acceleration.y) < abs(accelerometerData!.acceleration.x)
                ?   accelerometerData!.acceleration.x > 0 ? CurrentOrientation.landscapeRight  :   CurrentOrientation.landscapeLeft
                :   accelerometerData!.acceleration.y > 0 ? CurrentOrientation.portraitUpsideDown   :   CurrentOrientation.portrait
            
            DispatchQueue.main.async {
                self?.hideAnimation(currentOrientation)
            }
            self?.coreMotionManager.stopAccelerometerUpdates()
        }

    }
    
    fileprivate func addCameraLayer(_ orientation: UIDeviceOrientation) {
        let widthValue = UIScreen.main.bounds.width
        let heightValue = UIScreen.main.bounds.height
        
        let negativeValue: CGFloat = 44 + 96
        
        var Y: CGFloat = 0
        var X: CGFloat = 0
        
        if widthValue > heightValue {
            Y = widthValue - negativeValue
        } else {
            Y = heightValue - negativeValue
        }
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        switch startOrientation {
        case .portrait:
            debugPrint("portrait")
        case .landscapeLeft:
            debugPrint("landscapeLeft")
            if widthValue > heightValue {
                width = heightValue
            } else {
                width = widthValue
            }
            X = 0
            Y = 0
        case .landscapeRight:
            debugPrint("landscapeRight")
            if widthValue > heightValue {
                width = heightValue
            } else {
                width = widthValue
            }
            X = width
        case .portraitUpsideDown:
            debugPrint("portraitUpsideDown")
        default:
            debugPrint("default portrait")
        }
        
        debugPrint("X", X, "Y", Y, "width", width, "height", height)

        cameraEngine.previewLayer.frame = CGRect(x: X, y: Y, width: width, height: height)
        cameraPreviewView.layer.addSublayer(cameraEngine.previewLayer)
    }
    
    
    fileprivate func animateCameraView() {
        let widthValue = UIScreen.main.bounds.width
        let heightValue = UIScreen.main.bounds.height
        
        var setupWidthValue: CGFloat!
        var setupHeightValue: CGFloat!
        
        if widthValue < heightValue {
            setupWidthValue = widthValue
            setupHeightValue = heightValue - 44 - 96
        } else {
            setupWidthValue = heightValue
            setupHeightValue = widthValue - 44 - 96
        }
        
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        self.cameraEngine.previewLayer.frame = CGRect(x: 0, y: 0, width: setupWidthValue, height: setupHeightValue)
        CATransaction.commit()
    }
    
    
    fileprivate func hideAnimation(_ currentOrientation: CurrentOrientation) {
        let widthValue = UIScreen.main.bounds.width
        let heightValue = UIScreen.main.bounds.height
        
        let negativeValue: CGFloat = 44 + 96 // bottom bar height + top bar height
        
        var setupWidthValue: CGFloat = 0
        var setupHeightValue: CGFloat = 0
        var X: CGFloat = 0
        var Y: CGFloat = 0
        
        if widthValue < heightValue {
            setupWidthValue = widthValue
            setupHeightValue = heightValue - 44 - 96
        } else {
            setupWidthValue = heightValue
            setupHeightValue = widthValue - 44 - 96
        }
        
        switch currentOrientation {
        case .portrait:
            debugPrint("currentOrientation is portrait")
            // width value < heightValue for this case
            setupWidthValue = cameraEngine.previewLayer.frame.width
            setupHeightValue = 0//heightValue - negativeValue
            Y = heightValue - negativeValue
            X = -widthValue
        case .portraitUpsideDown:
            debugPrint("currentOrientation is portraitUpsideDown")
        case .landscapeLeft:
            debugPrint("currentOrientation is landscapeLeft")
        case .landscapeRight:
            debugPrint("currentOrientation is landscapeRight")
        }
        
        debugPrint("X", X, "Y", Y, "width", setupWidthValue, "height", setupWidthValue)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(hideDurationTime)
        cameraEngine.previewLayer.frame = CGRect(x: X, y: Y, width: setupWidthValue, height: setupHeightValue)
        CATransaction.commit()
    }
    
}

// MARK: - Navigation

extension CameraControllerViewController {
    
    @objc fileprivate func dismissAction() {
        detectHideOrientation()
        Timer.scheduledTimer(withTimeInterval: hideDurationTime, repeats: false) { [weak self] (timer) in
            self?.dismiss(animated: false, completion: nil)
        }
    }
    
}
