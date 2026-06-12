//
//  PasscodeCaptureController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import DaonAuthenticatorSDK
import DaonAuthenticatorPasscode

class PasscodeCaptureController: DASCaptureControllerProtocol, DASDataControllerWrapperDelegate {
    // MARK:- Member variables
    
    fileprivate unowned let context : DASAuthenticatorContext
    fileprivate var dataController : DASDataControllerWrapperProtocol?
    fileprivate var customViewController: PasscodeViewController?
    fileprivate var navigationController: UINavigationController?
    
    
    // MARK:- Initialisation
    
    init(context: DASAuthenticatorContext) {
        //
        // Hold onto the DASAuthenticatorContext object and use it to create the dataController.
        //
        self.context        = context
        self.dataController = DASPasscodeAuthenticatorFactory.createDataControllerWrapper(with: self.context, delegate: self)
        
        //
        // Ensure that we get all lock events from the SDK because we are in control of the UI presentation.
        // When the SDK is in charge of lock events it will take care of dismissing the UI itself.
        //
        self.dataController?.delegateWillHandleLockEvents = true
    }
    
    
    // MARK:- From DASCaptureControllerProtocol
    
    func execute() {
        if let controller = dataController {
            if context.isRegistration {
                //
                // REGISTRATION
                //
                // Silently register the passcode
                //
                // On successful registration, dataControllerCompletedSuccessfully will be called.
                //
                controller.registerPasscode("1234")
            } else {
                //
                // AUTHENTICATION
                //
                // Present the custom UI, using the inputHandler and cancellationHandler
                // closures to handle events.
                //
                
                customViewController = PasscodeViewController(nibName: "PasscodeViewController",
                                                              bundle: nil,
                                                              inputHandler: { (passcode) in
                                                                                //
                                                                                // User has entered a passcode, authenticate it against the registered passcode.
                                                                                //
                                                                                // On successful authentication, dataControllerCompletedSuccessfully will be called.
                                                                                // On failed authentication, dataControllerFailedWithError will be called.
                                                                                //
                                                                                controller.authenticatePasscode(passcode)
                                                                            },
                                                              cancellationHandler: {
                                                                                        //
                                                                                        // User has pressed cancel, remove the view controller and end capture.
                                                                                        //
                                                                                        self.navigationController!.dismiss(animated: true, completion: {
                                                                                            self.handleCaptureComplete(.cancelled)
                                                                                        })
                                                                                    })
                
                navigationController = UINavigationController(rootViewController: customViewController!)
                navigationController!.navigationBar.isTranslucent = false
                
                DASUtils.determineHostViewController()?.present(navigationController!,
                                                                animated: true,
                                                                completion: nil)
            }
        } else {
            print("ERROR: No passcodeController available!")
            handleCaptureComplete(.authenticatorInconsistentState)
        }
    }

    
    // MARK:- From DASDataControllerWrapperDelegate
    
    func dataControllerCompletedSuccessfully() {
        //
        // The data control has completed processing successfully so complete capture.
        //
        
        if context.isRegistration {
            //
            // REGISTRATION
            //
            // We are performing registration silently, we can complete capture immediately.
            //
            handleCaptureComplete(nil)
        } else {
            //
            // AUTHENTICATION
            //
            // We are presenting a UI for authentication, so we make sure to dismiss that first.
            //
            navigationController!.dismiss(animated: true, completion: {
                self.handleCaptureComplete(nil)
            })
        }
    }
    
    func dataControllerFailedWithError(_ error: Error!) {
        //
        // The data control has failed processing.
        //
        
        if context.isRegistration {
            //
            // REGISTRATION
            //
            // We are performing registration silently, so if that fails then
            // we cancel the whole capture process.
            //
            handleCaptureComplete(DASAuthenticatorError(rawValue: error._code))
        } else {
            //
            // AUTHENTICATION
            //
            // We are presenting a UI for authentication, so we tell the custom view controller
            // to display the error.
            //
            // If the authenticator has been locked, dismiss the UI and end capture
            //
            if error._code == DASAuthenticatorError.authenticatorTooManyAttemptsTempLocked.rawValue
                || error._code == DASAuthenticatorError.authenticatorTooManyAttemptsTempLocked.rawValue
                || error._code == DASAuthenticatorError.serverTooManyAttempts.rawValue {
                navigationController!.dismiss(animated: true, completion: {
                    self.handleCaptureComplete(DASAuthenticatorError(rawValue: error._code))
                })
            } else {
                customViewController?.handleError(error.localizedDescription)
            }
        }
    }
    
    
    // MARK:- Completion Handling
    
    private func handleCaptureComplete(_ error: DASAuthenticatorError?) {
        //
        // Cleanup to prevent retain cycles
        //
        dataController          = nil
        navigationController    = nil
        customViewController    = nil
        
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
