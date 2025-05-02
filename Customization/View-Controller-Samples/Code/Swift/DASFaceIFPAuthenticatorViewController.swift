//
//  DASFaceIFPAuthenticatorViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2024 Daon. All rights reserved.
//

import DaonAuthenticatorSDK
import DaonAuthenticatorFaceIFP


// View Controller for collecting a face image.
//
// Demonstrates default and custom view options. Set useCustomView = false to use standard capture mode.

@objc(DASFaceIFPAuthenticatorViewController)
class DASFaceIFPAuthenticatorViewController: DASAuthenticatorViewControllerBase {
            
    // A DASFaceCapture object used for capturing a photo for registering or authenticating
    var capture: DASFaceCapture?
    
    var useCustomView: Bool = true
    var isRegistration: Bool = false
    
    override init(nibName nibNameOrNil: String?,
                  bundle nibBundleOrNil: Bundle?,
                  context authenticatorContext: DASAuthenticatorContext?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: authenticatorContext)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localise("Face Screen - Title")  + " (Swift)"
    }
    
    @IBAction func startCaptureButtonClicked(_ sender: UIButton?) {
                
        isRegistration = singleAuthenticatorContext?.isRegistration ?? true;
    
        // Configure the face controller
        capture = DASFaceCapture(context: singleAuthenticatorContext)
        capture?.delegate = self
        capture?.deviceUprightDetection = true
        capture?.medicalMaskDetection = false
        capture?.allowConfirmation = isRegistration ? true : false
        capture?.quality = .low
        capture?.captureMode = .manual
        capture?.messages = !useCustomView
        capture?.style = .fullScreen
                        
        capture?.enhancedDetection = isRegistration ? true : false
        capture?.assessmentDelay = 0.75
                        
        capture?.start(controller: self)
    }
            
    /*!
     Called when the authenticator UI should be reset due to the view controller being removed from its parent.
     Typically this happens when transitioning between authenticators in a multi-authenticator policy. Resetting ensures
     that when transitioning back to the authenticator that it is back in its default prepared state.
     */
    override func authenticatorShouldReset() {
        if capture == nil {
            super.authenticatorShouldReset()
        } else {
            capture?.cancel() {
                super.authenticatorShouldReset()
            }
        }
    }
    
    /*!
     Cancels the UI by stopping capture and telling the context which will dismiss the UI.
     */
    override func authenticatorIsCancelling() {
        
        if capture == nil {
            super.authenticatorIsCancelling()
        } else {
            capture?.cancel() {
                super.authenticatorIsCancelling()
            }
        }
    }
        
    func vibrate() {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }

    // CUSTOM VIEW
    //
    // Custom view support code.
    //
    // Not used if custom view is not set.
    //
    // - customView()
    // - createButton()
    // - startButtonClicked()
    // - confirmButtonClicked()
    // - retryButtonClicked()
    //
    // Implements the DASFaceCaptureDelegate
        
    // Custom view buttons and labels
    
    var startButton: UIButton? = nil
    var retryButton: UIButton? = nil
    var confirmButton: UIButton? = nil
    var statusLabel: UILabel? = nil
    var oval: OvalMaskView = OvalMaskView()
    var busyIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    
    private func createCustomView(frame:CGRect) -> UIView {
        let customViewContainer = UIView()
        customViewContainer.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        customViewContainer.frame = frame
        
        oval.frame = CGRect(x: 0, y: 0, width: frame.width, height:frame.height)
                
        let buttonXOffset = 20
        let buttonYOffset = 40
        let buttonY = Int(frame.height * 3/4) + buttonYOffset
        
        let buttonHeight = 40
        let buttonWidth = 140
        
        statusLabel = UILabel()
        statusLabel?.text = "Get ready to capture your face"
        statusLabel?.frame = CGRect(x: 0, y: buttonY, width: Int(view.frame.width) - 100, height: 60)
        statusLabel?.center.x = view.center.x
        statusLabel?.textAlignment = .center
        statusLabel?.numberOfLines = 3
        statusLabel?.lineBreakMode = .byWordWrapping
        statusLabel?.textColor = .white
        statusLabel?.layer.masksToBounds = true
        statusLabel?.layer.cornerRadius = 8
        statusLabel?.backgroundColor = .black.withAlphaComponent(0.5)
        statusLabel?.isHidden = true
        
        startButton = createButton(title: "Start",
                                   color: .systemBlue,
                                   x: 0,
                                   y: buttonY,
                                   width: buttonWidth,
                                   height: buttonHeight)
        startButton?.center.x = view.center.x
        
        startButton?.addTarget(self, action: #selector(startButtonClicked), for: .touchUpInside)
        
        retryButton = createButton(title: "Retry",
                                   color: .systemBlue,
                                   x: Int(view.frame.minX) + buttonXOffset,
                                   y: buttonY,
                                   width: buttonWidth,
                                   height: buttonHeight)
        retryButton?.addTarget(self, action: #selector(retryButtonClicked), for: .touchUpInside)
        retryButton?.isHidden = true

        confirmButton = createButton(title: "Confirm",
                                     color: .systemGreen,
                                     x: Int(view.frame.maxX) - buttonWidth - buttonXOffset,
                                     y: buttonY,
                                     width: buttonWidth,
                                     height: buttonHeight)
        confirmButton?.addTarget(self, action: #selector(confirmButtonClicked), for: .touchUpInside)
        confirmButton?.isHidden = true

        let cancelButton = createButton(title: "X",
                                     color: .systemGray,
                                     x: Int(view.frame.minX) + buttonXOffset,
                                     y: buttonHeight,
                                     width: buttonWidth/2,
                                     height: buttonHeight)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)

        
        busyIndicator.center = view.center
        busyIndicator.frame.origin.y = CGFloat(buttonY)
        busyIndicator.color = .white
        
        customViewContainer.addSubview(oval)
        customViewContainer.addSubview(busyIndicator)
        customViewContainer.addSubview(statusLabel!)
        customViewContainer.addSubview(startButton!)
        customViewContainer.addSubview(retryButton!)
        customViewContainer.addSubview(confirmButton!)
        customViewContainer.addSubview(cancelButton)
        
        return customViewContainer
    }
    
    private func createButton(title: String, color: UIColor, x: Int, y: Int, width: Int, height: Int) -> UIButton {
        
        let button = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        
        return button
    }
        
    @IBAction func startButtonClicked() {
        debugPrint("Custom start button was clicked.")
                
        startButton?.isHidden = true
        statusLabel?.isHidden = false
        
        capture?.reset()
    }
    
    @IBAction func confirmButtonClicked() {
        debugPrint("Custom confirm button was clicked.")
                                    
        self.busyIndicator.startAnimating()
        self.retryButton?.isHidden = true
        self.confirmButton?.isHidden = true
        
        capture?.submit()
    }
    
    @IBAction func retryButtonClicked() {
        debugPrint("Custom retry button was clicked.")
                
        self.retryButton?.isHidden = true
        self.confirmButton?.isHidden = true
        self.statusLabel?.isHidden = false
        self.statusLabel?.text = "Get ready to capture your face again"
        
        capture?.reset()
    }
    
    @IBAction func cancelButtonClicked() {
        debugPrint("Custom cancel button was clicked.")
        
        capture?.cancel() {
            self.singleAuthenticatorContext?.completeCapture(error: .cancelled)
        }
    }
}

final class OvalMaskView: UIView {

    private var ovalLayer = CAShapeLayer()
    private let tagMask = 409
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 20, y: 100, width: rect.width - 2 * 20, height: rect.height * 0.55))
        ovalLayer = CAShapeLayer()
        ovalLayer.path = ovalPath.cgPath
        ovalLayer.fillColor = UIColor.clear.cgColor
        ovalLayer.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
        ovalLayer.lineWidth = 5
                
        layer.addSublayer(ovalLayer)

        let outOvalPath = UIBezierPath(rect: bounds)
        outOvalPath.append(ovalPath)
        let outOvalLayer = CAShapeLayer()
        outOvalLayer.path = outOvalPath.cgPath
        outOvalLayer.fillRule = .evenOdd

        // Set mask and background color and opacity
        let maskView = UIView(frame: bounds)
        maskView.tag = tagMask
        maskView.layer.mask = outOvalLayer
        maskView.backgroundColor = .clear.withAlphaComponent(0.4)
        
        // Only add once
        if viewWithTag(tagMask) == nil {
            addSubview(maskView)
        }
    }
}


