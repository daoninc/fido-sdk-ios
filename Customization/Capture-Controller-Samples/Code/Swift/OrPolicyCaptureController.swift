//
//  OrPolicyCaptureController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import DaonAuthenticatorSDK

class OrPolicyCaptureController: DASCaptureControllerProtocol {
    // MARK:- Member variables
    
    fileprivate unowned let multiAuthenticatorContext : DASMultiAuthenticatorContext
    fileprivate let availableAuthenticators: [DASAuthenticatorInfo]
    fileprivate var singleAuthenticatorContext: DASAuthenticatorContext?
    fileprivate var singleAuthenticatorCaptureController : DASCaptureControllerProtocol?
    
    
    // MARK:- Initialisation
    
    init(context: DASMultiAuthenticatorContext) {
        self.multiAuthenticatorContext = context
        
        //
        // Determine which factors we need to collect.
        //
        // For this sample we are expecting there to be only 1 group of factors (an authenticator group) as we are handling an AND policy.
        //
        var authenticators = [DASAuthenticatorInfo]()
        
        if let availableAuthenticatorGroups = self.multiAuthenticatorContext.requestedAuthenticatorGroups() {
            if availableAuthenticatorGroups.count > 0 {
                authenticators = availableAuthenticatorGroups[0]
            }
        }
        
        self.availableAuthenticators = authenticators
    }
    
    
    // MARK:- DASCaptureControllerProtocol
    
    func execute() {
        //
        // Use the list of factors to build and display an Action Sheet listing all the available authenticators.
        //
        if availableAuthenticators.count > 0 {
            let alertController = UIAlertController(title: "Available Authenticators", message: nil, preferredStyle: .actionSheet)
            
            for authenticatorInfo in availableAuthenticators {
                //
                // Present an action sheet with all the available authenticators
                //
                alertController.addAction(UIAlertAction(title: authenticatorInfo.authenticatorName, style: .default, handler: { (action) in
                    self.executeAuthenticator(authenticatorInfo)
                }))
            }

            alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                self.handleCaptureComplete(DASAuthenticatorError.cancelled)
            }))
            
            
            // Set popover properties for iPad
            let hostViewController = DASUtils.determineHostViewController()
            
            if let hostView = hostViewController?.view {
                alertController.popoverPresentationController?.sourceView = hostView
                alertController.popoverPresentationController?.sourceRect = CGRect(x: hostView.center.x, y: hostView.center.y, width: 0, height: 0)
            }
            
            hostViewController?.present(alertController, animated: true, completion: nil)
        } else {
            print("ERROR: No factors configured.")
            showErrorAndTerminate(.authenticatorInconsistentState)
        }
    }

    
    // MARK:- Authenticators
    
    private func executeAuthenticator(_ authenticator: DASAuthenticatorInfo) {
        let factor = authenticator.authenticatorFactor
        
        //
        // Make sure the authenticator is not invalidated or locked
        //
        if authenticator.authenticatorLockState == .temporary {
            handleCaptureComplete(.authenticatorTooManyAttemptsTempLocked)
        } else if authenticator.authenticatorLockState == .permanent {
            handleCaptureComplete(.authenticatorTooManyAttemptsPermLocked)
        } else if authenticator.authenticatorInvalidated {
            handleCaptureComplete(.localAuthenticationEnrollmentHasChanged)
        } else {
            //
            // Tell the DASMultiAuthenticatorContext the factor we are preparing to execute.
            //
            multiAuthenticatorContext.activeFactor = factor
            
            //
            // Use the DASMultiAuthenticatorContext to create the individual DASAuthenticatorContext for the
            // authenticator.
            //
            singleAuthenticatorContext = multiAuthenticatorContext.authenticatorContext(for: factor,
                                                                                        completionHandler: { (factor) in self.handleCaptureComplete(nil) },
                                                                                        failureHandler: { (factor, error) in self.handleCaptureComplete(error) })
            
            var silentCompletion = false
            
            if (singleAuthenticatorContext != nil) {
                //
                // Create and execute the individual DASCaptureControllerProtocol object for the specified factor.
                //
                singleAuthenticatorCaptureController = nil
                
                if factor == .password || factor == .passwordADoS {
                    singleAuthenticatorCaptureController = PasscodeCaptureController(context: singleAuthenticatorContext!)
                } else if factor == .fingerprint || (DASUtils.isFaceIDSupported() && factor == .face) {
                    singleAuthenticatorCaptureController = AppleBiometricsCaptureController(context: singleAuthenticatorContext!)
                } else if factor == .voice || factor == .voiceADoS {
                    singleAuthenticatorCaptureController = VoiceCaptureController(context: singleAuthenticatorContext!)
                } else if factor == .face || factor == .faceADoS {
                    singleAuthenticatorCaptureController = FaceIFPCaptureController(context: singleAuthenticatorContext!)
                } else if factor == .silent || factor == .silentAccessibility || factor == .offlineOTP {
                    silentCompletion = true
                }
                
                if singleAuthenticatorCaptureController != nil {
                    singleAuthenticatorCaptureController!.execute()
                } else if silentCompletion {
                    singleAuthenticatorContext!.completeCapture()
                } else {
                    // Unsupported authenticator
                    handleCaptureComplete(.authenticatorNotImplemented)
                }
            } else {
                print("ERROR: Single authenticator context was not created for factor: ", factor)
                handleCaptureComplete(.authenticatorInconsistentState)
            }
        }
    }
    
    
    // MARK:- Completion Handling
    
    private func handleCaptureComplete(_ error: DASAuthenticatorError?) {
        //
        // Cleanup to prevent retain cycles
        //
        singleAuthenticatorContext              = nil
        singleAuthenticatorCaptureController    = nil
        
        //
        // Terminates the capture process by telling the DASMultiAuthenticatorContext
        // object that we are done.
        //
        if error == nil {
            multiAuthenticatorContext.completeCapture()
        } else {
            if error! == .fallback {
                var switched = false
                
                // Look for ADoS/SRP fallback first
                for authInfo in availableAuthenticators {
                    if authInfo.authenticatorFactor == .passwordADoS {
                        executeAuthenticator(authInfo)
                        switched = true
                        break;
                    }
                }
                
                if !switched {
                    // No SRP fallback, so look for regular passcode.
                    for authInfo in availableAuthenticators {
                        if authInfo.authenticatorFactor == .password {
                            executeAuthenticator(authInfo)
                            switched = true
                            break;
                        }
                    }
                }
                
                if !switched {
                    print("ERROR: No fallback factor is available to switch to.")
                    multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
                }
            } else {
                multiAuthenticatorContext.completeCaptureWithError(error!)
            }
        }
    }
    
    
    // MARK:- Utilities
    
    private func showErrorAndTerminate(_ error: DASAuthenticatorError) {
        let errorObj = DASUtils.error(forError: error)
        
        let alertController = UIAlertController(title: errorObj?.localizedDescription, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
            self.handleCaptureComplete(error)
        }))
        
        DASUtils.determineHostViewController()?.present(alertController, animated: true, completion: nil)
    }
    
}
