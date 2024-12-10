//
//  DASFingerprintAuthenticatorViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019 Daon. All rights reserved.
//

import DaonAuthenticatorSDK

/*!
 @brief View Controller for presenting the Touch ID dialog.
 */
@objc(DASFingerprintAuthenticatorViewController)
class DASFingerprintAuthenticatorViewController: DASAuthenticatorViewControllerBase
{
    // MARK:- Controllers
    
    /*!
     @brief A @link DASFingerprintControllerProtocol @/link objects used for registering and authenticating Touch ID.
     */
    fileprivate var fingerprintController: DASFingerprintControllerProtocol?
    
    
    // MARK:- State
    
    /*!
     @brief A flag used to keep track of whether the Touch ID dialog has been presented once. We do this automatically in viewDidAppear.
     */
    fileprivate var autoPresentedOnce = false
    
    
    // MARK:- IBOutlets
    
    /*!
     @brief A UIImageView which fills the background.
     */
    @IBOutlet var backgroundImageView: UIImageView!
    
    /*!
     @brief A UIButton which when pressed allows the user to attempt Face ID registration / authentication again if it was previously cancelled.
     */
    @IBOutlet var retryButton: UIButton!
    
    /*!
     @brief A UIImageView which displays a success icon after registration / authentication is complete.
     */
    @IBOutlet var resultImageView: UIImageView!
    
    
    // MARK:- Initialization
    
    /*!
     @brief Instantiates a new @link DASFingerprintAuthenticatorViewController @/link object.
     @param nibNameOrNil Passed through to designated initializer
     @param nibBundleOrNil Passed through to designated initializer
     @param authenticatorContext The @link DASAuthenticatorContext @/link object with which this view controller can register or authenticate Touch ID.
     @return A new @link DASFingerprintAuthenticatorViewController @/link object.
     */
    override init!(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, context authenticatorContext: DASAuthenticatorContext?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: authenticatorContext)
        
        // Instantiate the fingerprint controller.
        //
        // Here we are requesting the wrapper version of the fingerprint controller. This means that the controller
        // will take care of showing an error and dismissing the UI if the authenticator is locked due to too many attempts.
        //
        fingerprintController = authenticatorContext!.createFingerprintControllerWrapper(withSDKHandlingLockEvents: true)
        
        // Set the tabBarItem in case this view controller is being displayed in a UITabBarController
        self.tabBarItem.title = localise("Fingerprint Screen - Title")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- View Lifecycle
    
    /*!
     @brief Called after view has been loaded. Sets up the initial UI state.
     */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Configure the UI
        self.backgroundImageView.image = loadImageNamed("Fingerprint-Collection-Background")
        
        self.title = localise("Fingerprint Screen - Title") + " (Swift)"
        
        self.retryButton.setTitle(localise("Fingerprint Screen - Button - Retry"), for: .normal)
        self.retryButton.isHidden = true
        
        self.resultImageView.isHidden = true
        self.resultImageView.image = loadImageNamed("Passed-Indicator")
    }
    
    /*!
     @brief Called when the view is about to be made visible. We use this to reset the UI if capture was previously completed.
     @param animated YES if view appearance will be animated.
     */
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if (self.captureCompleted)
        {
            self.captureCompleted = false
            
            // Capture has already completed successfully once. So if viewWillAppear is happening again
            // then the user must have gone back through the navigation stack.
            //
            // Reset the UI, so that the user may capture again.
            //
            self.retryButton.isHidden       = false
            self.resultImageView.isHidden   = true
        }
    }
    
    /*!
     @brief Called when the view has appeared. We use this to automatically present the Touch ID dialog.
     @param animated YES if view appearance will be animated.
     */
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // The first time the view appears, automatically present
        // the Touch ID dialog.
        if (!autoPresentedOnce)
        {
            autoPresentedOnce   = true
            self.isCancelling   = false
            
            performTouchIDAuthentication()
        }
    }

    
    // MARK:- From DASAuthenticatorViewControllerBase - Actions
    
    /*!
     @brief Called when the authenticator UI should be reset due to the view controller being removed from its parent. Typically this
     happens when transitioning between authenticators in a multi-authenticator policy. Resetting ensures that when transitioning
     back to the authenticator that it is back in its default prepared state.
     */
    override func authenticatorShouldReset()
    {
        super.authenticatorShouldReset()
        
        self.isCancelling   = true
        autoPresentedOnce   = false
        
        fingerprintController!.cancel()
    }
    
    
    // MARK:- Actions
    
    /*!
     @brief IBAction called when @link retryButton @/link is pressed.
     */
    @IBAction func retry(_ sender: UIButton?)
    {
        self.isCancelling = false
        
        performTouchIDAuthentication()
    }
    
    
    // MARK:- Touch ID
    
    /*!
     @brief Uses the @link fingerprintController @/link to bring up the Touch ID dialog and handle its response.
     */
    fileprivate func performTouchIDAuthentication()
    {
        if (!self.isCancelling)
        {
            var localizedReason = localise("Fingerprint Screen - Reason - Authentication")
            
            if (self.singleAuthenticatorContext!.isRegistration)
            {
                localizedReason = localise("Fingerprint Screen - Reason - Registration")
            }
            
            fingerprintController!.performAuthentication(withReason: localizedReason) { (error) in
                if (!self.isCancelling)
                {
                    if (error == nil)
                    {
                        self.retryButton.isHidden       = true
                        self.resultImageView.alpha      = 0
                        self.resultImageView.isHidden   = false
                        
                        UIView.animate(withDuration: 0.25,
                                       animations: { self.resultImageView.alpha = 1 },
                                       completion: { (finished) in
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute:
                                        {
                                            if (!self.isCancelling)
                                            {
                                                self.captureCompleted = true
                                                self.showCancelButton()
                                                self.singleAuthenticatorContext?.completeCapture()
                                            }
                                        })
                        })
                    }
                    else
                    {
                        self.retryButton.isHidden = false
                        
                        if let authenticatorError = DASAuthenticatorError(rawValue: error!._code)
                        {
                            if (authenticatorError != .cancelled)
                            {
                                var message = self.string(forError: authenticatorError)
                                
                                if (message == "UNKNOWN")
                                {
                                    message = self.string(forError: .fingerprintFailedToVerify)
                                }
                                
                                self.showAlert(withTitle: self.localise("Alert - Title - Error"),
                                               message: message)
                            }
                        }
                        else
                        {
                            NSLog(String(format: "Could not convert error to DASAuthenticatorError: %d - %@", error!._code, error!.localizedDescription))
                            self.singleAuthenticatorContext!.completeCapture(error: .authenticatorInconsistentState)
                        }
                    }
                }
            }
            
        }
    }
}