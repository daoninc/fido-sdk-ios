//
//  VoiceView.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2025 Daon. All rights reserved.
//

import SwiftUI

import DaonAuthenticatorVoice
@preconcurrency import DaonAuthenticatorSDK


#Preview {
    if #available(iOS 15.0, *) {
        VoiceView(context: nil)
    } else {
        // Fallback on earlier versions
    }
}


/// SwiftUI view for face registration and authentication.
@available(iOS 15.0, *)
struct VoiceView: View {
    
    @ObservedObject private var model : VoiceViewModel
    
    
    /// Initializes a new instance of the @link PasscodeView @/link struct.
    /// - Parameter context: The @link DASAuthenticatorContext @/link object with which the view can gain access to a passcode controller for registration and authentication.
    init(context: DASAuthenticatorContext?) {
        self.model = VoiceViewModel(context: context)
    }

    var body: some View {
        VStack {
            Group {
                if model.state == .processing {
                    ProgressView()
                } else if model.state == .success {
                    Image("Passed-Indicator")
                        .resizable()
                        .frame(width: 32, height: 32, alignment: .center)
                } else {
                    Text("Please speak the following text clearly, in a normal voice:")
                    Text(model.utterance()).italic()
                        .padding(50)
                        .multilineTextAlignment(.center)
                        .background(.gray.opacity(0.1))
                    Text(model.info)
                        .bold()
                    Button(model.state == .start ? "START" :"STOP") {
                        self.model.toggleRecording()
                    }
                    .foregroundColor(model.state == .start ? .blue : .red)
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            
            Spacer()
            
        }
        .navigationBarTitle(model.title)
        .onAppear() {
            self.model.updateProgress()
        }
        .alert(model.error, isPresented: $model.alert) {
            Button("OK", role: .cancel) {}
        }
    }
    
}

@MainActor
class VoiceViewModel : NSObject, ObservableObject, @MainActor DASVoiceControllerDelegate {
    
    private var context: DASAuthenticatorContext?
    
    enum CaptureState {
        case start
        case recording
        case processing
        case success
    }

    @Published var state : CaptureState = .start
    @Published var info : String = ""
    @Published var error : String = ""
    @Published var alert : Bool = false
    
    private let expectedVoiceSamples = 3
    private var voiceSampleIndex = 1
    private var voiceSamples = [Data]()
    
    private var _controller: DASVoiceControllerProtocol?
    
    private var controller : DASVoiceControllerProtocol {
        
        if context != nil {
            if _controller == nil {
                _controller =  DASVoiceAuthenticatorFactory.createVoiceController(context: context, delegate: self)
            }
        }
        return _controller!
    }
    
    var title : String {
        guard let context = context else {
            return "Voice (SwiftUI)"
        }
            
       return "\(context.authenticatorInfo?.authenticatorName ?? "Voice") (SwiftUI)"
    }
    
    init(context: DASAuthenticatorContext?) {
        self.context = context
    }
    
    func utterance() -> String {
        guard context != nil else {
            return "The phrase that the user should utter is not defined"
        }
        
        return controller.defaultUtterance() ?? "NA"
    }
    
    func toggleRecording() {
        
        guard let context = context else {
            return
        }
        
        if controller.isRecording() {
            controller.stopRecording() { [self] error, data in
                Task { @MainActor in
                    
                    state = .start
                    
                    if let sample = data {
                        if context.isRegistration {
                            voiceSamples.append(sample)
                            
                            if voiceSampleIndex < expectedVoiceSamples {
                                
                                voiceSampleIndex += 1
                                updateProgress()
                            } else {
                                state = .processing
                                controller.register(samples: self.voiceSamples)
                            }
                        } else {
                            state = .processing
                            controller.authenticate(sample: sample)
                        }
                    } else {
                        fail(error: error ?? DASUtils.error(forError: .voiceUnknownError))
                    }
                }
            }
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
                Task { @MainActor in
                    if granted {
                        self.state = .recording
                        self.controller.startRecording()
                    } else {
                        self.fail(error: DASUtils.error(forError: .noMicrophonePermission))
                    }
                }
            }
        }
    }

    func updateProgress() {
        if let context = context {
            if context.isRegistration {
                self.info = String(format: "%d of %d", self.voiceSampleIndex, self.expectedVoiceSamples)
            }
        }
    }
    
    func controllerDidCompleteSuccessfully() {
        self.state = .success
        
        // Pause a bit
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            self.context?.completeCapture()
        }
    }
    
    func controllerDidFail(error: any Error, score: NSNumber?) {
        
        guard let context = context else {
            fail(error: error)
            return
        }
        
        if context.isRegistration {
            fail(error: error)
        } else {
            if shouldUpdateAttempt(error: error) {
                failAndUpdateAttempts(error: error, score: score)
            } else {
                fail(error: error)
            }
        }
    }
    
    func fail(error: Error) {
        let authenticatorError = DASAuthenticatorError(rawValue: error._code)
        if authenticatorError == .serverUserLockout
            || authenticatorError == .serverTooManyAttempts
            || authenticatorError == .serverVoiceTooManyAttempts
            || authenticatorError == .authenticatorTooManyAttemptsTempLocked
            || authenticatorError == .authenticatorTooManyAttemptsPermLocked {
            
            context?.completeCapture(error: authenticatorError!)
        } else {
           reset(error: error, recaptureAllSamples:voiceSampleIndex >= expectedVoiceSamples)
        }
    }

    func shouldUpdateAttempt(error: Error) -> Bool {
        
        guard let context = context else {
            return false
        }
        
        if context.isADoSRequired {
            return false
        }
        
        return true
    }

    func failAndUpdateAttempts(error: Error, score: NSNumber?) {
        
        guard let context = context else {
            return
        }
        
        context.incrementFailures(error: error._code, score: score) { lockError in
            Task { @MainActor in
                if let e = lockError  {
                    // We are locked
                    self.fail(error: e)
                } else {
                    // We are not locked, so check for too many attempts
                    if context.haveEnoughFailedAttemptsForWarning() {
                        self.fail(error: DASUtils.error(forError: DASAuthenticatorError.voiceMultipleFailedAttempts))
                    } else {
                        self.fail(error: error)
                    }
                }
            }
        }
    }
    
    func reset(error: Error?, recaptureAllSamples: Bool) {
        
        if recaptureAllSamples {
            self.controller.cancel()
            self.voiceSampleIndex = 1
            self.voiceSamples.removeAll()
            self.updateProgress()
        }
                            
        self.state = .start
        
        if let e = error {
            self.alert = true
            self.error = e.localizedDescription
        }
    }
}
