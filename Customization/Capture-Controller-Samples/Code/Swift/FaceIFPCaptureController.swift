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
    
    
    init(context: DASAuthenticatorContext) {
        //
        // Hold onto the DASAuthenticatorContext object as we will need it to complete capture later. We will also
        // provide it to the FaceViewController.
        //
        self.context = context
    }
    
    func execute() {
        
        let registration = context.isRegistration
        
        // Configure the face controller
        let capture = DASFaceCapture(context: self.context)
        capture?.deviceUprightDetection = false
        capture?.medicalMaskDetection = false
        capture?.allowConfirmation = registration ? true : false
        capture?.quality = .low
        capture?.overlay = true
        
                        
        capture?.enhancedDetection = registration ? true : false
        capture?.assessmentDelay = 0.75
        
        capture?.start(controller: DASUtils.determineHostViewController())
    }
    
}
