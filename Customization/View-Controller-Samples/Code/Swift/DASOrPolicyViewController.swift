//
//  DASOrPolicyViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import DaonAuthenticatorSDK
import DaonCryptoSDK

/*!
@brief View Controller for allowing the user to chose one authenticator from a set of authenticators.
*/
@objc(DASOrPolicyViewController)
class DASOrPolicyViewController: DASAuthenticatorViewControllerBase {
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

    
    // MARK:- IBOutlets
    
    /*!
     @brief The UISegmentedControl that displays the name of all available (according to the server policy) authenticators.
     */
    @IBOutlet var segmentedControl: UISegmentedControl!
 
    
    // MARK:- Initialisation
    
    /*!
     @brief Instantiates a new instance of the @link DASOrPolicyViewController @/link class.
     @param nibNameOrNil Passed through to designated initializer
     @param nibBundleOrNil Passed through to designated initializer
     @param multiAuthenticatorContext The @link DASMultiAuthenticatorContext @/link object with which the view controller can gain access to the set of available authenticators for registration / authentication.
     @return A new @link DASOrPolicyViewController @/link instance ready to display.
     */
    @objc init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, multiAuthenticatorContext: DASMultiAuthenticatorContext!) {
        self.multiAuthenticatorContext = multiAuthenticatorContext

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- View lifecycle
    
    /*!
     @brief Called after view has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "OR Policy (Swift)"
        
        // Dark mode support
        if DASUtils.isDarkModeEnabled() {
            self.view.backgroundColor = .black
        }
    }
    
    /*!
    @brief Called when the view is about to be made visible. Sets up the initial UI state, and determines the set of authenticators we will be using and displays the first one.
    @param animated YES if view appearance will be animated.
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let horizontalBuffer : CGFloat = 16.0

        // Segmented Control
        if authenticators.count == 0 {// Only run once
            if let authGroups = self.multiAuthenticatorContext.requestedAuthenticatorGroups() {
                
                // For OR Policies, there can only be one group of authenticators
                // from which the user selects. If there isn't, complete with an error.
                if authGroups.count == 1 {
                    authenticators = authGroups[0]

                    // We need at least two authenticators in order to display an OR, If there isn't, complete with an error.
                    if authenticators.count >= 2 {
                        // Populate the segmented control with the authenticator icons
                        self.segmentedControl.removeAllSegments()

                        // Try to keep the segments square, but if there isn't enough space, reduce them.
                        var segWidth                    = self.segmentedControl.frame.size.height
                        let segmentWidths               = segWidth * CGFloat(authenticators.count)
                        let availableHorizontalSpace    = self.view.frame.size.width - horizontalBuffer

                        if segmentWidths > availableHorizontalSpace {
                            let excess = segmentWidths - availableHorizontalSpace
                            var excessPerSegment = excess / CGFloat(authenticators.count)

                            if excessPerSegment < 1 {
                                excessPerSegment = 1
                            }

                            segWidth = segWidth - excessPerSegment
                        }

                        let imageBuffer : CGFloat = 10

                        for i in 0..<authenticators.count {
                            let authenticatorInfo = authenticators[i]

                            let image = DASUtils.resize(authenticatorInfo.authenticatorIcon,
                            to: CGSize(width: segWidth - imageBuffer, height: segWidth - imageBuffer))

                            self.segmentedControl.insertSegment(with: image, at: i, animated: false)
                            self.segmentedControl.setWidth(segWidth, forSegmentAt: i)
                        }

                        // Find and select the first authenticator that is:
                        // - Unlocked
                        // - Not invalidated
                        //
                        var selectedAuthenticator = false

                        for i in 0..<authenticators.count {
                            let firstAuthenticator = authenticators[i]

                            if firstAuthenticator.authenticatorLockState == .unlocked && !firstAuthenticator.authenticatorInvalidated {
                                // Found an unlocked and not invalidated authenticator. Update the segmented control for it's index,
                                // create it's view controller and set it as the current child view controller.
                                currentAuthenticatorIndex = i
                                selectedAuthenticator = true
                                self.segmentedControl.selectedSegmentIndex = currentAuthenticatorIndex

                                if let firstViewController = viewControllerForFactor(firstAuthenticator.authenticatorFactor) {
                                    multiAuthenticatorContext.activeFactor = firstAuthenticator.authenticatorFactor
                                    addChildAuthenticatorViewController(firstViewController)
                                }
                                break
                            }
                        }

                        if !selectedAuthenticator {
                            IXALog.logError(withTag: KDASDefaultLoggingTag, message:"Could not determine which authenticator to show first!")
                            self.multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
                        }
                    } else {
                        IXALog.logError(withTag: KDASDefaultLoggingTag, message:"Need at least 2 view controllers created for multi authentication with OR policy!")
                        self.multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
                    }
                } else {
                    IXALog.logError(withTag: KDASDefaultLoggingTag, message:"Multiple authenticator groups returned for OR policy. Expected only 1.")
                    self.multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
                }
            } else {
                IXALog.logError(withTag: KDASDefaultLoggingTag, message: "No authenticator groups provided")
                self.multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isCancelling {
            multiAuthenticatorContext.cancelCapture()
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    // MARK:- From DASAuthenticatorViewControllerBase - Actions
    
    /*!
     @brief Called when the authenticator UI should be reset due to the view controller being removed from its parent. Typically this
     happens when transitioning between authenticators in a multi-authenticator policy. Resetting ensures that when transitioning
     back to the authenticator that it is back in its default prepared state.
     */
    override func authenticatorShouldReset() {
        super.authenticatorShouldReset()
        removeCurrentChildAuthenticatorViewController()
    }
    
    /*!
     @brief Cancels the authenticator by telling the context which will dismiss the UI.
     */
    override func authenticatorIsCancelling() {
        isCancelling = true
        removeCurrentChildAuthenticatorViewController()
    }
    
    
    // MARK:- IBActions
    
    /*!
     @brief IBAction called when the user changes the selected segment on the @link segmentedControl @/link.
     When the user makes this selection, we switch to the factor associated with that segment.
     @param sender The control that sent this event.
     */
    @IBAction func segmentedControlValueChanged(_ sender: UIButton?) {
        //
        // Determine which authenticator was selected, then check to make sure it is not
        // locked or invalidated.
        //
        
        let selectedAuthenticator = authenticators[self.segmentedControl.selectedSegmentIndex]
        
        if selectedAuthenticator.authenticatorLockState == .unlocked && !selectedAuthenticator.authenticatorInvalidated {
            // Authenticator is NOT locked or invalidated, create its UIViewController
            // then set it as the child view controller in our container.
            currentAuthenticatorIndex = self.segmentedControl.selectedSegmentIndex
            
            if let nextViewController = viewControllerForFactor(selectedAuthenticator.authenticatorFactor) {
                multiAuthenticatorContext.activeFactor = selectedAuthenticator.authenticatorFactor
                addChildAuthenticatorViewController(nextViewController)
            }
        } else {
            // Selected authenticator is either locked or invalidated, so show an error and don't allow the switch.
            
            self.segmentedControl.selectedSegmentIndex = currentAuthenticatorIndex
            
            var error: Error?
            
            if selectedAuthenticator.authenticatorInvalidated {
                error = self.multiAuthenticatorContext.error(forCode: .localAuthenticationEnrollmentHasChanged)
            } else {
                error = self.multiAuthenticatorContext.error(forCode: .cantSwitchToAuthenticatorTempLocked)
                
                if selectedAuthenticator.authenticatorLockState == .permanent {
                    error = self.multiAuthenticatorContext.error(forCode: .cantSwitchToAuthenticatorPermLocked)
                }
            }
            
            showAlert(withTitle: self.multiAuthenticatorContext.localise("Alert - Title - Error"),
                      message: error?.localizedDescription ?? "UNKNOWN")
        }
    }

    
    // MARK:- Authenticator switching
    
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
        
        return self.multiAuthenticatorContext.authenticatorViewController(for: factor, completionHandler: { (completionFactor) in
            self.multiAuthenticatorContext.completeCapture()
        }) { (completionFactor, error) in
            self.removeCurrentChildAuthenticatorViewController()
            self.multiAuthenticatorContext.completeCaptureWithError(error)
        }
    }
    
}
