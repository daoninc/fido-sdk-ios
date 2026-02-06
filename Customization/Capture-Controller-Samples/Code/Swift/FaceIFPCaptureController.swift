//
//  FaceIFPCaptureController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-24 Daon. All rights reserved.
//

import DaonAuthenticatorSDK
import DaonAuthenticatorFaceIFP

class FaceIFPCaptureController: DASCaptureControllerProtocol {
    
    private let context : DASAuthenticatorContext
    private var capture : DASFaceCapture?
    
    init(context: DASAuthenticatorContext) {
        //
        // Hold onto the DASAuthenticatorContext object as we will need it to complete capture later. We will also
        // provide it to the FaceViewController.
        //
        self.context = context
    }
    
    func execute() {
        
        DispatchQueue.main.async {
            let registration = self.context.isRegistration
            
            // Configure the face controller
            self.capture = DASFaceCapture(context: self.context)
            self.capture?.deviceUprightDetection = false
            self.capture?.medicalMaskDetection = false
            self.capture?.allowConfirmation = registration ? true : false
            self.capture?.quality = .low
            self.capture?.overlay = true
            
                            
            self.capture?.enhancedDetection = registration ? true : false
            self.capture?.assessmentDelay = 0.75
            
            self.capture?.start(controller: DASUtils.determineHostViewController())
        }
    }
    
}
