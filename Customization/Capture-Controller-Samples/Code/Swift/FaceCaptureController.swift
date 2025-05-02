//
//  FaceCaptureController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import DaonAuthenticatorSDK

class FaceCaptureController: DASCaptureControllerProtocol {
    // MARK:- Member variables
    
    private let context : DASAuthenticatorContext
    private var navigationController: UINavigationController?
    
    
    // MARK:- Initialisation
    
    init(context: DASAuthenticatorContext) {
        //
        // Hold onto the DASAuthenticatorContext object as we will need it to complete capture later. We will also
        // provide it to the FaceViewController.
        //
        self.context = context
    }
    
    
    // MARK:- From DASCaptureControllerProtocol
    
    func execute() {
        // Instantiate the faceViewController and present it. A FaceCompletionHandler closure will be used to
        // pass back control to this object once capture completes, fails or is cancelled.
        //
        // The FaceViewController class is based off of the DASFaceAuthenticatorViewController sample code
        // and will initialize it's faceController which will make it responsible for providing frames to the faceController.
        //
        // Video recording configuration can be seen in the FaceViewController class's configureVideo method.
        //
        // Handling of the video frames can be seen in the FaceViewController class's
        // captureOutput:didOutputSampleBuffer:fromConnection: method.
        //
        let faceViewController = FaceViewController(nibName: "FaceViewController", bundle: nil, context: context) { [weak self] (error) in
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
        
        navigationController = UINavigationController(rootViewController: faceViewController!)
        navigationController!.navigationBar.isTranslucent = false
        
        DASUtils.determineHostViewController()?.present(navigationController!,
                                                        animated: true,
                                                        completion: nil)
    }
    
}
