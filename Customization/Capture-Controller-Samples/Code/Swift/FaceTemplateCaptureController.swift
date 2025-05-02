//
//  FaceTemplateCaptureController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2020-25 Daon. All rights reserved.
//

import DaonAuthenticatorFace
import DaonAuthenticatorSDK

class FaceTemplateCaptureController: DASCaptureControllerProtocol {
    // MARK:- Member variables
    
    fileprivate let authTemplateString = "REZWMwEBAAAAgAAAAAAAAAAfTQG/S88oPwKbsr07jFq/XaVSvgsWEb+Sgwo/8USSv0moyT3o3To/Ct2jv0sfHD8cHxLA0v4pv+mxhb/2zpI/KSH5vqwon7+ISw++hljdvdTXLT/NepM/IQmSPZWyO0BtyKM/q93NviEJjz+jKba/kPjHv0rjNj/yzqQ9Qxysvmooyb/nzqE/8oR9vywzwr/UG8y/AawgPhXxmL+tik2/YojCvsKLA7/1W+e+rB5RPyBTMb4zQ5A/fneivgarlb4bMzm/76dYPy5crj56V9O/eZ7Zv3HEVL8IFoK/T9U5vDF4YT9vePy/cYMNP6grsb8g2hBAsVwDPopuHj4K4gBA4bCvPYPgxb5ZJus+AQFOP6sGLD8/c8Q+GVKPPgCeCcBlVq2+iLbKPycpQb2nz/A9jTm2P3/yAEBoulI/bO7iP+RoA0CVkEy/z0mRPgqC5r6tOO8+yvcywHWKYD/BZrA+jzXNvaoms7/TMYW9XzSiv0euNr9yO9g/kEx9Pn8K2L7gCss/ZyyPP5F6iT+rVIw/PmTuPqO56z4y5FI/r4m+vd4IDL4zdVa/T4OCPylsoj/I/CG/2PjQvqLwor90owg+SBaZvIlgcb1w06o77jF3vptoCD+Esty/dBw1v0OQ+L7oxrI9cuBTv6VORL4eFQLANcioP03YuT6LqOy+2aC1Pw=="
    fileprivate let context : DASAuthenticatorContext
    fileprivate let faceTemplateController : DASFaceTemplateControllerProtocol
    
    
    // MARK:- Initialisation
    
    init(context: DASAuthenticatorContext) {
        //
        // Hold onto the DASAuthenticatorContext object as we will need it to complete capture later. We will also
        // provide it to the Face Template Controller.
        //
        self.context = context
        self.faceTemplateController = DASFaceAuthenticatorFactory.createFaceTemplateController(with: context)
    }
    
    
    // MARK:- From DASCaptureControllerProtocol
    
    func execute() {
        if let template = Data(base64Encoded: authTemplateString) {
            faceTemplateController.authenticateTemplate(template) { (passed, score, error) in
                if passed {
                    print("Face template verified!")
                    self.context.completeCapture()
                } else {
                    print("ERROR: \(error!._code) - \(error!.localizedDescription)")
                    
                    if let authError = DASAuthenticatorError(rawValue: error!._code) {
                        self.context.completeCapture(error: authError)
                    } else {
                        self.context.completeCapture(error: .faceFailedToAuthenticate)
                    }
                }
            }
        } else {
            print("ERROR: Invalid template")
            context.completeCapture(error: .authenticatorInconsistentState)
        }
    }
    
}
