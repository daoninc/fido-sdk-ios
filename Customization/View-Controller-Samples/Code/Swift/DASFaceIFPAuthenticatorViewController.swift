//
//  DASFaceIFPAuthenticatorViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2024 Daon. All rights reserved.
//

import DaonAuthenticatorSDK
import DaonAuthenticatorFaceIFP

/*!
 @brief View Controller for collecting a face image.
 */
@objc(DASFaceIFPAuthenticatorViewController)
class DASFaceIFPAuthenticatorViewController: DASAuthenticatorViewControllerBase {
            
    // A DASFaceCapture object used for capturing a photo for registering or authenticating
    var capture: DASFaceCapture?
    
    override init(nibName nibNameOrNil: String?,
                  bundle nibBundleOrNil: Bundle?,
                  context authenticatorContext: DASAuthenticatorContext?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: authenticatorContext)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
                
        let registration = singleAuthenticatorContext?.isRegistration ?? true;
    
        // Configure the face controller
        capture = DASFaceCapture(context: singleAuthenticatorContext)
        capture?.delegate = self
        capture?.deviceUprightDetection = false
        capture?.medicalMaskDetection = false
        capture?.allowConfirmation = registration ? true : false
        capture?.quality = .low
                        
        capture?.enhancedDetection = registration ? true : false
        capture?.assessmentDelay = 0.75
        
        capture?.start(controller: self)
    }
    
         
    /*!
     @brief Called when the authenticator UI should be reset due to the view controller being removed from its parent.
     Typically this happens when transitioning between authenticators in a multi-authenticator policy. Resetting ensures
     that when transitioning back to the authenticator that it is back in its default prepared state.
     */
    override func authenticatorShouldReset() {
        super.authenticatorShouldReset()
        
        // If the controller is nil, we may be at the start of collection so don't do anything.
        if capture != nil {
            isCancelling = true
            
            capture?.cancel()
        }
    }
    
    /*!
     @brief Cancels the UI by stopping frame analysis and telling the context which will dismiss the UI.
     */
    override func authenticatorIsCancelling() {
        capture?.cancel()
        super.authenticatorIsCancelling()
    }
        
    func vibrate() {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }
}

extension DASFaceIFPAuthenticatorViewController : DASFaceCaptureDelegate {
    func faceCaptureDidUpdate(result: DaonFaceCapture.Result, image: UIImage) {
        print("faceCaptureDidUpdate")
    }
    
    func faceCaptureWillSubmit(image: UIImage) {
        vibrate()
        print("faceCaptureWillSubmit")
    }
    
    
}
