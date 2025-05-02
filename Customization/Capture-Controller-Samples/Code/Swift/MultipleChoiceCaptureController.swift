//
//  MultipleChoiceCaptureController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import UIKit

import DaonAuthenticatorSDK

class MultipleChoiceCaptureController: DASCaptureControllerProtocol {
    // MARK:- Member variables
    
    fileprivate unowned let multiAuthenticatorContext : DASMultiAuthenticatorContext
    
    
    // MARK:- Initialisation
    
    init(context: DASMultiAuthenticatorContext) {
        self.multiAuthenticatorContext = context
    }
    
    
    // MARK:- DASCaptureControllerProtocol
    
    func execute() {
        multiAuthenticatorContext.completeCaptureWithError(.authenticatorNotImplemented)
    }
}