extension DASFaceIFPAuthenticatorViewController : DASFaceCaptureDelegate {
    
    func faceCaptureDidUpdate(message: String, image: UIImage?) {
        // Custom view status messages
        statusLabel?.text = message
    }
    
    func faceCaptureDidFail(error: Error) {
        
        // Capture failed and retry is allowed.
        DispatchQueue.main.async {
            self.busyIndicator.isHidden = true
            self.statusLabel?.isHidden = false
            self.statusLabel?.text = error.localizedDescription
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.statusLabel?.isHidden = true
                self.retryButton?.isHidden = false
            }
        }
    }
    
    // Custom view and overlay
    func faceCaptureShouldUseView(frame: CGRect) -> UIView? {
        if useCustomView {
            return createCustomView(frame: frame)
        }
        
        return nil
    }
    
    func faceCaptureWillSubmit(image: UIImage) -> Bool {
        vibrate()
        
        // Custom view button logic
        // Only show retry and confirm for registration
        if isRegistration {
            self.retryButton?.isHidden = false
            self.confirmButton?.isHidden = false
        } else {
            self.busyIndicator.isHidden = false
            self.busyIndicator.startAnimating()
        }
        
        self.statusLabel?.isHidden = true
        
        // Don't auto submit the image if using a custom view
        if useCustomView {
            // If it is a registration don't submit the image unless the confirm button is pressed, if
            // authentication just submit the image.
            return !isRegistration
        }
        
        return true
    }
}

