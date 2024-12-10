//
//  DASPasswordAuthenticatorViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019 Daon. All rights reserved.
//
import DaonAuthenticatorPasscode

/*!
 @typedef DASPasscodeCaptureState
 @brief Categorizes the UI states that the passcode collection screen moves through.
 @constant DASPasscodeCaptureStateAuthentication            User is being prompted to enter an existing passcode for authentication.
 @constant DASPasscodeCaptureStateRegistration              User is being prompted to enter a new passcode for registration.
 @constant DASPasscodeCaptureStateRegistrationConfirmation  User is being prompted to confirm (re-enter) the new passcode for registration.
 */
enum DASPasscodeCaptureState: Int
{
    case preparing                  = -1
    case authentication             = 0
    case registration               = 1
    case registrationConfirmation   = 2
}

/*!
 @brief View Controller for collecting a passcode.
 */
@objc(DASPasswordAuthenticatorViewController)
class DASPasswordAuthenticatorViewController: DASAuthenticatorViewControllerBase, UITextFieldDelegate, DASDataControllerWrapperDelegate
{
    // MARK:- Controllers
    
    /*!
     @brief A @link DASDataControllerWrapperProtocol @/link object used for registering, authenticating and reenrolling passcodes.
     */
    fileprivate var dataController: DASDataControllerWrapperProtocol?
    
    
    // MARK:- State
    
    /*!
     @brief The current @link DASPasscodeCaptureState @/link state of the view controller.
     */
    fileprivate var state: DASPasscodeCaptureState = .preparing
    
    /*!
     @brief An NSMutableDictionary of @link DASPasscodeCaptureState @/link Ints to String passcode
     */
    fileprivate var capturedPasscodes = [DASPasscodeCaptureState:String]()
    
    /*!
     @brief Flag to keep track of if we are submitting, so that duplicate submissions cannot be made.
     */
    fileprivate var submitting = false
    
    
    // MARK:- Validation
    
    /*!
     @brief The minimum password length as specified in the extensions. Defaults to 4 for registration and NSNotFound (no minimum) for authentication.
     */
    fileprivate var minLength = NSNotFound
    
    /*!
     @brief The maximum password length as specified in the extensions. Defaults to 8 for registration and NSNotFound (no maximum) for authentication.
     */
    fileprivate var maxLength = NSNotFound
    

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
     @brief A UITextField where the user can enter their passcode.
     */
    @IBOutlet var entryTextField: UITextField!
    
    /*!
     @brief A UIButton the user can press to continue.
     */
    @IBOutlet var nextButton: UIButton!
    
    /*!
     @brief A UIImageView which displays a success icon after registration / authentication is complete.
     */
    @IBOutlet var resultImageView: UIImageView!
    
    /*!
     @brief A UIActivityIndicatorView which is shown while ADoS data is being sent to the server.
     */
    @IBOutlet var adosIndicatorView: UIActivityIndicatorView!

    
    // MARK:- Initialization
    
    /*!
     @brief Instantiates a new @link DASPasswordAuthenticatorViewController @/link object.
     @param nibNameOrNil Passed through to designated initializer
     @param nibBundleOrNil Passed through to designated initializer
     @param authenticatorContext The @link DASAuthenticatorContext @/link object with which this view controller can register or authenticate voice samples.
     @return A new @link DASPasswordAuthenticatorViewController @/link object.
     */
    override init!(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, context authenticatorContext: DASAuthenticatorContext?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: authenticatorContext)

        self.dataController    = DASPasscodeAuthenticatorFactory.createDataControllerWrapper(with: authenticatorContext, delegate: self)
        self.minLength         = dataController!.passcodeMinLength()
        self.maxLength         = dataController!.passcodeMaxLength()
        
        //
        // By default once an authenticator has been locked due to too many failed attempts,
        // the controller will take control of displaying a locked authenticator error then
        // will tear down the authenticator UI itself. If you wish to display this error yourself
        // then uncomment the following and handle the lock errors in
        // dataControllerFailedWithError:
        //
        // self.dataController!.delegateWillHandleLockEvents = true
        //
        
        // Set the tabBarItem in case this view controller is being displayed in a UITabBarController
        self.tabBarItem.title = localise("Password Screen - Title")
        
