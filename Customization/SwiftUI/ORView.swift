//
//  ORView.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import SwiftUI

import DaonAuthenticatorSDK
import DaonCryptoSDK

/// SwiftUI view for switching between different SwiftUI authenticator views.

@available(iOS 15.0, *)
struct ORView: View {
    
    @ObservedObject private var model : ORViewModel
    
    
    /// Initializes a new instance of the `ORView` struct.
    /// - Parameter context: The `DASMultiAuthenticatorContext` object with which the views model can gain access to the set of available authenticators for registration / authentication.
    init(context: DASMultiAuthenticatorContext) {
        self.model = ORViewModel(context: context)
    }
    
    var body: some View {
        VStack {
            Picker("Authenticator", selection: self.$model.currentAuthenticatorIndex) {
                ForEach(self.model.availableAuthenticators) {
                    Image(uiImage:$0.icon)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            currentAuthenticatorView()
            Spacer()
        }
        .navigationBarTitle("OR Policy (SwiftUI)")
    }
        
    /// Determines at run time which view to return for the currently selected authenticator.
    private func currentAuthenticatorView() -> AnyView {
        
        guard let authenticator = self.model.currentAuthenticator else {
            return AnyView(ErrorView(error: "Not Supported"))
        }
        
        guard authenticator.authenticatorLockState == .unlocked else {
            return AnyView(ErrorView(error: "\(authenticator.authenticatorName!)\n\nAuthenticator is locked"))
        }
        
        guard !authenticator.authenticatorInvalidated else {
            return AnyView(ErrorView(error: "\(authenticator.authenticatorName!)\n\nAuthenticator is invalidated"))
        }
        
        guard let singleAuthenticatorContext = self.model.createSingleAuthenticatorContext(factor: authenticator.authenticatorFactor) else {
            return AnyView(ErrorView(error: "\(authenticator.authenticatorName!)\n\nCouldn't create context"))
        }
        
        switch authenticator.authenticatorFactor {
            case .password, .passwordADoS:
                return AnyView(PasscodeView(context: singleAuthenticatorContext))
                
            case .face:
                if (DASUtils.isLocalAuthenticatorFactor(authenticator.authenticatorFactor, version: authenticator.authenticatorVersion)) {
                    return AnyView(LocalAuthenticationView(context: singleAuthenticatorContext))
                }
                
                return AnyView(FaceView(context: singleAuthenticatorContext))
            
            case .faceADoS:
                return AnyView(FaceView(context: singleAuthenticatorContext))
                
            case .fingerprint:
                return AnyView(LocalAuthenticationView(context: singleAuthenticatorContext))
                
            case .voice, .voiceADoS:
                return AnyView(VoiceView(context: singleAuthenticatorContext))
                
            default:
                return AnyView(ErrorView(error: "\(authenticator.authenticatorName!)\n\nNot Implemented"))
        }
    }
}


/// A struct which stores an authenticator's index and its icon for use in the PickerView.
struct AuthInfo: Identifiable {
    let id: Int
    let icon: UIImage
    let name : String
}

/// The model class from which the ORView determines its state.
class ORViewModel: NSObject, ObservableObject {
    
    /// The authenticator information required by the Picker view.
    @Published var availableAuthenticators = [AuthInfo]()
    
    /// The segment index of the Picker view.
    @Published var currentAuthenticatorIndex = 0 { willSet { currentAuthenticator = authenticators[newValue] }}
    
    /// The full authenticator information for the current authenticator.
    var currentAuthenticator: DASAuthenticatorInfo?
    
    /// The `DASMultiAuthenticatorContext` object with which the model can gain access to the set of available authenticators for registration/authentication.
    private var multiAuthenticatorContext: DASMultiAuthenticatorContext
    
    /// The full authenticator information for all of the available authenticators.
    private var authenticators = [DASAuthenticatorInfo]()
    
    /// Initializes a new instance of the `ORViewModel` class.
    /// - Parameter context: The `DASMultiAuthenticatorContext` object with which the model can gain access to the set of available authenticators for registration/authentication.
    init(context: DASMultiAuthenticatorContext) {
        
        multiAuthenticatorContext = context
        
        guard let authGroups = multiAuthenticatorContext.requestedAuthenticatorGroups() else {
            multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
            return
        }
        
        // For OR Policies, there can only be one group of authenticators
        // from which the user selects. If there isn't, complete with an error.
        if (authGroups.count == 1) {
            authenticators = authGroups[0]
            
            // We need at least two authenticators in order to display an OR, If there isn't, complete with an error.
            if (authenticators.count >= 2) {
                // Populate the segmented control with the authenticator
                
                var segments = [AuthInfo]()
                
                for i in 0..<authenticators.count {
                    let authenticatorInfo   = authenticators[i]
                    let resizedImage        = DASUtils.resize(authenticatorInfo.authenticatorIcon, to: CGSize(width: 30, height: 30))
                    
                    segments.append(AuthInfo(id: i, icon: resizedImage!, name: authenticatorInfo.authenticatorName))
                }
                
                // Find and select the first authenticator that is:
                // - Unlocked
                // - Not invalidated
                //
                var selectedAuthenticator = false
                
                for i in 0..<authenticators.count {
                    let firstAuthenticator = authenticators[i]
                    
                    if firstAuthenticator.authenticatorLockState == .unlocked && !firstAuthenticator.authenticatorInvalidated {
                        // Found an unlocked and not invalidated authenticator. Update the segmented control index,
                        // tell the context which authenticator is currently capturing.
                        currentAuthenticator                    = firstAuthenticator
                        currentAuthenticatorIndex               = i
                        selectedAuthenticator                   = true
                        multiAuthenticatorContext.activeFactor  = currentAuthenticator!.authenticatorFactor
                        break
                    }
                }
                
                if selectedAuthenticator {
                    availableAuthenticators = segments
                } else {
                    multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
                }
            } else {
                multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
            }
        } else {
            multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
        }
    }
    
    /// Creates an individual authenticator context for a specific factor.
    /// - Parameter factor: The factor that will be displayed.
    /// - Returns: The new `DASAuthenticatorContext`.
    func createSingleAuthenticatorContext(factor: DASAuthenticatorFactor) -> DASAuthenticatorContext? {
        //
        // Use the DASMultiAuthenticatorContext to create the individual DASAuthenticatorContext for the
        // authenticator.
        //
        
        //
        // Tell the DASMultiAuthenticatorContext the factor we are preparing to execute.
        //
        multiAuthenticatorContext.activeFactor = factor
        
        return multiAuthenticatorContext.authenticatorContext(for: factor) { _ in
                                                                    self.multiAuthenticatorContext.completeCapture()
                                                                } failureHandler: { (failedFactor, error) in
                                                                    
                                                                    // If we are including our own cancel button, ignore the cancel
                                                                    // event that comes from the contained authenticator view which
                                                                    // is called when switching tabs. E.g if the authenticator is locked.
                                                                    if error != .cancelled {
                                                                        self.multiAuthenticatorContext.completeCaptureWithError(error)
                                                                    }
                                                                }
    }
    
    /// Cancels and dismisses the authenticator UI.
    func cancel() {
        multiAuthenticatorContext.cancelCapture()
    }
        
}

