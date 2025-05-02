//
//  FaceViewController.swift
//  DaonAuthenticatorSDK
//
//  Created by Neil Johnston on 3/25/19.
//  Copyright © 2019-21 Daon. All rights reserved.
//

import AVFoundation

import DaonAuthenticatorFace
import DaonAuthenticatorSDK
import DaonFaceSDK

// Closures
typealias FaceCompletionHandler = (DASAuthenticatorError?) -> Void

 
/*!
 @brief View Controller for collecting a face image.
 */
class FaceViewController: DASFaceAuthenticatorViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK:- Completion

    /*!
     @brief The block to be executed when capture has completed, failed, or been cancelled.
     */
    private let completionHandler: FaceCompletionHandler

    
    /*!
     @group AV Foundation
     */
    
    /*!
     @brief The custom video capture session.
     */
    private var captureSession: AVCaptureSession?
    
    /*!
     @brief The AVCaptureVideoPreviewLayer which will be added on top of videoPhotoPreviewView.
     */
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    /*!
     @brief The video output object. We must make sure to nil out its sample buffer delegate before stopping.
     */
    private unowned var videoOutput: AVCaptureVideoDataOutput?
    
    
    // MARK:- Initialization
    
    /*!
     @brief Instantiates a new @link FaceViewController @/link object.
     @param nibNameOrNil Passed through to designated initializer
     @param nibBundleOrNil Passed through to designated initializer
     @param authenticatorContext The @link DASAuthenticatorContext @/link object with which this view controller can register or authenticate face.
     @param completionHandler The @link FaceCompletionHandler @/link block to be executed on completion, cancellation or failure.
     @return A new @link FaceViewController @/link object.
     */
    init!(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!, context authenticatorContext: DASAuthenticatorContext, completionHandler: @escaping FaceCompletionHandler) {
        
        self.completionHandler = completionHandler
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: authenticatorContext)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- From DASFaceAuthenticatorViewController - Controller
    
    override func configureFaceController() {
        
        faceController = DASFaceAuthenticatorFactory.createFaceController(context:singleAuthenticatorContext,
                                                                          preview:nil,
                                                                          delegate:self)
    }

    /*!
    @brief Handle the authenticator completing with an error.
    */
    override func completeCapture(error: DASAuthenticatorError) {
        stopVideo()
        completionHandler(DASAuthenticatorError(rawValue: error.rawValue))
    }

    
    // MARK:- From DASAuthenticatorViewControllerBase - Actions

    /*!
     @brief Cancels the UI by stopping frame analysis and telling the context which will dismiss the UI.
     */
    override func authenticatorIsCancelling() {
        dismissVisibleAlert()
        stopVideo()
        faceController?.cancel()
        completionHandler(.cancelled);
    }
    
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localise("Face Screen - Title") + " (Swift CC Sample)"
    }
    
    
    /*!
     @brief Called when the view has appeared. We use this to start the face controller.
     @param animated YES if view appearance will be animated.
     */
    override func viewDidAppear(_ animated: Bool) {
        self.startVideo()
        
        super.viewDidAppear(animated) // Takes care of starting the faceController
    }

    
    // MARK:- Video - Configuration
    
    private func startVideo() {
        if captureSession == nil {
            // Daon Face SDK
            //
            // Get an AVFoundation capture session and set the buffer delegate. The default is using
            // YUV and preset AVCaptureSessionPreset640x480
            captureSession = DFSAudioVideo.captureSession(with: self)
            
            // Hold on to the video output for cleanup in stopVideo
            if captureSession!.outputs.count > 0 {
                videoOutput = (captureSession!.outputs[0] as! AVCaptureVideoDataOutput)
            }
            
            DispatchQueue.global(qos: .background).async { [self] in
                captureSession!.startRunning()
            }

            //
            // Setup preview layer
            //
            let previewLayerRect                        = self.videoLivefeedView.bounds
            previewLayer                                = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer!.videoGravity                  = .resizeAspectFill
            previewLayer!.bounds                        = previewLayerRect
            previewLayer!.position                      = CGPoint(x: previewLayerRect.midX, y: previewLayerRect.midY)
                        
            if #available(iOS 17.0, *) {
                previewLayer!.connection?.videoRotationAngle = DASUtils.videoRotationAngle()
            } else {
                previewLayer!.connection?.videoOrientation = DASUtils.videoOrientation()
            }
            
            self.videoLivefeedView.layer.addSublayer(previewLayer!)
            
            // Configure UI
            if self.singleAuthenticatorContext!.isRegistration {
                update(state:.collectingForRegistration)
            } else {
                update(state:.collectingForAuthentication)
            }
        }
    }

    private func stopVideo() {
        if captureSession != nil {
            videoOutput?.setSampleBufferDelegate(nil, queue: nil)
    
            captureSession!.stopRunning()
            captureSession = nil
    
            previewLayer?.removeFromSuperlayer()
            previewLayer = nil
        }
    }
    
    
    // MARK:- Video - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        autoreleasepool {
            if (CMSampleBufferDataIsReady(sampleBuffer)) {
                let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                faceController?.process(frame: pixelBuffer)
            }
        }
    }
    
    /*!
     @brief Handles the notification from the face controller that the controllers current task has completed successfully.
     */
    override func controllerDidCompleteSuccessfully() {
        if (!self.isCancelling) {
            
            hideCancelButton()
            update(state:.success)
            
            stopVideo()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.captureCompleted = true
                self.completionHandler(nil)
            })
        }
    }
    
}
