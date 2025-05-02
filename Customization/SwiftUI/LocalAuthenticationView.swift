//
//  LocalAuthenticationView.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2020-25 Daon. All rights reserved.
//

import SwiftUI

import DaonAuthenticatorSDK

/// SwiftUI view for Touch ID / Face ID registration and authentication.

@available(iOS 15.0, *)
struct LocalAuthenticationView: View {
    
    @ObservedObject private var model : LocalAuthenticationViewModel

    init(context: DASAuthenticatorContext) {
        self.model = LocalAuthenticationViewModel(context: context)
    }
    
    var body: some View {
        Text(model.info)
            .navigationBarTitle(model.info)
            .background(Color(.systemBackground))
            .onAppear { model.performAuthentication() }
            .onDisappear { model.dismiss() }
            .alert(model.error, isPresented: $model.alert) {
                Button("OK", role: .cancel) { model.cancel() }
            }
    }
}


/// The model class from which the LocalAuthenticationView determines it's state.
/// 
private class LocalAuthenticationViewModel : ObservableObject {
    
    @Published var info : String = ""
    @Published var alert : Bool = false
    @Published var error : String = ""
    
    private var context: DASAuthenticatorContext
    
    /// A @link DASAppleBiometricsControllerProtocol @/link object used for registering and authenticating Touch ID / Face ID.
    private var _controller: DASAppleBiometricsControllerProtocol?
    private var controller : DASAppleBiometricsControllerProtocol {
        if _controller == nil {
            if context.authenticatorInfo?.authenticatorFactor == .fingerprint {
                _controller = DASAuthenticatorFactory.getFingerprintControllerWrapper(with: context, sdkHandlingLockEvents: true)
            } else {
                _controller = DASAuthenticatorFactory.getFaceIdControllerWrapper(with: context, sdkHandlingLockEvents: true)
            }
        }
        
        return _controller!
    }
    
     /// Initializes a new @link LocalAuthenticationViewModel @/link object.
     /// - Parameter context: The @link DASAuthenticatorContext @/link object with which this view controller can register or authenticate Touch ID / Face ID.
    init(context: DASAuthenticatorContext) {
        self.context = context
                
        info = "\(context.authenticatorInfo?.authenticatorName ?? "NA") (SwiftUI)"
    }
    
    func cancel() {
        context.cancelCapture()
    }
    
    func dismiss() {
        if !context.isCaptureComplete {
            cancel()
        }
    }
    
    func performAuthentication() {
        let reason = context.isRegistration ? "Register" : "Authenticate"
        
        controller.performAuthentication(withReason: reason) { (error) in
            
            guard let err = error else {
                self.context.completeCapture()
                return
            }
            
            // Show an error
            if let authenticatorError = DASAuthenticatorError(rawValue: err._code) {
                if authenticatorError != .cancelled {
                    DispatchQueue.main.async { // Published properties should be updated on the main thread.
                        self.error = DASUtils.string(forError: authenticatorError) ?? DASUtils.string(forError: .faceIdFailedToVerify)
                        self.alert = true
                    }
                } else {
                    self.cancel()
                }
            }
        }
    }    
}
