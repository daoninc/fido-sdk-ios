//
//  AndPolicyCaptureController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import DaonAuthenticatorSDK

class AndPolicyCaptureController: DASCaptureControllerProtocol {
    // MARK:- Member variables
    
    fileprivate unowned let multiAuthenticatorContext : DASMultiAuthenticatorContext
    fileprivate var requiredAuthenticators: [DASAuthenticatorInfo]
    fileprivate var completedFactors = [DASAuthenticatorFactor]()
    
    fileprivate var singleAuthenticatorContext: DASAuthenticatorContext?
    fileprivate var singleAuthenticatorCaptureController: DASCaptureControllerProtocol?
    
    
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
        
        self.requiredAuthenticators = authenticators
    }
    
    
    // MARK:- DASCaptureControllerProtocol
    
    func execute() {
        //
        // Make sure there are only supported authenticators in the set of required authenticators. Then
        // execute the first one.
        //
        if requiredAuthenticators.count > 0 {
            // Return an error if there are unsupported factors:
            var haveUnsupportedFactors = false

            for authenticator in requiredAuthenticators {
                let factor = authenticator.authenticatorFactor
                
                if factor == .silent || factor == .silentAccessibility || factor == .offlineOTP {
                    haveUnsupportedFactors = true
                    print("ERROR: Factor %ld is not currently supported by the capture controller mechanism", factor)
                    break
                }
            }
            
            if !haveUnsupportedFactors {
                executeNextAuthenticator(completedFactor: nil)
            } else {
                print("ERROR: Unsupported authenticators.")
                showErrorAndTerminate(error: .authenticatorNotSupported)
            }
        } else {
            print("ERROR: No factors configured.")
            showErrorAndTerminate(error: .authenticatorInconsistentState)
        }
    }

    
    // MARK:- Authenticators
    
    private func executeNextAuthenticator(completedFactor: DASAuthenticatorFactor?) {
        if completedFactor != nil {
            completedFactors.append(completedFactor!)
        }
        
        if completedFactors.count == requiredAuthenticators.count {
            //
            // All factors have been completed
            //
            handleCaptureComplete(nil)
        } else {
            //
            // More factors to complete, find the first one that isn't completed
            //
            for authenticator in requiredAuthenticators {
                if !completedFactors.contains(authenticator.authenticatorFactor) {
                    let supported = executeAuthenticator(forFactor: authenticator.authenticatorFactor)
                    if !supported {
                        showErrorAndTerminate(error: .authenticatorNotImplemented)
                    }
                    break
                }
            }
        }
    }
    
    private func executeAuthenticator(forFactor factor: DASAuthenticatorFactor) -> Bool {
        var supported = true
        
        //
        // Tell the DASMultiAuthenticatorContext the factor we are preparing to execute.
        //
        multiAuthenticatorContext.activeFactor = factor
        
        //
        // Use the DASMultiAuthenticatorContext to create the individual DASAuthenticatorContext for the
        // authenticator.
        //
        singleAuthenticatorContext = multiAuthenticatorContext.authenticatorContext(for: factor,
                                                                                    completionHandler: { (factor) in self.executeNextAuthenticator(completedFactor: factor) },
                                                                                    failureHandler: { (factor, error) in self.handleCaptureComplete(error) })
        
        if singleAuthenticatorContext != nil {
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
            } else if factor == .faceADoS {
                singleAuthenticatorCaptureController = FaceIFPCaptureController(context: singleAuthenticatorContext!)
            } else {
                supported = false
            }
            
            if singleAuthenticatorCaptureController != nil {
                singleAuthenticatorCaptureController!.execute()
            }
        } else {
            print("ERROR: Single authenticator context was not created for factor: ", factor)
            showErrorAndTerminate(error: .authenticatorInconsistentState)
        }
        
        return supported
    }
    
    
    // MARK:- Completion Handling
    
    private func handleCaptureComplete(_ error: DASAuthenticatorError?) {
        //
        // Cleanup to prevent retain cycles
        //
        completedFactors.removeAll()
        requiredAuthenticators.removeAll()
        singleAuthenticatorContext              = nil
        singleAuthenticatorCaptureController    = nil
        
        //
        // Terminates the capture process by telling the DASMultiAuthenticatorContext
        // object that we are done.
        //
        if error == nil {
            multiAuthenticatorContext.completeCapture()
        } else {
            multiAuthenticatorContext.completeCaptureWithError(error!)
        }
    }
    
    
    // MARK:- Utilities
    
    private func showErrorAndTerminate(error: DASAuthenticatorError) {
        let errorObj = DASUtils.error(forError: error)
        
        let alertController = UIAlertController(title: errorObj?.localizedDescription, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
            self.handleCaptureComplete(error)
        }))
        
        DASUtils.determineHostViewController()?.present(alertController, animated: true, completion: nil)
    }
    
}
