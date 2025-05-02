//
//  VoiceViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2024 Daon. All rights reserved.
//

import DaonAuthenticatorSDK
import DaonAuthenticatorVoice

typealias VoiceCompletionHandler = (DASAuthenticatorError?) -> Void

class VoiceViewController: DASVoiceAuthenticatorViewController {
            
    /*!
     @brief The block to be executed when capture has completed, failed, or been cancelled.
     */
    private let completionHandler: VoiceCompletionHandler
    
    
    override func authenticatorIsCancelling() {
        super.authenticatorIsCancelling()
        completionHandler(.cancelled)
    }

    override func controllerDidCompleteSuccessfully() {
        super.controllerDidCompleteSuccessfully()
        completionHandler(nil)
    }
        
    override func fail(error: Error) {
        if !isCancelling {
            let authenticatorError = DASAuthenticatorError(rawValue: error._code)
            if authenticatorError == .serverUserLockout
                || authenticatorError == .serverTooManyAttempts
                || authenticatorError == .serverVoiceTooManyAttempts
                || authenticatorError == .authenticatorTooManyAttemptsTempLocked
                || authenticatorError == .authenticatorTooManyAttemptsPermLocked {
                
                singleAuthenticatorContext?.completeCapture(error: authenticatorError!)
                completionHandler(authenticatorError)
            } else {
                reset(error: error, recaptureAllSamples:voiceSampleIndex >= expectedVoiceSamples)
            }
        }
    }

    init!(nibName nibNameOrNil: String!,
          bundle nibBundleOrNil: Bundle!,
          context authenticatorContext: DASAuthenticatorContext,
          completionHandler: @escaping VoiceCompletionHandler) {
        self.completionHandler  = completionHandler
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: authenticatorContext)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

