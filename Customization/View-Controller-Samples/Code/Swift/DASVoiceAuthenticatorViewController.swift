//
//  DASVoiceAuthenticatorViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-24 Daon. All rights reserved.
//

import DaonAuthenticatorVoice
import DaonAuthenticatorSDK
import DaonCryptoSDK


/*!
 @brief View Controller for collecting one or more voice samples.
 */
@objc(DASVoiceAuthenticatorViewController)
class DASVoiceAuthenticatorViewController: DASAuthenticatorViewControllerBase, DASVoiceControllerDelegate {
    
    /*!
     @brief The duration of the fade in/out animation for the @link utteranceLabel @/link control.
     */
    let KUtteranceAnimationDuration = 1.0
    
    /*!
     @brief How long to show the success icon in the @link levelMeter @/link control before moving on to the next step.
     */
    let KSuccessAppearanceTimeInterval = 1.0
    
    
    // MARK:- Controllers
    
    /*!
     @brief A @link DASVoiceControllerProtocol @/link object used for registering and authenticating voice samples.
     */
    lazy var voiceController: DASVoiceControllerProtocol = DASVoiceAuthenticatorFactory.createVoiceController(context: singleAuthenticatorContext, delegate: self)
    
    
    /*!
     @brief A UIImageView which fills the background.
     */
    @IBOutlet var backgroundImageView: UIImageView!
    
    /*!
     @brief A UILabel with instructions for the user.
     */
    @IBOutlet var instructionsLabel: UILabel!
    
    /*!
     @brief A UILabel with the current voice sample and the total expected samples. E.g "1/3".
     */
    @IBOutlet var progressLabel: UILabel!
    
    /*!
     @brief A UILabel with the utterance that the user is expected to say.
     */
    @IBOutlet var utteranceLabel: UILabel!
    
    /*!
     @brief A custom @link DASCircularLevelMeter @/link view which shows the audio level in real time.
     */
    @IBOutlet var levelMeter: DASCircularLevelMeter!
    
    var voiceSampleIndex = 1
    let expectedVoiceSamples = 3
    var voiceSamples = [Data]()
    var registration = false;
        
    /*!
     @brief Instantiates a new @link DASVoiceAuthenticatorViewController @/link object.
     @param nibNameOrNil Passed through to designated initializer
     @param nibBundleOrNil Passed through to designated initializer
     @param authenticatorContext The @link DASAuthenticatorContext @/link object with which this view controller can register or authenticate voice samples.
     @return A new @link DASVoiceAuthenticatorViewController @/link object.
     */
    override init!(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, context authenticatorContext: DASAuthenticatorContext?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: authenticatorContext)
                        
        // Set the tabBarItem in case this view controller is being displayed in a UITabBarController
        tabBarItem.title = localise("Voice Screen - Title")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*!
     @brief Called after view has been loaded. Sets up the initial UI state.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableLevelMeter()
        
        backgroundImageView.image = loadImageNamed("Voice-Collection-Background")
        
        self.title = "\(singleAuthenticatorContext?.authenticatorInfo?.authenticatorName ?? "Voice") (Swift)"
        
