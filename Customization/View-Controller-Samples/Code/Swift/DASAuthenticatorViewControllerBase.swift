//
//  DASAuthenticatorViewControllerBase.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import UIKit
import AVFoundation
import DaonAuthenticatorSDK

// Typedalias for simplicity

/*!
 @typedef DASAlertDismissalHandler
 @brief Block that is used to notify a calling object that an alert has been dismissed.
 */
typealias DASAlertDismissalHandler = () -> Void

/*!
 @brief Base view controller for all authenticator view controllers.
 */
@objc(DASAuthenticatorViewControllerBase)
class DASAuthenticatorViewControllerBase: UIViewController, AVAudioPlayerDelegate, UIAdaptivePresentationControllerDelegate {
    // MARK:- Controls
    
    /*!
     @brief The UIButton for cancelling this view controller.
     */
    fileprivate var cancelButton : UIBarButtonItem?

    /*!
     @brief Keeps track of the current alert in case we need to dismiss it if the UI is bein torn down.
     */
     var currentAlertController : UIAlertController?
    
    
    // MARK:- AV Foundation
    
    /*!
     @brief AVAudioPlayer for playing camera capture sounds as needed.
     */
    fileprivate var audioPlayer : AVAudioPlayer?

    /*!
     @brief A UIView that can be used to contain a child view controller.
     */
    @IBOutlet var containerView : UIView?
    
    
    // MARK:- Properties

    /*!
     @brief The @link DASAuthenticatorContext @/link object with which a custom view controller can register or authenticate.
     */
    weak var singleAuthenticatorContext : DASAuthenticatorContext?
    
    /*!
     @brief A flag used to keep track of whether the authenticator has finished capture.
     */
    var captureCompleted = false
    
    /*!
     @brief A flag used to keep track of whether the authenticator has been / is being cancelled. We do this so that we can take account of this if any asynchronous calls complete after cancellation.
     */
    var isCancelling = false
    
    /*!
     @brief The current child view controller that may be being presented when in multi-authenticator mode.
     */
    var currentChildViewController: UIViewController?
    
    
    // MARK:- Instantiation
    
    /*!
     @brief Instantiates a new @link DASAuthenticatorViewControllerBase @/link object.
     @param nibNameOrNil Passed through to designated initializer
     @param nibBundleOrNil Passed through to designated initializer
     @param authenticatorContext The @link DASAuthenticatorContext @/link object with which a custom view controller can register or authenticate.
     @return A new @link DASAuthenticatorViewControllerBase @/link object.
     */
    @objc init!(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, context authenticatorContext: DASAuthenticatorContext?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.singleAuthenticatorContext = authenticatorContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- View Lifecycle
    
    /*!
     @brief Called after view has been loaded. Sets up the initial UI state.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: On iOS 15 the navigation bar item is transparent
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            navigationController?.navigationBar.standardAppearance = appearance;
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }

        // Navigation Bar
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(authenticatorIsCancelling))

        // Notifications
        //
        // If specified, register to be alerted when the app is backgrounded, so that we can cancel the current authenticator.
        //
        if shouldCancelOnBackgrounding() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleEnteredBackground(note:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
        
        // Register for the iOS 13 pull-down to dismiss gesture event.
        if let navController = self.navigationController {
            if let presController = navController.presentationController {
                presController.delegate = self
            }
        }
        
        // Dark Mode support
        if #available(iOS 13.0, *) {
            if DASUtils.isDarkModeEnabled() {
                self.navigationController?.navigationBar.barTintColor = .secondarySystemBackground
                self.navigationController?.navigationBar.isTranslucent = false
            }
        }
    }
    
    /*!
     @brief Called when the view has appeared. We use this to add a cancel button to the left of the navigation bar.
     @param animated YES if view appearance will be animated.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showCancelButton()
    }
    
    /*!
     @brief Returns a Boolean value indicating whether the view controller's contents should auto rotate.
     @return NO. By default we don't support rotation.
     */
    override var shouldAutorotate: Bool{
        return false
    }
    
    /*!
     @brief Returns all of the interface orientations that the view controller supports.
     @return UIInterfaceOrientationMaskPortrait. By default we only support portrait.
     */
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    /*!
     @brief Returns the interface orientation to use when presenting the view controller.
     @return UIInterfaceOrientationPortrait. By default we only support portrait.
     */
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    /*!
     @brief Called when there will be a view controller transition. We use this check if we are being removed from a parent, so that we can cleanly reset.
     @param parent The view controller being transitioned to.
     */
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {
            authenticatorShouldReset()
        }
    }
    
    
    // MARK:- UIAdaptivePresentationControllerDelegate

