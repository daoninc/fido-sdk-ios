//
//  FaceAuthenticatorViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2021-23 Daon. All rights reserved.
//

import DaonAuthenticatorFace
import DaonAuthenticatorSDK
import DaonCryptoSDK
import DaonFaceSDK

enum DASFaceCaptureState : Int
{
    case preparing                      = 0
    case collectingForRegistration      = 1
    case collectingForAuthentication    = 2
    case confirmingPhoto                = 3
    case verifyingPhoto                 = 4
    case intializing                    = 5
    case tracking                       = 6
    case analyzing                      = 7
    case success                        = 8
    case failed                         = 9
    case retry                          = 10
    case noCameraPermission             = 11
    case spoof                          = 12
}

/*!
 @brief View Controller for collecting a face image.
 */
@objc(DASFaceAuthenticatorViewController)
class DASFaceAuthenticatorViewController: DASAuthenticatorViewControllerBase, DASFaceControllerDelegate {
    
    // How long to show a success/failure message before moving on to the next step.
    private let KTransitionTimeAfterResult = 2.0
        
    // A DASFaceControllerProtocol object used for registering and authenticating face templates.
    var faceController: DASFaceControllerProtocol?
    
    // The current @link DASFaceCaptureState @/link state of the view controller.
    var state : DASFaceCaptureState = .preparing
        
    // The registration or authentication image that was captured and is being processed.
    var capturedImage: UIImage?
    
    var overlay: DASFaceOverlayView?
    
    
    // MARK:- IBOutlets
    
    // A UIImageView which fills the background.
    @IBOutlet var backgroundImageView: UIImageView!
    
    // A UILabel with instructions for the user.
    @IBOutlet var instructionsLabel: UILabel!
    
    // A UILabel with current state or status
    @IBOutlet var statusLabel: UILabel!
    
    // A UIView which contains all the video* IBOutlets.
    // Provide an easy means of hiding all controls in case of issues such as no camera permission.
    @IBOutlet var videoContainerView: UIView!
    
    // A UIActivityIndicatorView displayed while the @link faceController @/link is starting the camera.
    @IBOutlet var videoPreparingActivityIndicator: UIActivityIndicatorView!
    
    // A UIActivityIndicatorView displayed while the @link faceController @/link is assessing an images quality or registering one.
    @IBOutlet var videoProcessingActivityIndicator: UIActivityIndicatorView!
    
    // A UIView upon which the @link faceController @/link will display a livefeed from the camera.
    @IBOutlet var videoLivefeedView: UIView!
    
    // A UIImageView in which the captured face image will be displayed to the user.
    @IBOutlet var videoPhotoPreviewView: UIImageView!
    
    // A UIView which will contain the current video overlay
    @IBOutlet var videoOverlayContainer: UIView!
    
    // A UIView which is an overlay for the @link videoResultImageView @/link. This is a dark overlay to make the result stand out.
    @IBOutlet var videoResultOverlay: UIView!
    
    // A UIView which contains all the UIButton IBOutlets for registration.
    @IBOutlet var actionsContainerView: UIView!
    
    // A UIButton the user can press to take a photo for registration.
    @IBOutlet var takePhotoButton: UIButton!
    
    // A UIButton the user can press to conform they wish to use the displayed photo for registration.
    @IBOutlet var usePhotoButton: UIButton!
    
    // A UIButton the user can press to take another photo for registration.
    @IBOutlet var retakePhotoButton: UIButton!
    
    
    
    
    // MARK:- Initialization
    
    
    override init(nibName nibNameOrNil: String?,
                  bundle nibBundleOrNil: Bundle?,
                  context authenticatorContext: DASAuthenticatorContext?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: authenticatorContext)
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
        
        // Configure the face controller
        configureFaceController()
        
        overlay = DASFaceOverlayView(frame: videoOverlayContainer.frame)
        videoOverlayContainer.addSubview(overlay!)
        
        DASUtils.addConstrainEqualConstraint(to: view, containerView: videoOverlayContainer, childView: overlay)
        
        update(state: .preparing)
        
