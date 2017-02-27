//
//  ImagePickerController.swift
//  ImagePickerSheet
//
//  Created by Alexsander Khitev on 2/23/17.
//  Copyright © 2017 Alexsander Khitev. All rights reserved.
//

import Foundation
import Photos

let previewInset: CGFloat = 5

/// The media type an instance of ImagePickerSheetController can display
public enum ImagePickerMediaType {
    case image
    case video
    case imageAndVideo
}

open class ImagePickerController: UIViewController {
    
    fileprivate lazy var sheetController: SheetController = {
        let controller = SheetController(previewCollectionView: self.previewPhotoCollectionView)
        controller.actionHandlingCallback = { [weak self] (actionStyle) in
            if actionStyle == nil {
                self?.dismiss(animated: false, completion: nil)
            } else {
                switch actionStyle! {
                case .photoLibrary:
                    // show image picker 
                    self?.showPhotoLibraryController()
//                    self?.dismiss(animated: false, completion: nil)
                default:
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
        return controller
    }()
    
    var sheetCollectionView: UICollectionView {
        return sheetController.sheetCollectionView
    }
    
    
    fileprivate var previewPhotoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    
    fileprivate var supplementaryViews = [Int: PreviewSupplementaryView]()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "ImagePickerSheetBackground"
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.3961)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.sheetController, action: #selector(SheetController.handleCancelAction)))
        
        return view
    }()
    
    open var delegate: ImagePickerControllerDelegate?
    
    /// All the actions. The first action is shown at the top.
    open var actions: [ImagePickerAction] {
        return sheetController.actions
    }
    
    /// Maximum selection of images.
    open var maximumSelection: Int?
    
    fileprivate var selectedAssetIndices = [Int]() {
        didSet {
            sheetController.numberOfSelectedAssets = selectedAssetIndices.count
        }
    }
    
    /// The media type of the displayed assets
    open let mediaType: ImagePickerMediaType
    
    // MARK: - CollectionView identifier
    
    fileprivate let imagePickerCollectionCellIdentifier = "ImagePickerCollectionCell"
    fileprivate let imagePickerLiveCameraCollectionCellIdentifier = "ImagePickerLiveCameraCollectionCell"
    
    // MARK: - Data
    
    fileprivate var fetchResult: PHFetchResult<PHAsset>!
    
    // MARK: - Managers
    
    fileprivate let imageManager = PHCachingImageManager()
    
    // MARK: - Camera 
    
    fileprivate var cameraEngine = CameraEngine()
    
    // MARK: - Controllers
    
    fileprivate lazy var photoLibraryController: UIImagePickerController = {
        let photoLibraryController = UIImagePickerController()
        photoLibraryController.sourceType = .photoLibrary
        photoLibraryController.delegate = self
        return photoLibraryController
    }()
    
    // MARK: - Enums 
    
    fileprivate enum Source: String {
        case camera, photoLibrary, cell
    }
    
    fileprivate var currentImageSource = Source.camera
    
    /// Whether the image preview has been elarged. This is the case when at least once
    /// image has been selected.
    open fileprivate(set) var enlargedPreviews = false
    
    fileprivate let minimumPreviewHeight: CGFloat = 110 // 129
    fileprivate var maximumPreviewHeight: CGFloat = 110 // 129
    
    fileprivate var previewCheckmarkInset: CGFloat {
        return 12.5
    }
    
    // MARK: - Initialization
    
    public init(mediaType: ImagePickerMediaType) {
        self.mediaType = mediaType
        super.init(nibName: nil, bundle: nil)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.mediaType = .imageAndVideo
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
        
        NotificationCenter.default.addObserver(sheetController, selector: #selector(SheetController.handleCancelAction), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    deinit {
        debugPrint("ImagePickerSheetController is deinit")
        NotificationCenter.default.removeObserver(sheetController, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    // MARK: - View Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Camera
        cameraEngine.rotationCamera = true
        cameraEngine.currentDevice = .front
        cameraEngine.sessionPresset = .photo
        cameraEngine.startSession()
        // UI
        addUIElements()
        // Collection view
        setupCollectionViewSettings()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preferredContentSize = CGSize(width: 400, height: view.frame.height)
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            prepareAssets()
        } else {
            // for camera
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPhotoLibraryAccess()
    }
    
  
    // MARK: - Actions
    
    /// Adds an new action.
    /// If the passed action is of type Cancel, any pre-existing Cancel actions will be removed.
    /// Always arranges the actions so that the Cancel action appears at the bottom.
    open func addAction(_ action: ImagePickerAction) {
        sheetController.addAction(action)
        view.setNeedsLayout()
    }
    
    // MARK: - UI
    
    private func addUIElements() {
        view.addSubview(backgroundView)
        view.addSubview(sheetCollectionView)
    }
    
    private func checkPhotoLibraryAccess() {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        self.prepareAssets()
                        self.previewPhotoCollectionView.reloadData()
                        self.sheetCollectionView.reloadData()
                        self.view.setNeedsLayout()
                        
                        // Explicitely disable animations so it wouldn't animate either
                        // if it was in a popover
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        self.view.layoutIfNeeded()
                        CATransaction.commit()
                    }
                }
            }
        }
    }
    
    // MARK: - Images
    
    fileprivate func prepareAssets() {
        requestPhoto()
        reloadCurrentPreviewHeight(invalidateLayout: false)
    }
    
    private func requestPhoto() {
        // If we get here without a segue, it's because we're visible at app launch,
        // so match the behavior of segue from the default "All Photos" view.
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        }
    }
    
    // MARK: - Layout
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if popoverPresentationController == nil {
            // Offset necessary for expanded status bar
            // Bug in UIKit which doesn't reset the view's frame correctly
            
            let offset = UIApplication.shared.statusBarFrame.height
            var backgroundViewFrame = UIScreen.main.bounds
            backgroundViewFrame.origin.y = -offset
            backgroundViewFrame.size.height += offset
            backgroundView.frame = backgroundViewFrame
        }
        else {
            backgroundView.frame = view.bounds
        }
        
        reloadCurrentPreviewHeight(invalidateLayout: true)
        
        let sheetHeight = sheetController.preferredSheetHeight
        let sheetSize = CGSize(width: view.bounds.width, height: sheetHeight)
        
        // This particular order is necessary so that the sheet is layed out
        // correctly with and without an enclosing popover
        preferredContentSize = sheetSize
        sheetCollectionView.frame = CGRect(origin: CGPoint(x: view.bounds.minX, y: view.bounds.maxY - view.frame.origin.y - sheetHeight), size: sheetSize)
    }
    
    fileprivate func reloadCurrentPreviewHeight(invalidateLayout invalidate: Bool) {
        sheetController.setPreviewHeight(minimumPreviewHeight, invalidateLayout: invalidate)
    }
    
}

