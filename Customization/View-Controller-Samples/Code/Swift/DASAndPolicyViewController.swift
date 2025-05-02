//
//  DASAndPolicyViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import DaonAuthenticatorSDK
import DaonCryptoSDK

/*!
 @brief View Controller for controlling the sequential display of a set of authenticators.
 */
@objc(DASAndPolicyViewController)
class DASAndPolicyViewController: UINavigationController, UINavigationBarDelegate, UIAdaptivePresentationControllerDelegate {
    // MARK:- Context
    
    /*!
     @brief A @link DASMultiAuthenticatorContext @/link object used for accessing registration/authentication information and services.
     */
    fileprivate let multiAuthenticatorContext : DASMultiAuthenticatorContext
    
    
    // MARK:- State
    
    /*!
     @brief An array containing information (@link DASAuthenticatorInfo @/link) on each authenticator which much be registered or authenticated.
     */
    fileprivate var authenticators = [DASAuthenticatorInfo]()
    
    /*!
     @brief Keeps track of the authenticator (in @link authenticators @/link) we are currently presenting.
     */
    fileprivate var currentAuthenticatorIndex = 0
    
    /*!
     @brief Flag for whether this view controller should be dismissed automatically if the application is backgrounded.
     */
    fileprivate var shouldCancelOnBackgrounding = false
    
    
    // MARK:- UI
    
    /*!
     @brief The view controller associated with the current authenticator.
     */
    fileprivate var currentCaptureViewController: UIViewController?
    
    /*!
     @brief The UIButton for cancelling this view controller.
     */
    fileprivate var cancelButton: UIBarButtonItem?
    
    
    // MARK:- Initialisation
    