        if let context = singleAuthenticatorContext {
            if context.isRegistration {
                update(state: .collectingForRegistration)
            } else {
                update(state: .collectingForAuthentication)
            }
        }
                
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [self] granted in
            DispatchQueue.main.async {
                if granted {
                    self.faceController?.start()
                } else {
                    self.fail(error: DASUtils.error(forError: .noCameraPermission))
                }
            }
        }
    }
    
    /*!
     @brief Called when the view will transition to another orientation. We pass this information on to
        the face controller so that it can adjust itself.
     @param size The views new size.
     @param coordinator The transition coordinator.
     */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate() { (context) in
            self.faceController?.handleOrientationChange()
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK:- Actions
    
    /*!
     @brief IBAction called when @link takePhotoButton @/link is pressed.
     @param sender The control that sent this event.
     */
    @IBAction func takePhoto(_ sender: UIButton?) {
        
        playCameraSoundAndVibrate()
        
        capturedImage = faceController?.captureImage()
        
        if capturedImage != nil {
            update(state: .confirmingPhoto)
        } else {
            update(state: .failed)
        }
    }
    
    /*!
     @brief IBAction called when @link usePhotoButton @/link is pressed.
     @param sender The control that sent this event.
     */
    @IBAction func usePhoto(_ sender: UIButton?) {
        
        update(state: .verifyingPhoto)
        
        if let image = capturedImage, let context = singleAuthenticatorContext {
            if context.isRegistration {
                faceController?.register(image: image)
            } else {
                faceController?.authenticate(image: image)
            }
        } else {
            update(state: .failed)
        }
    }
    
    /*!
     @brief IBAction called when @link retakePhotoButton @/link is pressed.
     @param sender The control that sent this event.
     */
    @IBAction func retakePhoto(_ sender: UIButton?) {
        
        capturedImage = nil
                    
        // Tell the face controller to restart, which will clear the current
        // photo and resume frame analysis.
        faceController?.resume()
                
        update(state: .collectingForRegistration)
    }
        
    func configureFaceController() {
                
        // If no liveness or server liveness a higher resolution will be used.
        
        faceController = DASFaceAuthenticatorFactory.createFaceController(context:singleAuthenticatorContext,
                                                                          preview:videoLivefeedView,
                                                                          delegate:self)
        
        
        let expected = faceController?.expectedLivenessEvents()
        
        print("Expected liveness events: ", expected ?? "NA")
        
    }
    
    // MARK:- From DASAuthenticatorViewControllerBase - Actions
    
    /*!
     @brief Called when the authenticator UI should be reset due to the view controller being removed from its parent. Typically this
     happens when transitioning between authenticators in a multi-authenticator policy. Resetting ensures that when transitioning
     back to the authenticator that it is back in its default prepared state.
     */
    override func authenticatorShouldReset() {
        super.authenticatorShouldReset()
        
        // If the controller is nil, we may be at the start of collection so don't do anything.
        if faceController != nil {
            isCancelling = true
            
            faceController!.cancel()
            update(state: .preparing)
        }
    }
    
    /*!
     @brief Cancels the UI by stopping frame analysis and telling the context which will dismiss the UI.
     */
    override func authenticatorIsCancelling() {
        faceController?.cancel()
        super.authenticatorIsCancelling()
    }


    
    // MARK:- DASFaceControllerDelegate
    
    func controllerDidCompleteSuccessfully() {
        hideCancelButton()
        update(state: .success)
        
        singleAuthenticatorContext?.completeCapture()
    }
    
    func controllerDidFail(error: Error, score: NSNumber?) {
     
        guard let context = singleAuthenticatorContext else {
            fail(error: error)
            return
        }
                
        if context.isRegistration {
            fail(error: error)
        } else {                        
            if shouldUpdateAttempt(error: error) {
                failAndUpdateAttempts(error: error, score: score)
            } else {
                fail(error: error)
            }
        }
    }

    // Notify that a frame from the live video has completed processing.
    func controllerDidAnalyze(result: DFSResult, quality: Bool, issues: [NSNumber]?) {
        
        if !isCancelling && (state == .collectingForAuthentication || state == .collectingForRegistration) {
            overlay?.update(quality: quality, issues: issues)
            
            // We are using a take photo button at registration or authentication with server side liveness.
            //
            // No liveness
            //      Enable the take photo button when we have a quality image
            //
            // Liveness
            //      We will enable the take photo button when liveness is complete.
            
            if showTakePhotoButton() && !isLivenessRequired() {
                takePhotoButton.isHidden = !quality
            }
        }
    }
            
    // Notify a conforming object that a liveness event (passive, blink, etc) has been detected.
    
    func controllerDidDetectLiveness(event: DASFaceLivenessEvent, result: DFSResult, image: UIImage?, allEventsDetected: Bool) {
        
        if !isCancelling {
            if allEventsDetected {
                
                if showTakePhotoButton() {
                    
                    // Enable the take photo option at registration or when no liveness on the client.
                    // Automatic authentication of the best image in all cases can be enabled by removing
                    // authentication or change the showTakePhotoButton() method.
                    
                    if let context = singleAuthenticatorContext {
                        if context.isRegistration {
                            update(state: .collectingForRegistration)
                        } else {
                            update(state: .collectingForAuthentication)
                        }
                    }
                    
                    takePhotoButton.isHidden = false
                } else {
                    update(state: .verifyingPhoto)
                    faceController?.authenticate(image: image)
                }
                                
            } else {
                // More liveness events are required
                
                switch event {
                    
                case .blink:
                    update(state: .collectingForAuthentication)
                    statusLabel.text = "Blink detected"
                    
                case .spoof:
                    update(state: .spoof)
                    
                case .passive:
                    update(state: .collectingForAuthentication)
                    statusLabel.text = "Liveness detected"
                                                        
                case .initializing:
                    statusLabel.text = "Initializing"
                    
                case .started:
                    statusLabel.text = "Determining liveness"
                    
                case .tracking:
                    vibrate()
                    statusLabel.text = "Look alive!"
                    
                case .analyzing:
                    statusLabel.text = "Analyzing"
                    
                case .completed:
                    statusLabel.text = "Done"
                    
                case .reset:
                    statusLabel.text = "Looking for a face"
                default:
                    break
                }
            }
        }
    }
    
    func controllerShouldUse(configuration: [AnyHashable : Any]) -> [AnyHashable : Any]? {
        
        return [kDFSConfigSensorPitchMinimumKey:65];
    }
    
    // Provide a custom image quality criteria.
    func controllerShouldUseQualityCriteria(result: DFSResult) -> [NSNumber]? {
        
        guard let context = singleAuthenticatorContext else {
            return nil
        }
        
        var issues: [NSNumber] = []
                
        if result.quality.hasMask {
            issues.append(NSNumber(value: DASAuthenticatorError.faceQualityCheckMaskDetected.rawValue))
            overlay?.update(warning: "Please make sure you are not wearing a face mask", color: UIColor.red)
        }
        
        if context.isRegistration { 
            
            if !result.isDeviceUpright {
                issues.append(NSNumber(value: DASAuthenticatorError.faceQualityCheckFailedDeviceNotUpright.rawValue))
            }
        }
        
        if !result.quality.isFaceCentered {
            issues.append(NSNumber(value: DASAuthenticatorError.faceLivenessAlertFaceNotCentered.rawValue))
        }
        
        // Look at the global score first. If it is above the threshold we are fine, otherwise
        // check individual metrics.

        if !result.quality.hasAcceptableQuality {
            // Check what's wrong

            let goodLighting = result.quality.hasAcceptableExposure
                            && result.quality.hasUniformLighting
                            && result.quality.hasAcceptableGrayscaleDensity
                            && result.quality.hasFace;
            
            if !goodLighting {
                issues.append(NSNumber(value: DASAuthenticatorError.faceQualityCheckFailedPoorLighting.rawValue))
            }
            
            issues.append(NSNumber(value: DASAuthenticatorError.faceQualityCheckFailedReasonUnknown.rawValue))
            
        } else if !result.quality.hasAcceptableEyeDistance {
            issues.append(NSNumber(value: DASAuthenticatorError.faceQualityCheckFailedFaceTooFarAway.rawValue))
        }
        
        return issues
    }
    
    // So that we can override in FaceViewController
    func completeCapture(error: DASAuthenticatorError) {
        singleAuthenticatorContext?.completeCapture(error: error)
    }
    
    func fail(error: Error?) {
        if !isCancelling {
            
            if let e = error, let authenticatorError = DASAuthenticatorError(rawValue: e._code) {
                
                if authenticatorError == .noCameraPermission {
                    // We don't have permission to use the camera, we cannot continue,
                    // so display this to the user.
                    update(state: .noCameraPermission)
                    
                } else if (authenticatorError == .serverUserLockout
                            || authenticatorError == .serverTooManyAttempts
                            || authenticatorError == .serverFaceTooManyAttempts
                            || authenticatorError == .authenticatorTooManyAttemptsTempLocked
                            || authenticatorError == .authenticatorTooManyAttemptsPermLocked) {
                    
                    // A face error occurred, which we believe should cause capture to terminate.
                    
                    completeCapture(error: authenticatorError)
                    
                } else if (authenticatorError == .faceLivenessCheckFailed
                            || authenticatorError == .faceLostFaceContinuity
                            || authenticatorError == .faceLivenessCheckEyesClosed
                            || authenticatorError == .faceLivenessAtRegistrationTimeout
                            || authenticatorError == .faceRecognitionTimeout
                            || authenticatorError == .faceRecognitionTimeoutNoFaceDetected) {
                    
                    update(state: .retry)
                    
                    showAlert(withTitle: localise("Alert - Title - Error"), message: string(forError: authenticatorError)) {
                        
                        self.faceController?.resume()
                        
                        if let context = self.singleAuthenticatorContext {
                            if context.isRegistration {
                                self.update(state: .collectingForRegistration)
                            } else {
                                self.update(state: .collectingForAuthentication)
                            }
                        }
                    }
                } else if (authenticatorError == .faceMultipleFailedAttempts) {
                    showAlert(withTitle: localise("Alert - Title - Error"), message: string(forError: authenticatorError)) {
                              self.update(state: .failed)
                    }
                } else {
                    update(state: .failed, message: e.localizedDescription)
                }
            } else {
                singleAuthenticatorContext?.completeCapture(error: .authenticatorInconsistentState)
            }
        }
    }
    
    func failAndUpdateAttempts(error: Error, score: NSNumber?) {
        
        guard let context = singleAuthenticatorContext else {
            return
        }
        
        context.incrementFailures(error: error._code, score: score) { (lockError) in
            
            if let e = lockError  {
                // We are locked
                self.fail(error: e)
            } else {
                // We are not locked, so check for too many attempts
                if context.haveEnoughFailedAttemptsForWarning() {
                    self.fail(error: DASUtils.error(forError: DASAuthenticatorError.faceMultipleFailedAttempts))
                } else {
                    self.fail(error: error)
                }
            }
        }
    }
    
    func shouldUpdateAttempt(error: Error) -> Bool {
        
        guard let context = singleAuthenticatorContext else {
            return false
        }
        
        let e = DASAuthenticatorError(rawValue: error._code)
        
        // The server will handle locking, so if we got a local error (timed out, liveness failed, spoof, etc),
        // report that to the server as it has no way of knowing that happened.
        
        if context.isADoSRequired {
            return e == DASAuthenticatorError.faceRecognitionTimeout
                || e == DASAuthenticatorError.faceLivenessCheckFailed
                || e == DASAuthenticatorError.faceLivenessCheckSpoof
                || e == DASAuthenticatorError.faceLivenessCheckEyesClosed
        } else {
            return e != DASAuthenticatorError.faceRecognitionTimeoutNoFaceDetected
        }
    }
        
    func isLivenessRequired() -> Bool {
        if let expected = faceController?.expectedLivenessEvents() {
            if expected.count > 0 {
                return true
            }
        }
        
        return false;
    }
    
    func isExpected(event: DASFaceLivenessEvent) -> Bool {
        
        if let expected = faceController?.expectedLivenessEvents() {
            return expected.contains(NSNumber(value:event.rawValue)) && !isDetected(event: event)
        }
        
        return false;
    }
    
    func isDetected(event: DASFaceLivenessEvent) -> Bool {
        
        if let detected = faceController?.detectedLivenessEvents() {
            return detected.contains(NSNumber(value:event.rawValue))
        }
        
        return false;
    }
    
    // Enable the take photo option at registration or when no liveness on the client.
    // Automatic authentication of the best image in all cases can be enabled by removing
    // the no liveness requirement.
    func showTakePhotoButton() -> Bool {
        
        guard let context = singleAuthenticatorContext else {
            return false
        }
        
        return context.isRegistration || !isLivenessRequired()
    }
    
    /*!
     @brief Updates the UI for a new @link DASFaceCaptureState @/link.
     @param newState The new @link DASFaceCaptureState @/link.
     */
    func update(state: DASFaceCaptureState, message: String? = nil) {
        
        guard let context = singleAuthenticatorContext else {
            return
        }
        
        self.state = state
        
        takePhotoButton.setTitle(localise("Face Screen - Button - Take Photo"), for: .normal)
        usePhotoButton.setTitle(localise("Face Screen - Button - Use Photo"), for: .normal)
        retakePhotoButton.setTitle(localise("Face Screen - Button - Reake Photo"), for: .normal)
        
        backgroundImageView.image = loadImageNamed("Face-Collection-Background")
        
        overlay?.reset()
        
        switch state {
        case .preparing:
            hideCancelButton()
            
            instructionsLabel.alpha    = 1
            instructionsLabel.text     = localise("Face Screen - Instructions - Preparing")
            
            // Video Container
            videoPreparingActivityIndicator.isHidden     = false
            videoProcessingActivityIndicator.isHidden    = true
            videoOverlayContainer.isHidden               = true
            videoPhotoPreviewView.isHidden               = true
            videoResultOverlay.isHidden                  = true
            
            // Actions Container
            if (showTakePhotoButton()) {
                takePhotoButton.isHidden      = true
                usePhotoButton.isHidden       = true
                retakePhotoButton.isHidden    = true
            } else {
                actionsContainerView.removeFromSuperview()
            }
            
        case .collectingForRegistration, .collectingForAuthentication, .tracking:
            
            showCancelButton()
            
            if showTakePhotoButton() {
                takePhotoButton.isHidden       = true
                retakePhotoButton.isHidden     = true
                usePhotoButton.isHidden        = true
                actionsContainerView.isHidden  = false
            }
            
            instructionsLabel.alpha = 1
            
            // Video Container
            videoPreparingActivityIndicator.isHidden   = true
            videoProcessingActivityIndicator.isHidden  = true
            videoOverlayContainer.isHidden             = false
            videoPhotoPreviewView.isHidden             = true
            videoResultOverlay.isHidden                = true
            
            statusLabel.text = ""
            
            if isExpected(event: DASFaceLivenessEvent.passive) && isExpected(event: DASFaceLivenessEvent.blink) {
                instructionsLabel.text = localise("Face Screen - Instructions - Authentication - Passive And Blink")
            } else if isExpected(event: DASFaceLivenessEvent.blink) {
                instructionsLabel.text = localise("Face Screen - Instructions - Authentication - Blink")
            } else if isExpected(event: DASFaceLivenessEvent.passive) {
                instructionsLabel.text = localise("Face Screen - Instructions - Authentication - Passive")
            } else {
                if state == .collectingForRegistration {
                    self.instructionsLabel.text = localise("Face Screen - Instructions - Registration")
                } else if (!isLivenessRequired()) {
                    self.instructionsLabel.text = localise("Face Screen - Instructions - Verifying")
                } else {
                    self.instructionsLabel.text = localise("Face Screen - Instructions - Authentication")
                }
            }
            
        case .confirmingPhoto:
            
            instructionsLabel.alpha    = 1
            instructionsLabel.text     = localise("Face Screen - Instructions - Confimation")
            
            if let imageToDisplay = capturedImage {
                // Video Container
                videoPhotoPreviewView.isHidden = false
                videoPhotoPreviewView.image    = rotateImage(imageToDisplay, to: previewImageOrientation())
            }
            
            // Actions Container
            takePhotoButton.isHidden      = true
            usePhotoButton.isHidden       = false
            retakePhotoButton.isHidden    = false
            
            faceController?.cancel()
            
            overlay?.oval(color: UIColor.clear)
            
        case .verifyingPhoto, .analyzing:
            
            statusLabel.text = ""
            
            hideCancelButton()
            
            instructionsLabel.alpha = 1
            
            if state == .verifyingPhoto {
                instructionsLabel.text = localise("Face Screen - Instructions - Verifying")
            } else {
                instructionsLabel.text = localise("Face Screen - Instructions - Analyzing")
            }
            
            videoProcessingActivityIndicator.isHidden = false
            actionsContainerView.isHidden = true
            
            videoPhotoPreviewView.isHidden = false
            videoPhotoPreviewView.backgroundColor = UIColor.white
            
            overlay?.oval(color: UIColor.clear)
            overlay?.update(message: "")
            
        case .success:
            
            statusLabel.text = "Success"
            
            instructionsLabel.alpha = 0
            
            videoPhotoPreviewView.isHidden = true
            videoPhotoPreviewView.backgroundColor = UIColor.white
            
            videoProcessingActivityIndicator.isHidden  = true
            videoLivefeedView.isHidden = true
            
            // Actions Container
            takePhotoButton.isHidden      = true
            usePhotoButton.isHidden       = true
            retakePhotoButton.isHidden    = true
            
            overlay?.update(withResult: true)
            
        case .spoof:

            instructionsLabel.alpha = 1
            instructionsLabel.text = localise("Face Screen - Instructions - Spoof")
            
            videoPhotoPreviewView.isHidden = false
            videoPhotoPreviewView.backgroundColor = UIColor.white
            
            videoResultOverlay.isHidden                = false
            videoProcessingActivityIndicator.isHidden  = true
            
            // Actions Container
            takePhotoButton.isHidden      = true
            usePhotoButton.isHidden       = true
            retakePhotoButton.isHidden    = true
            
            overlay?.update(withResult: false)
            
        case .failed:
            
            statusLabel.text = "Failed"
            
            instructionsLabel.alpha    = 0
            instructionsLabel.text     = ""
            
            // Video Container
            videoResultOverlay.isHidden                = false
            videoProcessingActivityIndicator.isHidden  = true
            
            // Actions Container
            takePhotoButton.isHidden      = true
            usePhotoButton.isHidden       = true
            retakePhotoButton.isHidden    = true
                                    
            overlay?.update(withResult: false)
            
            // Display the current error in a "toast" then after a delay reset the UI and resume face analysis.
            if message != nil {
                showToast(in: self.view, message: message!, isError: true)
            }
            
            if context.isRegistration {
                if message == nil {
                    showToast(in: self.view, message: localise("Face Screen - Enrollment Issue - Could Not Enroll"), isError: true)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + KTransitionTimeAfterResult) {
                    self.update(state: .collectingForRegistration)
                    self.faceController?.resume()
                }
            } else {
                if message == nil {
                    showToast(in: self.view, message: localise("Face Screen - Verification Issue - Could Not Verify"), isError: true)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + KTransitionTimeAfterResult) {
                    self.update(state: .collectingForAuthentication)
                    self.faceController?.resume()
                }
            }
            
        case .retry:
            
            if context.isRegistration {
                instructionsLabel.text = localise("Face Screen - Enrollment Issue - Could Not Enroll")
            } else {
                instructionsLabel.text = localise("Face Screen - Verification Issue - Could Not Verify")
            }
            
        case .noCameraPermission:
            
            showCancelButton()
            
            // Labels
            instructionsLabel.text = string(forError: .noCameraPermission)
            
            // Containers
            videoContainerView.isHidden    = true
            actionsContainerView.isHidden  = true
            
        default: break
        }
    }
    
    
    /*!
     @brief Determine the orientation to which we need to rotate the capture image prior to display on screen.
     @return The UIImageOrientation for rotation.
     */
    private func previewImageOrientation() -> UIImage.Orientation {
        
        var imageOrientation : UIImage.Orientation = .rightMirrored
        
        switch DASUtils.statusBarOrientation() {
        case .portrait:
            imageOrientation = .rightMirrored
            
        case .portraitUpsideDown:
            imageOrientation = .leftMirrored
            
        case .landscapeLeft:
            imageOrientation = .upMirrored
            
        case .landscapeRight:
            imageOrientation = .downMirrored
            
        default:
            imageOrientation = .rightMirrored
        }
        
        return imageOrientation
    }

    func vibrate() {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }
}