// MARK: - UICollection view 

extension ImagePickerController {
    
    fileprivate func setupCollectionViewSettings() {
        previewPhotoCollectionView.dataSource = self
        previewPhotoCollectionView.delegate = self
        registerCollectionViewElements()
    }
    
    private func registerCollectionViewElements() {
        // cells
        let photoNib = UINib(nibName: "ImagePickerCollectionCell", bundle: Bundle(identifier: "com.alexsander-khitev.ImageControllerPicker"))
        previewPhotoCollectionView.register(photoNib, forCellWithReuseIdentifier: imagePickerCollectionCellIdentifier)
        let liveNib = UINib(nibName: "ImagePickerLiveCameraCollectionCell", bundle: Bundle(identifier: "com.alexsander-khitev.ImageControllerPicker"))
        previewPhotoCollectionView.register(liveNib, forCellWithReuseIdentifier: imagePickerLiveCameraCollectionCellIdentifier)
    }
    
    
}

// MARK: - UICollectionViewDataSource

extension ImagePickerController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard fetchResult != nil else { return 1 }
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard fetchResult != nil else { return 1 } // this is a camera }
        return fetchResult.count + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = imagePickerLiveCameraCollectionCell(collectionView, indexPath: indexPath)
            
            return cell
        } else {
            let cell = imagePickerCollectionCell(collectionView, indexPath: indexPath)
    
            
            return cell
        }
    }
    
}

// MARK: - UICollectionViewDelegate

extension ImagePickerController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // this is a camera
            presentCameraController()
        } else {
            presentCropControllerFromCell(indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
      
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ImagePickerController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 95, height: 95)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
}

