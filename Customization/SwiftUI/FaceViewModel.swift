//
//  FaceViewModel.swift
//  SDKDemo
//
//  Copyright © 2025 Daon. All rights reserved.
//
import SwiftUI

import DaonAuthenticatorFaceIFP
import DaonAuthenticatorSDK
import DaonFaceSDK


class FaceViewModel : NSObject, ObservableObject,  @MainActor DASFaceCaptureDelegate {
    
    private var context: DASAuthenticatorContext?
    
    private var useCustomView: Bool
    private var registration: Bool
    private var capture: DASFaceCapture?
    
    enum State {
        case start
        case confirm
        case error
    }
    
    @Published var busy : Bool = false
    @Published var buttons : Bool = true
    @Published var error : String = ""
    @Published var message : String = "Get ready to capture your face"
    @Published var state : State = .start
    @Published var color : Color = .gray
    
    @MainActor
    init(context: DASAuthenticatorContext?, useCustomView: Bool = false) {
        self.context = context
        self.useCustomView = useCustomView
        self.capture = DASFaceCapture(context: context)
        self.registration = context?.isRegistration ?? false
    }
    
    var title : String {
        guard let context = context else {
            return "Face (SwiftUI)"
        }
            
       return "\(context.authenticatorInfo?.authenticatorName ?? "Face") (SwiftUI)"
    }
    
    // Use the Face Capture API to capture and submit an image to the server
    @MainActor
    func startCapture() {
        
        showButtonBar(state: .start)
        
        // Configure the face controller
        capture?.deviceUprightDetection = true
        capture?.medicalMaskDetection = false
        capture?.allowConfirmation = registration ? true : false
        capture?.quality = .low
        capture?.style = useCustomView ? .fullScreen : .automatic
        capture?.messages = useCustomView ? false : true
        capture?.captureMode = .manual
        capture?.delegate = self
        capture?.setParameters([kDFSConfigQualityThresholdEyesOpenKey: 0.65])
        capture?.start(controller: DASUtils.determineHostViewController()) {
            print("CAPTURE DONE")
        }
    }
    
    private func showButtonBar(state: State, error: String = "") {
        self.buttons = true
        self.busy = false
        self.state = state
        self.error = error
        self.color = .clear
    }
        
    private func hideButtonBar() {
        self.buttons = false
    }
    
    private func setBusy() {
        self.busy = true
        hideButtonBar()
    }
    
    @MainActor func start() {
        hideButtonBar()
        capture?.reset()
    }
    
    @MainActor func confirm() {
        setBusy()
                
        capture?.submit()
    }
    
    @MainActor func retry() {
        hideButtonBar()
        self.message = "Get ready to capture your face again"
        capture?.reset()
    }
    
    @MainActor func cancel() {
        capture?.cancel() {
            if self.state != .start {
                self.context?.completeCapture(error: .cancelled)
            }
        }
    }
    
    //
    // DASFaceCaptureDelegate methods
    //
    
    func faceCaptureDidUpdate(message: String, image: UIImage?) {
        self.message = message
    }
    
    func faceCaptureDidUpdate(result: Result, image: UIImage) {
        // Don't stay in this delegate too long.
        
        if result.hasAcceptableQuality && result.isDeviceUpright {
            self.color = .green
        } else {
            self.color = .red
        }
    }
    
    @MainActor
    func faceCaptureDidFail(error: Error) {
        // Capture failed and retry is allowed.
        
        self.showButtonBar(state: .error, error: error.localizedDescription)
        
        if error._code == DASAuthenticatorError.authenticatorAuthTokenMismatch.rawValue {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.cancel()
            }
        }
    }
    
    // Custom view and overlay
    @MainActor
    func faceCaptureShouldUseView(frame: CGRect) -> UIView? {
        
        if #available(iOS 15.0, *) {
            if useCustomView {
                // Some trickery to convert a SwiftUI View to UIView
                let vc = UIHostingController(rootView: FaceCustomView(model: self))
                vc.view.frame = frame
                vc.view.backgroundColor = .clear
                vc.loadView()
                
                return vc.view
            }
        }
        return nil
    }
    
    func faceCaptureWillSubmit(image: UIImage) -> Bool {
        
        // Custom view button logic
        // Only show retry and confirm for registration
        if self.registration {
            showButtonBar(state: .confirm)
        } else {
            setBusy()
        }
        
        // Don't auto submit the image if using a custom view
        if useCustomView {
            // If it is a registration don't submit the image unless the confirm button is pressed, if
            // authentication just submit the image.
            return !self.registration
        }
        
        return true
    }
}

