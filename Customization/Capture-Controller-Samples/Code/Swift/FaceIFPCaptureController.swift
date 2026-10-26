//
//  FaceIFPCaptureController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-26 Daon. All rights reserved.
//

import DaonFIDOSDK
import DaonAuthenticatorFaceIFP

class FaceIFPCaptureController: DASCaptureControllerProtocol {

    private let context : DASAuthenticatorContext
    private var capture : DASFaceCapture?
    private let backgroundCancellation = FaceIFPBackgroundCancellation()

    init(context: DASAuthenticatorContext) {
        //
        // Hold onto the DASAuthenticatorContext object as we will need it to complete capture later. We will also
        // provide it to the FaceViewController.
        //
        self.context = context
    }

    func execute() {

        DispatchQueue.main.async { [self] in
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
            self.capture?.trueDepthAssessment = false
            self.capture?.trueDepthRequireIdentityMatch = false

            guard let hostViewController = DASUtils.determineHostViewController() else {
                self.context.completeCapture(error: .authenticatorNoHostViewController)
                return
            }

            self.backgroundCancellation.start(isEnabled: self.shouldCancelOnBackgrounding()) { [weak self] completion in
                self?.capture?.cancel(completion: completion)
            } completion: { [weak self] in
                self?.context.cancelCapture()
            }

            self.capture?.start(controller: hostViewController) { [weak self] in
                self?.backgroundCancellation.stop()
            }
        }
    }

    private func shouldCancelOnBackgrounding() -> Bool {
        guard let backgroundExtension = context.authenticatorInfo?.authenticatorExtensions[KDASExtensionAuthenticatorCancelOnBackground] as? String else {
            return true
        }

        return backgroundExtension.lowercased() != KDASExtensionValueFalse
    }
}

final class FaceIFPBackgroundCancellation {

    private let notificationCenter: NotificationCenter
    private var observer: NSObjectProtocol?
    private var cancellationStarted = false

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }

    deinit {
        stop()
    }

    func start(isEnabled: Bool,
               cancel: @escaping (@escaping () -> Void) -> Void,
               completion: @escaping () -> Void) {
        stop()
        cancellationStarted = false

        guard isEnabled else {
            return
        }

        observer = notificationCenter.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                  object: nil,
                                                  queue: .main) { [weak self] _ in
            guard let self, !self.cancellationStarted else {
                return
            }

            self.cancellationStarted = true
            self.stop()
            cancel(completion)
        }
    }

    func stop() {
        if let observer {
            notificationCenter.removeObserver(observer)
            self.observer = nil
        }
    }
}