// MARK: - UICollectionView cells 

extension ImagePickerController {
    
    fileprivate func imagePickerCollectionCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> ImagePickerCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imagePickerCollectionCellIdentifier, for: indexPath) as! ImagePickerCollectionCell
        
        guard fetchResult != nil else { return cell }
        let asset = fetchResult.object(at: indexPath.row - 1) //- 1) - 1 because camera view
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 95, height: 95), contentMode: .aspectFill, options: options) { (image, info) in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.photoImageView?.image = image
            }
        }
        
        return cell
    }
    
    fileprivate func imagePickerLiveCameraCollectionCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> ImagePickerLiveCameraCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imagePickerLiveCameraCollectionCellIdentifier, for: indexPath) as! ImagePickerLiveCameraCollectionCell
        
        cameraEngine.previewLayer.frame = CGRect(x: 0, y: 0, width: 95, height: 95)
        
        // camera orientation
        
        cameraEngine.previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.orientationFromUIDeviceOrientation(UIDevice.current.orientation)

        
        cell.containerView.layer.addSublayer(cameraEngine.previewLayer)
        return cell
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate

extension ImagePickerController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(imagePickerSheetController: self, presenting: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(imagePickerSheetController: self, presenting: false)
    }
    
}

// MARK: - Camera

extension ImagePickerController {
    
    fileprivate func presentCameraController() {
        let cameraController = CameraControllerViewController()
        cameraController.delegate = self
        cameraController.cameraEngine = cameraEngine
        cameraController.startOrientation = UIDevice.current.orientation
        cameraEngine.previewLayer.connection.videoOrientation = .portrait// AVCaptureVideoOrientation.orientationFromUIDeviceOrientation(UIDevice.current.orientation)
        cameraEngine.rotationCamera = false
                
        present(cameraController, animated: false, completion: {

                })
    }

    
    fileprivate func returnCameraLayerToCell() {
        guard let cameraLiveCell = previewPhotoCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ImagePickerLiveCameraCollectionCell else { return }
        cameraEngine.rotationCamera = true
        cameraEngine.previewLayer.frame = CGRect(x: 0, y: 0, width: 95, height: 95)
        
        // return to standard cell behavior
        cameraEngine.changeCurrentDevice(.front)
        cameraEngine.previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.orientationFromUIDeviceOrientation(UIDevice.current.orientation)
        
        cameraLiveCell.containerView.layer.insertSublayer(cameraEngine.previewLayer, at: 1)
    }
    
}

// MARK: - Delegate

extension ImagePickerController: CameraControllerViewControllerDelegate {
    
    func willHide() {
        returnCameraLayerToCell()
    }
    
}

// MARK: - Image picker

extension ImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate func showPhotoLibraryController() {
        present(photoLibraryController, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker delegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }

        let cropViewController = TOCropViewController(croppingStyle: .circular, image: selectedImage)
        cropViewController.delegate = self
        
        currentImageSource = .photoLibrary
        
        picker.pushViewController(cropViewController, animated: true)
    }
 
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - TOCropViewController Delegate 

extension ImagePickerController: TOCropViewControllerDelegate {
    
    public func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    public func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        
        if delegate != nil {
            delegate?.imagePickerController!(image, with: cropRect, angle: angle)
        }
        
        
        
        switch currentImageSource {
        case .photoLibrary:
            photoLibraryController.popViewController(animated: false)
            dismiss(animated: false, completion: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
        case .cell:
            cropViewController.dismiss(animated: true, completion: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            break
        case .camera:
            break
        }
    }
    
}

extension ImagePickerController {
    
    fileprivate func presentCropControllerFromCell(_ indexPath: IndexPath) {
        let asset = fetchResult[indexPath.row - 1]
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: options) { [weak self] (image, data) in
            guard image != nil else { return }
            guard self != nil else  { return }
            
            let cropViewController = TOCropViewController(croppingStyle: .circular, image: image!)
            cropViewController.delegate = self
            
            self?.currentImageSource = .cell
            
            DispatchQueue.main.async {
                self?.present(cropViewController, animated: false, completion: nil)
            }
        }
    }
    
}
