//
//  PasscodeView.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import SwiftUI

import DaonAuthenticatorPasscode
@preconcurrency import DaonAuthenticatorSDK
import DaonCryptoSDK

#Preview {
    if #available(iOS 15.0, *) {
        PasscodeView(context: nil)
    } else {
        // Fallback on earlier versions
    }
}

/// SwiftUI view for passcode registration and authentication.

@available(iOS 15.0, *)
struct PasscodeView: View {
    
    /// The model that this view monitors for state changes.
    @ObservedObject private var model : PasscodeViewModel
    
    @State private var textInput : String = ""

    
    /// Initializes a new instance of the @link PasscodeView @/link struct.
    /// - Parameter context: The @link DASAuthenticatorContext @/link object with which the view can gain access to a passcode controller for registration and authentication.
    init(context: DASAuthenticatorContext?) {
        self.model = PasscodeViewModel(context: context)
    }
    
    /// The content and behavior of the view.
    var body: some View {
        
        VStack {
            Text(model.info)
                .multilineTextAlignment(.center)
                .padding([.top, .horizontal])
            
            if $model.busy.wrappedValue {
                ProgressView()
            } else if $model.done.wrappedValue {
                Image("Passed-Indicator")
                    .resizable()
                    .frame(width: 32, height: 32, alignment: .center)
            } else {
                SecureField("", text: $textInput)
                    .frame(width: 200, height: 31)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(model.keyboardType())
                    .background(Color(.systemFill))
                    .multilineTextAlignment(.center)
                    .cornerRadius(5)
                
                Button("NEXT") {
                    self.model.buttonPressed(input: self.textInput)
                    self.textInput = ""
                }
                .buttonStyle(.bordered)
                .padding()
            }
            
            Spacer()
        }
        .navigationBarTitle(model.title)
        .background(Color(.systemBackground))
        .onDisappear {
            model.dismiss()
        }
        .alert(model.error, isPresented: $model.alert) {
            Button("OK", role: .cancel) { model.reset() }
        }
    }
    
}

class PasscodeViewModel : ObservableObject, @MainActor DASDataControllerWrapperDelegate {
        
    private var context: DASAuthenticatorContext?
    private var inputs: [String] = []
    
    @Published var info : String = "Enter passcode"
    @Published var error : String = ""
    @Published var alert : Bool = false
    @Published var busy : Bool = false
    @Published var done : Bool = false
    
    init(context: DASAuthenticatorContext?) {
        self.context = context
    }
    
    var title : String {
        guard let context = context else {
            return "Passcode (SwiftUI)"
        }
        
       return "\(context.authenticatorInfo?.authenticatorName ?? "Passcode") (SwiftUI)"
    }
    
    @MainActor
    private var _controller: DASDataControllerWrapperProtocol?
    
    @MainActor
    private var controller : DASDataControllerWrapperProtocol {
        if _controller == nil {
            _controller = DASPasscodeAuthenticatorFactory.createDataControllerWrapper(with: context, delegate: self)
            _controller?.delegateWillHandleLockEvents = true
        }
        
        return _controller!
    }
    
    @MainActor func buttonPressed(input: String) {
        
        guard let context = context else {
            return
        }
        
        inputs.append(input)
                
        if input.isEmpty {
            reset(error: DASUtils.string(forError:.passwordIsEmpty))
        }
        
        if controller.isReenrollmentRequested() {
        
            if inputs.count == 1 {
                info = "Enter new passcode"
            } else if inputs.count == 2 {
                info = "Re-enter new passcode"
            } else if inputs.count == 3 {
                if  inputs[1] == inputs[2] {
                    
                    self.busy = true
                    
                    controller.reenroll(withExistingPasscode: inputs[0], andNewPasscode: inputs[1])
                } else {
                    reset(error:DASUtils.string(forError: .passwordMismatch))
                }
            }
        } else if context.isRegistration {
            if inputs.count > 1 {
                if  inputs[0] == inputs[1] {
                    
                    self.busy = true
                    
                    controller.registerPasscode(inputs[0])
                } else {
                    reset(error:DASUtils.string(forError: .passwordMismatch))
                }
            } else {
                info = "Re-enter passcode"
            }
        } else {
            self.busy = true
            
            controller.authenticatePasscode(inputs[0])
        }
    }
                
    /// Resets the internal properties to their default state.
    func reset(error: String? = nil) {
        inputs.removeAll()
        
        self.busy = false
        self.done = false
        self.info = "Enter passcode"
        
        if let e = error {
            self.alert = true
            self.error = e
        }
    }
    
    func cancel() {
        if let context = context {
            context.cancelCapture()
        }
    }
    
    func dismiss() {
        if let context = context {
            if !context.isCaptureComplete {
                cancel()
            }
        }
    }
    
    @MainActor func keyboardType() -> UIKeyboardType {
        return controller.passcodeKeyboardType()
    }

    @MainActor
    func dataControllerCompletedSuccessfully() {
        
        self.busy = false
        self.done = true
        
        // Pause a bit
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.context?.completeCapture()
        }
    }
    
    func dataControllerFailedWithError(_ error: Error) {
                
        if error._code == DASAuthenticatorError.authenticatorTooManyAttemptsTempLocked.rawValue
            || error._code == DASAuthenticatorError.authenticatorTooManyAttemptsPermLocked.rawValue
            || error._code == DASAuthenticatorError.aDoSTooManyAttemptsServerLocked.rawValue {
            if let authenticatorError = DASAuthenticatorError(rawValue: error._code) {
                self.context?.completeCapture(error: authenticatorError)
            } else {
                self.context?.completeCapture(error: .authenticatorInconsistentState)
            }
        } else {
            self.reset(error: error.localizedDescription)
        }
    }

}
