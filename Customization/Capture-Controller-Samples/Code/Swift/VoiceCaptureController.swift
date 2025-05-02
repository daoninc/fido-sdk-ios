//
//  VoiceCaptureController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2024 Daon. All rights reserved.
//

import DaonAuthenticatorSDK

class VoiceCaptureController: DASCaptureControllerProtocol {
    
    private unowned let context : DASAuthenticatorContext
    private var navigationController: UINavigationController?
    
    
    // MARK:- Initialisation
    
    init(context: DASAuthenticatorContext) {
        //
        // Hold onto the DASAuthenticatorContext object as we will need it to complete capture later. We will also
        // provide it to the VoiceViewController.
        //
        self.context = context
    }
    
    
    // MARK:- From DASCaptureControllerProtocol
    
    func execute() {
        // Instantiate the voiceViewController and present it. A VoiceCompletionHandler block will be used to
        // pass back control to this object once capture completes, fails or is cancelled.
       
        let voiceViewController = VoiceViewController(nibName: "DASVoiceAuthenticatorViewController",
                                                      bundle: nil,
                                                      context: context) { [weak self] (error) in
            self?.navigationController!.dismiss(animated: true) {
                // Capture is complete, notify the context.
                if error == nil {
                    self?.context.completeCapture()
                } else if error! == .cancelled {
                    self?.context.cancelCapture()
                } else {
                    self?.context.completeCapture(error: error!)
                }
            }
        }
        
        navigationController = UINavigationController(rootViewController: voiceViewController!)
        navigationController!.navigationBar.isTranslucent = false
        
        DASUtils.determineHostViewController()?.present(navigationController!,
                                                        animated: true,
                                                        completion: nil)
    }
}
