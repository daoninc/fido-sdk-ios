//
//  AppleBiometricsCaptureController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import DaonAuthenticatorSDK

class AppleBiometricsCaptureController: DASCaptureControllerProtocol {
    // MARK:- Member variables
    
    fileprivate unowned let context : DASAuthenticatorContext
    fileprivate var appleBiometricsController : DASAppleBiometricsControllerProtocol?

    
    // MARK:- Initialisation
    
    init(context: DASAuthenticatorContext) {
        //
        // Hold onto the DASAuthenticatorContext object and use it to create the appleBiometricsController.
        //
        // When creating the appleBiometricsController, we pass false for withSDKHandlingLockEvents to ensure
        // that we don't miss lock events that would typically be handled by the SDK as it is usually presenting the UI.
        //
        self.context = context

        if DASUtils.isFaceIDSupported() {
            self.appleBiometricsController = self.context.createFaceIdControllerWrapper(withSDKHandlingLockEvents: false)
        } else {
            self.appleBiometricsController = self.context.createFingerprintControllerWrapper(withSDKHandlingLockEvents: false)
        }
    }
    
    
    // MARK:- From DASCaptureControllerProtocol
    
    func execute() {
        if let controller = appleBiometricsController {
            if context.isRegistration {
                //
                // REGISTRATION
                //
                // Silently register
                //
                if DASUtils.isTouchIDEnabled() || DASUtils.isFaceIDEnabled() {
                    // We have local biometrics, complete silently.
                    handleCaptureComplete(nil)
                } else {
                    // We do not have local biometrics, complete with an error.
                    handleCaptureComplete(.localAuthBiometryNotEnrolled)
                }
            } else {
                //
                // AUTHENTICATION
                //
                // Present the TouchID/FaceID UI
                //
                
                controller.performAuthentication(withReason: "Test Auth", completionHandler: { (error) in
                    if let biometryError = error {
                        // Have an error, complete capture with it.
                        self.handleCaptureComplete(DASAuthenticatorError(rawValue: biometryError._code)!)
                    } else {
                        // No error, user is authenticated, complete capture
                        self.handleCaptureComplete(nil)
                    }
                }, fallback: "Use Passcode instead", terminateOnFallback: false)
 
            }
        } else {
            print("ERROR: No appleBiometricsController available!")
            handleCaptureComplete(.authenticatorInconsistentState)
        }
    }
    
    
    // MARK:- Completion Handling
    
    private func handleCaptureComplete(_ error: DASAuthenticatorError?) {
        //
        // Cleanup to prevent retain cycles
        //
        appleBiometricsController = nil
        
        //
        // Terminates the capture process by telling the DASAuthenticatorContext
        // object that we are done.
        //
        if error == nil {
            context.completeCapture()
        } else if error! == .cancelled {
            context.cancelCapture()
        } else {
            context.completeCapture(error: error!)
        }
    }

}
