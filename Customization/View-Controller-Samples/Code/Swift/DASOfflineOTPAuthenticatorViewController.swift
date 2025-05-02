//
//  DASOfflineOTPAuthenticatorViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import DaonAuthenticatorSDK

/*!
 @brief View Controller for scanning a QR code.
 */
@objc(DASOfflineOTPAuthenticatorViewController)
class DASOfflineOTPAuthenticatorViewController: DASAuthenticatorViewControllerBase, DASMetadataControllerDelegate {
    // MARK:- Controllers
    
    /*!
     @brief A @link DASMetadataControllerProtocol @/link object used for scanning QR codes.
     */
    fileprivate var metadataController: DASMetadataControllerProtocol?

    
    // MARK:- IBOutlets
    
    /*!
     @brief A UIImageView which fills the background.
     */
    @IBOutlet var backgroundImageView: UIImageView!
    
    /*!
     @brief A UILabel with instructions for the user.
     */
    @IBOutlet var instructionsLabel: UILabel!
    
    /*!
     @brief A UIActivityIndicatorView displayed while the view controller is starting the camera.
     */
    @IBOutlet var preparingView: UIActivityIndicatorView!
    
    /*!
     @brief A UIView over which the video preview will be added as a new layer (@link livePreviewLayer @/link).
     */
    @IBOutlet var videoContainerView: UIView!
    
    /*!
     @brief A UIImageView which will display the scanned QR code.
     */
    @IBOutlet var qrCodePreviewImageView: UIImageView!
    
    
    // MARK:- Initialization
    
    /*!
     @brief Instantiates a new @link DASOfflineOTPAuthenticatorViewController @/link object.
     @param nibNameOrNil Passed through to designated initializer
     @param nibBundleOrNil Passed through to designated initializer
     @param authenticatorContext The @link DASAuthenticatorContext @/link object with which a custom view controller can register or authenticate.
     @return A new @link DASOfflineOTPAuthenticatorViewController @/link object.
     */
    override init!(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, context authenticatorContext: DASAuthenticatorContext?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: authenticatorContext)
        
        // Set the tabBarItem in case this view controller is being displayed in a UITabBarController
        self.tabBarItem.title = localise("Offline OTP Screen - Title")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- View Lifecycle
    
    /*!
     @brief Called after view has been loaded. Sets up the initial UI state.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the UI
        self.backgroundImageView.image = loadImageNamed("Offline-OTP-Collection-Background")
        
        self.title = localise("Offline OTP Screen - Title") + " (Swift)"
        
        self.instructionsLabel.text = localise("Offline OTP Screen - Instructions")
        
        configureForPreparingMode()
        
        // Instantiate the metadata controller
        metadataController = self.singleAuthenticatorContext!.createMetadataController(with: self,
                                                                   previewView: self.videoContainerView,
                                                                   metadataTypes: [.qr])
    }

    /*!
     @brief Called when the view has appeared. We use this to check for camera permissions and then begin QR code scanning.
     @param animated YES if view appearance will be animated.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        metadataController!.start()
    }
    
    /*!
     @brief Called when the view has disappeared. We use this to stop QR code scanning.
     @param animated YES if view disappearance will be animated.
     */
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    
        configureForPreparingMode()
        metadataController!.cancel()
    }

    
    // MARK:- From DASMetadataControllerDelegate
    
    func cancel() {
        // NA
    }
    
    /*!
     @brief From DASMetadataControllerDelegate: Used to notify a conforming object that metadata scanning has started.
     */
    func metadataControllerScanningStarted() {
        configureForScanningMode()
    }
    
    /*!
     @brief From DASMetadataControllerDelegate: Used to notify a conforming object that metadata scanning completed successfully.
     @param image An image of the metadata object that was scanned.
     @param contents The UT8 encoded contents of the metadata object that was scanned.
     */
    func metadataControllerCompleted(with image: UIImage!, contents: Data!) {
        DispatchQueue.main.async {
            self.playCameraSoundAndVibrate()
            self.configureForPreviewModeWithImage(image)
         
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute:{
                self.singleAuthenticatorContext!.completeCapture(withTemporaryData: contents)
            })
        }
    }
    
    /*!
     @brief From DASMetadataControllerDelegate: Used to notify a conforming object that metadata scanning failed with an error.
     @param error The error that caused scanning to fail.
     */
    func metadataControllerCompletedWithError(_ error: Error!) {
        configureForErrorMode(error.localizedDescription)
    }
    
    
    // MARK:- UI
    
    /*!
     @brief Configures the UI to show a preparing indicator while QR code scanning is started.
     */
    fileprivate func configureForPreparingMode() {
        self.preparingView.isHidden           = false
        self.qrCodePreviewImageView.isHidden  = true
    }
    
    /*!
     @brief Configures the UI to show the scanning mode.
     */
    fileprivate func configureForScanningMode() {
        self.preparingView.isHidden           = true
        self.qrCodePreviewImageView.isHidden  = true
    }
    
    /*!
     @brief Configures the UI to show the scanned mode, with a preview of the scanned QR code.
     */
    fileprivate func configureForPreviewModeWithImage(_ previewImage: UIImage) {
        self.preparingView.isHidden             = true
        self.qrCodePreviewImageView.image       = previewImage
        self.qrCodePreviewImageView.isHidden    = false
    }
    
    /*!
     @brief Configures the UI to show an error.
     */
    fileprivate func configureForErrorMode(_ errorMessage: String) {
        self.instructionsLabel.text             = errorMessage
        self.instructionsLabel.isHidden         = false
        self.preparingView.isHidden             = true
        self.videoContainerView.isHidden        = true
        self.qrCodePreviewImageView.isHidden    = true
    }
}