        if let context = singleAuthenticatorContext {
            registration = context.isRegistration
            
            if registration {
                updateProgress()
                instructionsLabel.text = localise("Voice Screen - Instructions - Registration")
            } else {
                progressLabel.removeFromSuperview()
                //progressLabel = nil
                instructionsLabel.text = localise("Voice Screen - Instructions - Authentication")
            }
            
            utteranceLabel.text = voiceController.defaultUtterance()
        }
    }
    
    /*!
     @brief Called when the view is about to be made visible. We use this to reset the UI if capture was previously completed.
     @param animated YES if view appearance will be animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureCompleted {
            captureCompleted = false
            
            // Capture has already completed successfully once. So if viewWillAppear is happening again
            // then the user must have gone back through the navigation stack.
            //
            // Reset the UI, so that the user may capture again.
            //
            reset(error: nil, recaptureAllSamples: true)
        }
    }
    
    /*!
     @brief Called when the view has appeared. We use this to force the microphone permission dialog to appear if needed.
     @param animated YES if view appearance will be animated.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check for microphone permission, ignore the response. If they said NO, then an appropriate
        // error will be shown when they actually try to record.
        
        AVCaptureDevice.requestAccess(for: .audio) { (granted) in }
    }
    
    
    // MARK:- From DASAuthenticatorViewControllerBase - Actions
    
    /*!
     @brief Called when the authenticator UI should be reset due to the view controller being removed from its parent. Typically this
     happens when transitioning between authenticators in a multi-authenticator policy. Resetting ensures that when transitioning
     back to the authenticator that it is back in its default prepared state.
     */
    override func authenticatorShouldReset() {
        super.authenticatorShouldReset()
                
        isCancelling = true
        voiceController.cancel()
        reset(error: nil, recaptureAllSamples: true)
    }

    override func authenticatorIsCancelling() {
        super.authenticatorIsCancelling()
        voiceController.cancel()
    }
    
    // MARK:- Level Meter
    
    /*!
     @brief Configures the level meter and it's behavior when pressed.
     */
    func enableLevelMeter() {
        levelMeter.enableButtonMode(startText: localise("Voice Screen - Action - Start Recording"),
                                          stopText: localise("Voice Screen - Action - Stop Recording"),
                                    retryModeEnabled: false) {
            self.toggleRecording()
        }
        
        levelMeter.audioMeterDataSource = voiceController
    }
        
    func toggleRecording() {
        
        if voiceController.isRecording() {
            voiceController.stopRecording() { [self] error, data in
              
                if let sample = data {
                    if registration {
                        voiceSamples.append(sample)
                                                
                        if voiceSampleIndex < expectedVoiceSamples {
                            
                            voiceSampleIndex += 1
                            
                            showCancelButton()
                            showUtteranceLabel()
                            
                            levelMeter.showSuccess(reset: true)
                            updateProgress()
                        } else {
                            levelMeter.showProcessing()
                            hideUtteranceLabel()
                            voiceController.register(samples: self.voiceSamples)
                        }
                    } else {
                        levelMeter.showProcessing()
                        hideUtteranceLabel()
                        voiceController.authenticate(sample: sample)
                    }
                } else {
                    fail(error: error ?? DASUtils.error(forError: .voiceUnknownError))
                }
            }
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.audio) { [self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self.voiceController.startRecording()
                        // Stop the user from cancelling the screen while recording is in progress.
                        self.hideCancelButton()
                    } else {
                        self.fail(error: DASUtils.error(forError: .noMicrophonePermission))
                    }
                }
            }
        }
    }
    
    
    func controllerDidCompleteSuccessfully() {
        
        // No more voice samples are required, so we are done!, complete capture.
        self.levelMeter.showSuccess(reset: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + KSuccessAppearanceTimeInterval) {
            if !self.isCancelling {
                self.captureCompleted = true
                self.showCancelButton()
                self.singleAuthenticatorContext?.completeCapture()
            }
        }
    }
    
    func controllerDidFail(error: Error, score: NSNumber?) {
     
        if registration {
            fail(error: error)
        } else {
            if shouldUpdateAttempt(error: error) {
                failAndUpdateAttempts(error: error, score: score)
            } else {
                fail(error: error)
            }
        }
    }

    func fail(error: Error) {
        if !isCancelling {
            let authenticatorError = DASAuthenticatorError(rawValue: error._code)
            if authenticatorError == .serverUserLockout
                || authenticatorError == .serverTooManyAttempts
                || authenticatorError == .serverVoiceTooManyAttempts
                || authenticatorError == .authenticatorTooManyAttemptsTempLocked
                || authenticatorError == .authenticatorTooManyAttemptsPermLocked {
                
                singleAuthenticatorContext?.completeCapture(error: authenticatorError!)
            } else {
                reset(error: error, recaptureAllSamples:voiceSampleIndex >= expectedVoiceSamples)
            }
        }
    }

    func shouldUpdateAttempt(error: Error) -> Bool {
        
        guard let context = singleAuthenticatorContext else {
            return false
        }
        
        if context.isADoSRequired {
            return false
        }
        
        return true
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
                    self.fail(error: DASUtils.error(forError: DASAuthenticatorError.voiceMultipleFailedAttempts))
                } else {
                    self.fail(error: error)
                }
            }
        }
    }
    
    
    /*!
     @brief Resets the internal state and UI elements so that we may record another voice sample. Displays any error in a popup from the bottom of the screen.
     @param error The error that occurred.
     @param recaptureAllSamples YES if all samples must be recaptured, NO if only the last sample must be recaptured.
     */
    func reset(error: Error?, recaptureAllSamples: Bool) {
        
        if recaptureAllSamples {
            voiceController.cancel()
            voiceSampleIndex = 1
            updateProgress()
        }
                    
        showCancelButton()

        if levelMeter.isShowingProcessing() {
            UIView.animate(withDuration: KUtteranceAnimationDuration) {
                self.utteranceLabel.alpha = 1
            }
    
            levelMeter.showFailure(reset: true)
        } else {
            utteranceLabel.alpha = 1
            levelMeter.reset()
        }
        
        // Display error in toast
        if error != nil {
            showToast(in: self.view, message: error!.localizedDescription, isError: true)
        }
    }
    
    
    // MARK:- UI
    
    /*!
     @brief Updates the @link progressLabel @/link ("1/3") to show which voice sample we are collecting.
     */
    func updateProgress() {
        if let label = self.progressLabel {
            label.text = String(format: localise("Voice Screen - Progress - Formatted"),
                                voiceSampleIndex,
                                expectedVoiceSamples)
        }
    }
    
    private func showUtteranceLabel() {
        UIView.animate(withDuration: KUtteranceAnimationDuration) { self.utteranceLabel.alpha = 1 }
    }
    
    private func hideUtteranceLabel() {
        UIView.animate(withDuration: KUtteranceAnimationDuration) { self.utteranceLabel.alpha = 0 }
    }
    
}