        self.determineInitialState()
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
        self.backgroundImageView.image = loadImageNamed("Password-Collection-Background")
        
        self.title = localise("Password Screen - Title") + " (Swift)"
        
        updateInstructions()
        
        nextButton.setTitle(localise("Button - Title - Next"), for: .normal)
        
        self.resultImageView.isHidden     = true
        self.adosIndicatorView.isHidden   = true
        
        if (DASUtils.isDarkModeEnabled())
        {
            if #available(iOS 13.0, *)
            {
                self.adosIndicatorView.style = .medium
                self.adosIndicatorView.color = .white
            }
        }
        
        configureTextFieldWithAnimation(false)
        
        entryTextField.delegate = self
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
            // Reset the controller & UI, so that the user may capture again.
            //
            self.dataController = DASPasscodeAuthenticatorFactory.createDataControllerWrapper(with: self.singleAuthenticatorContext, delegate: self)
            resetWithError(nil)
        }
    }
    
    /*!
     @brief Called when the view has appeared. We use this to present the keyboard.
     @param animated YES if view appearance will be animated.
     */
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        entryTextField.becomeFirstResponder()
    }

    
    //MARK:- From DASAuthenticatorViewControllerBase - Actions
    
    /*!
     @brief Called when the authenticator UI should be reset due to the view controller being removed from its parent. Typically this
     happens when transitioning between authenticators in a multi-authenticator policy. Resetting ensures that when transitioning
     back to the authenticator that it is back in its default prepared state.
     */
    override func authenticatorShouldReset()
    {
        super.authenticatorShouldReset()
        entryTextField.resignFirstResponder()
        resetWithError(nil)
    }
    
    /*!
     @brief Cancels the authenticator by telling the context which will dismiss the UI. Override in sub-classes
     in order to perform any authenticator specific cancellation before calling the base class.
     */
    override func authenticatorIsCancelling()
    {
        entryTextField.resignFirstResponder()
        super.authenticatorIsCancelling()
    }
    
    
    // MARK:- State

    /*!
     @brief Determines what the current @link DASPasscodeCaptureState @/link is.
     */
    fileprivate func determineInitialState()
    {
        if (singleAuthenticatorContext!.isRegistration)
        {
            state = .registration
        }
        else
        {
            state = .authentication
        }
    }
    
    /*!
     @brief Switches to a new state and updates the UI.
     @param newState The new state to switch to.
     */
    fileprivate func resetForNextInputState(_ newState:DASPasscodeCaptureState)
    {
        state = newState
    
        configureTextFieldWithAnimation(true)
        updateInstructions()
        entryTextField.becomeFirstResponder()
    }
    
    
    // MARK:- Actions
    
    /*!
     @brief IBAction called when @link nextButton @/link is pressed.
     @param sender The control that sent this event.
     */
    @IBAction func nextButtonPressed(_ sender: UIButton?)
    {
        objc_sync_enter(self) // Combined with setting the submitting boolean, this prevents a race condition where the user presses the next button multiple times.
        
        if (!submitting)
        {
            submitting = true

            if (entryTextField.text?.count == 0)
            {
                // Nothing entered, reset and show error.
                resetWithError(string(forError: .passwordIsEmpty))
            }
            else
            {
                // We have a non-empty string, so store it and determine what should happen next based on the current state.
                capturedPasscodes[state] = entryTextField.text
                
                switch (state)
                {
                    case .authentication:
                        if (dataController!.isReenrollmentRequested())
                        {
                            // Current passcode is collected, ADoS Reenroll is required so begin collecting the new (replacement) passcode.
                            resetForNextInputState(.registration)
                            submitting = false
                        }
                        else
                        {
                            // Current passcode is collected, attempt submission.
                            validateAndSubmit()
                        }
                        break
                    
                    case .registration:
                        // New passcode is collected, ask for it again to confirm.
                        resetForNextInputState(.registrationConfirmation)
                        submitting = false
                        break
                    
                    case .registrationConfirmation:
                        // New passcode is collected, attempt submission.
                        validateAndSubmit()
                        break
                    
                    default:
                        break
                }
            }
        }
            
        objc_sync_exit(self)
    }
    

    // MARK- Passcode submission
    
    /*!
     @brief Validates the inputted text then submits it to the @link dataController @/link.
     */
    fileprivate func validateAndSubmit()
    {
        // Check that passcode is in the correct format.
        if (!validatePasscodesEntered())
        {
            resetWithError(string(forError: .passwordIsEmpty))
        }
        else if (!validatePasscodesAreTheSame())
        {
            resetWithError(string(forError: .passwordMismatch))
        }        
        else if (self.singleAuthenticatorContext!.isRegistration && !self.singleAuthenticatorContext!.isADoSRequired && !validatePasscodesAreTheCorrectLength())
        {
            var message : String?
            
            if (minLength != NSNotFound && maxLength != NSNotFound)
            {
                message = String(format: localise("Password Screen - Error - Wrong Lengths - Formatted"), minLength, maxLength)
            }
            else if (minLength != NSNotFound)
            {
                // Only need to complain that the passcode is too short
                message = String(format: localise("Password Screen - Error - Too short - Formatted"), minLength)
            }
            else
            {
                // Only need to complain that the passcode is too long
                message = String(format: localise("Password Screen - Error - Too long - Formatted"), maxLength)
            }
            
            resetWithError(message)
        }
        else
        {
            // Passcodes are in the correct format, transition to the processing UI, then begin the registration / authentication / reenrollment.
            
            hideCancelButton()
            
            entryTextField.resignFirstResponder()
            entryTextField.isEnabled = false
            
            UIView.animate(withDuration: 0.25,
                           animations: { self.nextButton.alpha = 0 },
                           completion: { (finished) in
                                            self.adosIndicatorView.alpha    = 0
                                            self.adosIndicatorView.isHidden = false
                            
                                            UIView.animate(withDuration: 0.25,
                                                           animations: { self.adosIndicatorView.alpha = 1 },
                                                           completion: { (finished) in
                                                                            if (self.dataController!.isReenrollmentRequested())
                                                                            {
                                                                                let existingPasscode        = self.capturedPasscodes[.authentication]
                                                                                let newPasscodeToRegister   = self.capturedPasscodes[.registration]
                                                                                self.dataController!.reenroll(withExistingPasscode: existingPasscode, andNewPasscode: newPasscodeToRegister)
                                                                            }
                                                                            else if (self.singleAuthenticatorContext!.isRegistration)
                                                                            {
                                                                                let passcodeToRegister = self.capturedPasscodes[.registration]
                                                                                self.dataController!.registerPasscode(passcodeToRegister)
                                                                            }
                                                                            else
                                                                            {
                                                                                let passcodeToAuthenticate = self.capturedPasscodes[.authentication]
                                                                                self.dataController!.authenticatePasscode(passcodeToAuthenticate)
                                                                            }
                                                                        })
                                        })
        }
    }
    
    
    // MARK:- Password Validation
    
    /*!
     @brief Determines whether we have all the required passcodes.
     @return YES is all required passcodes have been collected.
     */
    fileprivate func validatePasscodesEntered() -> Bool
    {
        var passcodesArePresent = false
        
        let registrationPasscode                = capturedPasscodes[.registration]
        let registrationConfirmationPasscode    = capturedPasscodes[.registrationConfirmation]
        let authenticationPasscode              = capturedPasscodes[.authentication]
        
        if (self.singleAuthenticatorContext!.isRegistration)
        {
            // We are collecting for registration so make sure we have the new passcode plus the re-entered passcode for confirmation.
            passcodesArePresent = registrationPasscode != nil && registrationPasscode!.count > 0
                                && registrationConfirmationPasscode != nil && registrationConfirmationPasscode!.count > 0
        }
        else
        {
            // We are collecting for authentication..
            
            if (dataController!.isReenrollmentRequested())
            {
                // ADoS reenroll is required, so make sure we have the current passcode, the new passcode, and the new re-entered passcode for confirmation.
                passcodesArePresent = authenticationPasscode != nil && authenticationPasscode!.count > 0
                                    && registrationPasscode != nil && registrationPasscode!.count > 0
                                    && registrationConfirmationPasscode != nil && registrationConfirmationPasscode!.count > 0
            }
            else
            {
                // Only the authentication passcode is needed.
                passcodesArePresent = authenticationPasscode != nil && authenticationPasscode!.count > 0
            }
        }
        
        return passcodesArePresent
    }

    /*!
     @brief Determines whether the collected registration passcodes are the same.
     @return YES if both registration passcodes are the same.
     */
    fileprivate func validatePasscodesAreTheSame() -> Bool
    {
        var passcodesAreTheSame = true
        
        if (self.singleAuthenticatorContext!.isRegistration || dataController!.isReenrollmentRequested())
        {
            if let passcode = capturedPasscodes[.registration], let confirmationPasscode = capturedPasscodes[.registrationConfirmation]
            {
                if (passcode.count > 0 && confirmationPasscode.count > 0)
                {
                    passcodesAreTheSame = passcode == confirmationPasscode
                }
                else
                {
                    passcodesAreTheSame = false
                }
            }
            else
            {
                passcodesAreTheSame = false
            }
        }
        
        return passcodesAreTheSame
    }
    
    /*!
     @brief Determines whether all of the collected passcodes are the correct length.
     @discussion NSNotFound is returned from the @link dataController @/link for min and max lengths and means "no limit".
     @return YES if all collected passcodes are the correct length.
     */
    fileprivate func validatePasscodesAreTheCorrectLength() -> Bool
    {
        var passcodesAreTheCorrectLength = true
        
        for passcode in capturedPasscodes.values
        {
            if (minLength != NSNotFound)
            {
                if (passcode.count < minLength)
                {
                    passcodesAreTheCorrectLength = false
                    break
                }
            }
            
            if (maxLength != NSNotFound)
            {
                if (passcode.count > maxLength)
                {
                    passcodesAreTheCorrectLength = false
                    break
                }
            }
        }
        
        return passcodesAreTheCorrectLength
    }
    
    /*!
     @brief Determines whether the current registered passcode and the one collected for reenrollment are different.
     @return YES if the current registered passcode and the one collected for reenrollment are different.
     */
    fileprivate func validateCurrentAndReenrollPasscodesAreNotTheSame() -> Bool
    {
        var passcodesAreDifferent = true
        
        if (dataController!.isReenrollmentRequested())
        {
            if let currentPasscode = capturedPasscodes[.authentication], let reenrollPasscode = capturedPasscodes[.registration]
            {
                if (currentPasscode.count > 0 && reenrollPasscode.count > 0)
                {
                    passcodesAreDifferent = currentPasscode != reenrollPasscode
                }
                else
                {
                    passcodesAreDifferent = false
                }
            }
            else
            {
                passcodesAreDifferent = false
            }
        }
        
        return passcodesAreDifferent
    }
    
    
    // MARK:- From DASDataControllerWrapperDelegate
    
    /*!
     @brief From the @link DASDataControllerWrapperDelegate @/link: Used to notify a conforming object that the controllers current task has completed successfully.
     */
    func dataControllerCompletedSuccessfully()
    {
        self.hideCancelButton()
        
        UIView.animate(withDuration: 0.25,
                       animations: {
                                        self.nextButton.alpha           = 0
                                        self.adosIndicatorView.alpha    = 0
                                    },
                       completion: { (finished) in
                                        self.adosIndicatorView.isHidden = true
                                        self.resultImageView.alpha      = 0
                                        self.resultImageView.isHidden   = false
                                        self.resultImageView.image      = self.loadImageNamed("Passed-Indicator")
                                        
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
                                    })
    }
    
    /*!
     @brief From the @link DASDataControllerWrapperDelegate @/link: Used to notify a conforming object that the controllers current task has failed.
     @param error An error that caused the current task to fail, such as entering an incorrect passcode.
     */
    func dataControllerFailedWithError(_ error: Error!)
    {
        //
        // We only need to check for lock errors if dataController!.delegateWillHandleLockEvents has previously been set to
        // YES (See the comments in initWithNibName:bundle:context:), otherwise the SDK will handle them (display an error
        // and terminate capture). Code is included here just for completeness.
        //
        if (error._code == DASAuthenticatorError.authenticatorTooManyAttemptsTempLocked.rawValue
            || error._code == DASAuthenticatorError.authenticatorTooManyAttemptsPermLocked.rawValue
            || error._code == DASAuthenticatorError.serverTooManyAttempts.rawValue)
        {
            if let authenticatorError = DASAuthenticatorError(rawValue: error._code)
            {
                self.singleAuthenticatorContext!.completeCapture(error: authenticatorError)
            }
            else
            {
                NSLog(String(format: "Could not convert error to DASAuthenticatorError: %d - %@", error._code, error.localizedDescription))
                self.singleAuthenticatorContext!.completeCapture(error: .authenticatorInconsistentState)
            }
        }
        else
        {
            self.resetWithError(error.localizedDescription)
        }
    }
    
    
    // MARK:- UITextFieldDelegate
    
    /*!
     @brief From the @link UITextFieldDelegate @/link: Used to notify a conforming object that the "Next" button on the on-screen keyboard has been pressed.
     @param textField The UITextField that raised the event.
     */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        nextButtonPressed(nil)
        
        return true
    }

    
    // MARK:- Misc UI
    
    /*!
     @brief Sets up the UITextField that is used for passcode entry.
     @param animate If YES we will show a transition as we move from passcode entry to passcode confirmation entry.
     */
    fileprivate func configureTextFieldWithAnimation(_ animate: Bool)
    {
        // Set the primary properties
        self.entryTextField.text                            = ""
        self.entryTextField.autocapitalizationType          = .none
        self.entryTextField.autocorrectionType              = .no
        self.entryTextField.enablesReturnKeyAutomatically   = true
        self.entryTextField.returnKeyType                   = .next
        self.entryTextField.adjustsFontSizeToFitWidth       = true
        self.entryTextField.textAlignment                   = .left
        self.entryTextField.keyboardType                    = dataController!.passcodeKeyboardType()
        self.entryTextField.leftViewMode                    = .always
        self.entryTextField.clearButtonMode                 = .whileEditing
        self.entryTextField.isSecureTextEntry               = true
        self.entryTextField.isEnabled                       = true

        if (state == .registrationConfirmation)
        {
            self.entryTextField.placeholder = localise("Password Screen - Text Field Place Holder - Confirmation")
        }
        else
        {
            self.entryTextField.placeholder = localise("Password Screen - Text Field Place Holder")
        }
        
        if (animate)
        {
            startAnimation(on: self.entryTextField, transition: .flipFromLeft)
        }
    }
    
    /*!
     @brief Update the on-screen instructions based on the current state.
     */
    fileprivate func updateInstructions()
    {
        switch (state)
        {
            case .authentication:
                if (dataController!.isReenrollmentRequested())
                {
                    self.instructionsLabel.text = localise("Password Screen - Instructions - Authentication - Current")
                }
                else
                {
                    self.instructionsLabel.text = localise("Password Screen - Instructions - Authentication")
                }
                break
            
            case .registration:
                if (dataController!.isReenrollmentRequested())
                {
                    self.instructionsLabel.text = localise("Password Screen - Instructions - Reenroll")
                }
                else
                {
                    self.instructionsLabel.text = localise("Password Screen - Instructions - Registration")
                }
                break
            
            case .registrationConfirmation:
                if (dataController!.isReenrollmentRequested())
                {
                    self.instructionsLabel.text = localise("Password Screen - Instructions - Reenroll - Confirm")
                }
                else
                {
                    self.instructionsLabel.text = localise("Password Screen - Instructions - Registration - Confirm")
                }
                break
            
            default:
                break
        }
    }
    
    
    // MARK:- Resetting
    
    /*!
     @brief Resets the UI to it's default state.
     @errorMessage An error that caused the reset. It will be displayed on screen.
     */
    fileprivate func resetWithError(_ errorMessage: String?)
    {
        showCancelButton()
        determineInitialState()
        updateInstructions()
        
        submitting = false
        
        capturedPasscodes.removeAll()
        
        self.resultImageView.isHidden   = true
        self.nextButton.alpha           = 1
        self.entryTextField.isEnabled   = true
        self.adosIndicatorView.isHidden = true
        
        self.configureTextFieldWithAnimation(false)
        
        if let message = errorMessage
        {
            if (message.count != 0)
            {
                self.showAlert(withTitle: localise("Alert - Title - Error"), message: message)
                {
                    self.entryTextField.becomeFirstResponder()
                }
            }
        }
    }
}