    /*!
    @brief Called on the delegate when the user has taken action to dismiss the presentation successfully, after all animations are finished.
     This is not called if the presentation is dismissed programmatically.
    @param presentationController The current UIPresentationController
    */
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // Handle the iOS 13 swipe to dismiss gesture.
        self.authenticatorIsCancelling()
    }
    
    
    // MARK:- Backgrounding
    
    /*!
     @brief Determines whether we should cancel the authenticator if we detect that we are being backgrounded.
     @return YES, unless overridden by extension.
     */
    func shouldCancelOnBackgrounding() -> Bool {
        var shouldCancel = true
    
        if let authExtensions = self.singleAuthenticatorContext?.authenticatorInfo?.authenticatorExtensions {
            if let backgroundExtension = authExtensions[KDASExtensionAuthenticatorCancelOnBackground] as? String {
                if backgroundExtension.lowercased() == KDASExtensionValueFalse {
                    shouldCancel = false
                }
            }
        }
        
        return shouldCancel
    }
    
    /*!
     @brief Handles an app backgrounded event.
     @param note The notification object.
     */
    @objc func handleEnteredBackground(note: NSNotification) {
        NotificationCenter.default.removeObserver(self)
        authenticatorIsCancelling()
    }
    
    
    // MARK:- Actions
    
    /*!
     @brief Called when the authenticator UI should be reset due to the view controller being removed from its parent.
     @discussion Typically this happens when transitioning between authenticators in a multi-authenticator policy. Resetting ensures that
     when transitioning back to the authenticator that it is back in its default prepared state. Override in sub-classes in order to perform any
     authenticator specific reset functionality.
    */
    @objc func authenticatorShouldReset() {
        dismissVisibleAlert()
    }
    
    /*!
     @brief Called when the authenticator UI will be cancelled due to a drag down to dismiss event (iOS 13) or backgrounding (if configured).
     @discussion The @link DASAuthenticatorViewControllerBase @/link class will take care of telling the context which will dismiss the UI
     if applicable. Override in sub-classes in order to perform any authenticator specific cancellation, then call super.authenticatorIsCancelling().
    */
    @objc func authenticatorIsCancelling() {
        dismissVisibleAlert()
        singleAuthenticatorContext?.cancelCapture()
    }
    
    
    // MARK:- Localisation
    
    /*!
     @brief Searches through all available bundles and returns the localisation for a specified key.
     @param key The localisation key. See the DAS-Localizable.strings file for all potential keys and values.
     @return The localized NSString.
     */
    func localise(_ key: String) -> String {
        return DASUtils.localise(key)
    }
    
    
    // MARK:- Animation
    
    /*!
     @brief Performs a specified animation transition on a UIView.
     @param viewToAnimate The UIView upon which the animation transition will be performed.
     @param transition The UIViewAnimationTransition to be performed.
     */
    func startAnimation(on viewToAnimate: UIView, transition:UIView.AnimationTransition) {
        var animationOptions = UIView.AnimationOptions(rawValue: 0)
        
        switch transition {
            case .curlUp:           animationOptions = .transitionCurlUp
            case .curlDown:         animationOptions = .transitionCurlDown
            case .flipFromLeft:     animationOptions = .transitionFlipFromLeft
            case .flipFromRight:    animationOptions = .transitionFlipFromRight
            default:                break
        }
        
        UIView.transition(with: viewToAnimate,
                          duration: 0.7,
                          options: animationOptions,
                          animations: nil,
                          completion: nil)
    }
    

    // MARK:- UI
    
    /*!
     @brief Adds a cancel button to the left of the current UINavigationItem.
     */
    func showCancelButton() {
        let navItem = (self.navigationController == self.parent) ? self.navigationItem : self.parent?.navigationItem
        
        if self.navigationController?.viewControllers.count == 1 {
            navItem?.leftBarButtonItem = cancelButton
        }
        
        navItem?.setHidesBackButton(false, animated: false)
        
        // Enable the tab bar if one is present...
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
        
        // Allow swipe down to dismiss when the cancel button is visible
        if #available(iOS 13.0, *) {
            self.parent?.isModalInPresentation = false
        }
    }
    
    /*!
     @brief Removes the cancel button from the left of the current UINavigationItem.
     */
    func hideCancelButton() {
        let navItem = (self.navigationController == self.parent) ? self.navigationItem : self.parent?.navigationItem
        
        if self.navigationController?.viewControllers.count == 1 {
            navItem?.leftBarButtonItem = nil;
        }
        
        navItem?.setHidesBackButton(true, animated: false)
        
        // Disable the tab bar if one is present...
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        // Disable swipe down to dismiss when the cancel button is hidden
        if #available(iOS 13.0, *) {
            self.parent?.isModalInPresentation = true
        }
    }
    

    // MARK:- Alerts
    
    /*!
     @brief Displays a UIAlertController on screen with a message and an "OK" button.
     @param title The title of the UIAlertController.
     @param message The message text to display in the UIAlertController.
     */
    func showAlert(withTitle: String, message: String) {
        let okButtonText = localise("Button - Title - OK")
        
        currentAlertController = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        currentAlertController!.addAction(UIAlertAction(title: okButtonText, style: .default, handler: nil))
     
        self.present(currentAlertController!, animated: false, completion: nil)
    }
    
    /*!
     @brief Displays a UIAlertController on screen with a message and an "OK" button, with a completion handler.
     @param title The title of the UIAlertController.
     @param message The message text to display in the UIAlertController.
     @param handler A @link DASAlertDismissalHandler @/link block used to notify the caller when the user has pressed the "OK" button.
     */
    func showAlert(withTitle: String, message: String, onDismissal: @escaping DASAlertDismissalHandler) {
        let okButtonText = localise("Button - Title - OK")
        
        currentAlertController = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        currentAlertController!.addAction(UIAlertAction(title: okButtonText, style: .default, handler: { (action) in onDismissal() }))

        currentAlertController!.popoverPresentationController?.sourceView = self.view
            
        self.present(currentAlertController!, animated: true, completion: nil)
    }
    
    /*!
    @brief Forces dismissal of any alert currently presented from showAlertWithTitle: & showAlertWithTitle:message:onDismissal:
    */
    func dismissVisibleAlert() {
        if let visibleAlert = currentAlertController {
            visibleAlert.dismiss(animated: false) {
                self.currentAlertController = nil
            }
        }
    }
    
    /*!
     @brief Animates a message into the current UIViewController from the bottom of the screen for a fixed time before dismissing.
     @param presentationView The UIView upon which to display the message.
     @param message The text to display.
     @param isError If YES, the text background will be [UIColor redColor] otherwise [UIColor colorWithRed:159.0/255.0 green:203.0/255.0 blue:109.0/255.0 alpha:1].
     */
    func showToast(in presentationView: UIView, message: String, isError: Bool) {
        // Determine the toast height
        let toastFont   = UIFont.systemFont(ofSize: 16)
        let attributes  = [NSAttributedString.Key.font: toastFont]
        let size        = CGSize(width: self.view.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let rect        = message.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        let textHeight  = rect.size.height + 10 // The above only calculates the height of the text. But the UILabel has padding so we need to take account of that also...
        
        var homeBarPadding : CGFloat = 0
        
        // Take account of iPhone Home bar
        if #available(iOS 11.0, *) {
            homeBarPadding = self.view.safeAreaInsets.bottom
        }
        
        let toastHeight = ((textHeight < 50) ? 50 : textHeight) + homeBarPadding
        
        // Setup the toast label
        let startingY                   = presentationView.frame.size.height
        let toastFrame                  = CGRect(x: 0, y: startingY, width: presentationView.frame.size.width, height: CGFloat(toastHeight))
        let toastLabel                  = UILabel(frame: toastFrame)
        toastLabel.text                 = message
        toastLabel.textAlignment        = NSTextAlignment.center
        toastLabel.numberOfLines        = 0
        toastLabel.textColor            = .white
        
        if isError {
            toastLabel.backgroundColor = .red
        } else {
            toastLabel.backgroundColor = UIColor(red: 159.0/255.0, green: 203.0/255.0, blue: 109.0/255.0, alpha: 1)
        }
        
        self.view.addSubview(toastLabel)

        // Perform the animation
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                            toastLabel.frame = CGRect(x: toastFrame.origin.x,
                                                      y: toastFrame.origin.y - toastFrame.size.height,
                                                      width: toastFrame.size.width,
                                                      height: toastFrame.size.height)
                        },
                       completion: { (done: Bool) in
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                                UIView.animate(withDuration: 0.5,
                                               animations: {
                                    toastLabel.frame = toastFrame
                                },
                                               completion: { (done: Bool) in
                                    toastLabel.removeFromSuperview()
                                })
                            }
                        })

    }
    

    // MARK:- Errors
    
    /*!
     @brief Returns the localized error message for a specific @link DASAuthenticatorError @/link type.
     @param error The @link DASAuthenticatorError @/link error.
     @return An NSString with the localized error message for the @link DASAuthenticatorError @/link type.
     */
    func string(forError error: DASAuthenticatorError) -> String {
        return DASUtils.string(forError: error)
    }
    
    /*!
     @brief Creates a new NSError object for an @link DASAuthenticatorError @/link error with the default localized error message.
     @param error The @link DASAuthenticatorError @/link error.
     @return An NSError with the @link DASAuthenticatorError @/link error and localized message.
     */
    func error(forError error: DASAuthenticatorError) -> Error! {
        return DASUtils.error(forError: error)
    }
    
    
    // MARK:- Images
    
    /*!
     @brief Searches through all available bundles and returns the first image with a specified name.
     @param imageName The name of the image to find.
     @return The loaded image.
     */
    func loadImageNamed(_ imageName: String) -> UIImage? {
        return DASUtils.loadImageNamed(imageName)
    }
    
    /*!
     @brief Rotates an image to a specific orientation.
     @param image The image to rotate.
     @param orientation The requested image orientation.
     @return The rotated image.
     */
    func rotateImage(_ image: UIImage, to: UIImage.Orientation) -> UIImage? {
        return DASUtils.rotateImage(image, to: to)
    }
    
    
    // MARK:- Audio
    
    /*!
     @brief Vibrates the device and plays the DASCameraShutter.caf file if it finds it in one of the applications bundles.
     */
    func playCameraSoundAndVibrate() {
        // The iPhone has two volume settings:
        // 1) The ringer
        // 2) Alerts & Media
        // Using AVAudioPlayer will use #2 so will ignore mute button
        
        if audioPlayer == nil {
            if let filePath = DASUtils.getPathInAllBundles(forResource: "DASCameraShutter", ofType: "caf") {
                let audioURL = URL(fileURLWithPath: filePath)
                
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(.ambient)
                    try audioSession.setActive(false, options: AVAudioSession.SetActiveOptions())
                    
                    audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                
                    if audioPlayer != nil {
                        audioPlayer!.volume     = 0.3
                        audioPlayer!.delegate   = self
                    
                        audioPlayer!.play()
                    }
                } catch _ {
                    // Ignore error
                }
                
            }
        }
        
        // Vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    
    // MARK:- From AVAudioPlayerDelegate
    
    /*!
     @brief Called by the AVAudioPlayer created in @link playCameraSoundAndVibrate @/link when the audio has completed playback. Here we perform cleanup.
     @param player The AVAudioPlayer that was playing back audio.
     @param flag Success or failure flag.
     */
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop() // In theory we stopped playing, but we still need to call stop or the following line may cause an error.
        audioPlayer = nil
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        } catch _ {
            // Ignore error
        }
    }
    
    
    // MARK:- Child View Controllers
    
    /*!
     @brief Switches to a new child view controller
     @param childViewController The UIViewController we will be setting as the child.
     */
    func addChildAuthenticatorViewController(_ childViewController: UIViewController?) {
        if let childVC = childViewController {
            removeCurrentChildAuthenticatorViewController()
            
            currentChildViewController = childVC

            addChild(currentChildViewController!)
            self.view.addSubview(currentChildViewController!.view)
            DASUtils.addConstrainEqualConstraint(to: self.view, containerView: self.containerView, childView: currentChildViewController!.view)
            currentChildViewController?.didMove(toParent: self)
            
            self.title = currentChildViewController?.title
        }
    }
    
    /*!
     @brief Removes the current child view controller (The UIViewController for the currently visible authenticator
     in multi-authenticator mode). During this process we call willMoveToParentViewController with nil which the child view controller knows is a
     signal to perform any cancellation / cleanup.
     */
    func removeCurrentChildAuthenticatorViewController() {
        if let currentChildVC = currentChildViewController {
            currentChildVC.willMove(toParent: nil) // Ensures the view controller will do any cancellation / cleanup
            currentChildVC.removeFromParent()
            currentChildVC.view.removeFromSuperview()
        }
        
        currentChildViewController = nil
        
        self.title = nil
    }
}