    /*!
     @brief Instantiates a new instance of the @link DASAndPolicyViewController @/link class.
     @param nibNameOrNil Passed through to designated initializer
     @param nibBundleOrNil Passed through to designated initializer
     @param ctx The @link DASMultiAuthenticatorContext @/link object with which the view controller can gain access to the set of expected authenticators for registration / authentication.
     @param cancelOnBackgrounding Flag for whether this view controller should be dismissed automatically if the application is backgrounded.
     @return A new @link DASAndPolicyViewController @/link instance ready to display.
     */
    @objc init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, context: DASMultiAuthenticatorContext!, cancelOnBackgrounding: Bool) {
        self.multiAuthenticatorContext      = context
        self.shouldCancelOnBackgrounding    = cancelOnBackgrounding
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- View Lifecycle
    
    /*!
     @brief Called after view has been loaded. Sets up the initial UI state, and determines the set of authenticators we will be using and displays the first one.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notifications
        //
        // If specified, register to be alerted when the app is backgrounded, so that we can cancel the current authenticator.
        //
        if shouldCancelOnBackgrounding {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleEnteredBackground(_:)),
                                                   name: UIApplication.didEnterBackgroundNotification,
                                                   object: nil)
        }
        
        // Navigation Bar
        self.navigationBar.isTranslucent = false
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(authenticatorIsCancelling))
        
        // Register for the iOS 13 pull-down to dismiss gesture event.
        if let navController = self.navigationController {
            if let presController = navController.presentationController {
                presController.delegate = self
            }
        }
        
        // Determine the set of authenticators we will need to run through..
        if let authGroups = self.multiAuthenticatorContext.requestedAuthenticatorGroups() {
            // For AND Policies, there can only be one group of authenticators which are
            // moved through sequentially. If there isn't, complete with an error.
            if authGroups.count == 1 {
                authenticators = authGroups[0]
                
                // Get the first authenticator, and set it as
                // the navigation stack.
                if authenticators.count > 0 {
                    let authenticatorInfo = authenticators[0]
                    
                    if let vcs = viewControllerForFactor(authenticatorInfo.authenticatorFactor) {
                        self.viewControllers = [vcs]
                        
                        multiAuthenticatorContext.activeFactor = authenticatorInfo.authenticatorFactor
                        
                        showCancelButton()
                    } else {
                        IXALog.logError(withTag: KDASDefaultLoggingTag, message:"No authenticator view controller available.")
                        self.multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
                    }
                } else {
                    IXALog.logError(withTag: KDASDefaultLoggingTag, message:"No view controllers created for multi authentication!")
                    self.multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
                }
            } else {
                IXALog.logError(withTag: KDASDefaultLoggingTag, message:"Multiple authenticator groups returned for AND policy. Expected only 1.")
                self.multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
            }
        } else {
            IXALog.logError(withTag: KDASDefaultLoggingTag, message:"No authenticator groups returned for AND policy.")
            self.multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
        }
    }
    
    /*!
     @brief Called when there will be a view controller transition. We use this check if we are being removed from a parent, so that we can cleanly reset by passing this message onto the @link currentCaptureViewController @/link.
     @param parent The view controller being transitioned to.
     */
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {
            authenticatorShouldReset()
        }
    }
    
    /*!
     @brief Handles an app backgrounded event.
     @param note The notification object.
     */
    @objc func handleEnteredBackground(_ notification:Notification) {
        NotificationCenter.default.removeObserver(self)
        authenticatorIsCancelling()
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
    
    
    // MARK:- From DASAuthenticatorViewControllerBase - Actions
    
    /*!
     @brief Called when the authenticator UI should be reset due to the view controller being removed from its parent. Typically this
     happens when transitioning between authenticators in a multi-authenticator policy. Resetting ensures that when transitioning
     back to the authenticator that it is back in its default prepared state.
     */
    func authenticatorShouldReset() {
        if let currentVc = currentCaptureViewController {
            currentVc.willMove(toParent: nil)
        }
    }
    
    /*!
     @brief Cancels the authenticator by telling the context which will dismiss the UI.
     */
    @objc func authenticatorIsCancelling() {
        multiAuthenticatorContext.cancelCapture()
    }
    
    
    // MARK:- Authenticators
    
    /*!
     @brief Uses the @link context @/link to get a UIViewController for a specific factor.
     @param factor The @link DASAuthenticatorFactor @/link to get a UIViewController for.
     @return The requested UIViewController.
     */
    fileprivate func viewControllerForFactor(_ factor: DASAuthenticatorFactor) -> UIViewController? {
        //
        // Ask the context to give us the correct view controller for the selected authenticator factor.
        // As part of this call, we give the context two blocks:
        // 1) The completion handler block in which we automatically move to the next authenticator once this one is complete.
        // 2) The failure handler block in which we dismiss the current authenticator with an error.
        //
        
        return self.multiAuthenticatorContext.authenticatorViewController(for: factor, completionHandler: { (completionFactor) in self.moveToNextAuthenticatorFrom(completionFactor)
        }) { (completionFactor, error) in
            self.multiAuthenticatorContext.completeCaptureWithError(error)
        }
    }
    
    /*!
     @brief Begins registration or authentication with the next authenticator in the list.
     @param factor The @link DASAuthenticatorFactor @/link that was just completed successfully.
     */
    fileprivate func moveToNextAuthenticatorFrom(_ factor: DASAuthenticatorFactor) {
        // Find the factor in the set of authenticators, then see if there is another
        // authenticator after it.
        //
        // If there isn't, then we can complete capture successfully.
        //
        // If there is, reconfigure, get the UIViewController for that authenticator and present it to the user
        // by adding it to the navigation stack.
        //
        for i in 0..<authenticators.count {
            let info = authenticators[i]
            
            if info.authenticatorFactor == factor {
                if i+1 == authenticators.count {
                    // Everything has been authenticated!
                    self.multiAuthenticatorContext.completeCapture()
                } else {
                    // There's another authenticator to pass...
                    let authenticatorInfo = authenticators[i+1]
                    
                    currentCaptureViewController = viewControllerForFactor(authenticatorInfo.authenticatorFactor)
                    
                    multiAuthenticatorContext.activeFactor = authenticatorInfo.authenticatorFactor
                    
                    currentAuthenticatorIndex += 1
                    
                    pushViewController(currentCaptureViewController!, animated: true)
                    break
                }
            }
        }
    }
    
    
    // MARK:- UI
    
    /*!
     @brief Displays the @link cancelButton @/link in the left of the navigation bar.
     */
    fileprivate func showCancelButton() {
        if let topVC = self.topViewController {
            topVC.navigationItem.leftBarButtonItem = cancelButton
            topVC.navigationItem.setHidesBackButton(false, animated: true)
        }
        
        // Allow swipe down to dismiss when the cancel button is visible
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = false
        }
    }
    
    
    // MARK:- UINavigationBarDelegate
    
    /*!
     @brief Notifies us that an item was popped off the navigation bar. i.e. The user moved backwards through the stack.
     @param navigationBar The navigation bar.
     @param item The item that was popped off the navigation bar.
     */
    func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {
        // Tell the context we have moved backwards in the navigation stack to a previous
        // authenticator.
        
        currentAuthenticatorIndex -= 1
        
        multiAuthenticatorContext.activeFactor = authenticators[currentAuthenticatorIndex].authenticatorFactor
        
        // Reset the context for the factor we are going back to as it will be in a completed state.
        multiAuthenticatorContext.resetActiveFactorContext()
        
        // If there is only one view controller left on the stack, show the cancel button.
        if self.viewControllers.count == 1 {
            showCancelButton()
        }
    }
    
    
    // MARK:- Memory Management
    
    /*!
     @brief Handle this object being deallocated. Here we perform any cleanup.
     */
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
