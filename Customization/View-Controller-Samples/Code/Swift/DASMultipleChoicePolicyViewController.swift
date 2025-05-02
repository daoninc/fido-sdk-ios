//
//  DASMultipleChoicePolicyViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import DaonAuthenticatorSDK
import DaonCryptoSDK

// Typedalias for simplicity

/*!
 @typedef DASAuthenticatorGroup
 @brief Array of @link DASAuthenticatorInfo @/link objects.
 */
typealias DASAuthenticatorGroup = [DASAuthenticatorInfo]

/*!
 @brief View Controller for controlling the display of a set of authenticators in paged ui mode.
 */
@objc(DASMultipleChoicePolicyViewController)
class DASMultipleChoicePolicyViewController: DASAuthenticatorViewControllerBase {
    // MARK:- Constants

    /*!
     @brief The duration for the authenticator group switching animation.
     */
    fileprivate let KAnimationDuration = 0.5
    
    
    // MARK:- Context
    
    /*!
     @brief A @link DASMultiAuthenticatorContext @/link object used for accessing registration/authentication information and services.
     */
    fileprivate let multiAuthenticatorContext : DASMultiAuthenticatorContext
    
    
    // MARK:- State
    
    /*!
     @brief An NSArray containing information (@link DASAuthenticatorGroup @/link) on each authenticator group which will be displayed to the user.
     */
    fileprivate var authenticatorGroups = [DASAuthenticatorGroup]()
    
    /*!
     @brief The current group whose set of authenticator we are displaying for user selection.
     */
    fileprivate var currentGroup : DASAuthenticatorGroup?
    
    /*!
     @brief The set of @link DASAuthenticatorFactor @/link factors the user has already completed.
     */
    fileprivate var completedFactors : Set<DASAuthenticatorFactor> = []
    
    /*!
     @brief Keeps track of the authenticator (in @link authenticators @/link) we are currently presenting.
     */
    fileprivate var currentAuthenticatorIndex = 0
    
    /*!
     @brief Flag to ensure that the code to display the first authenticator of the first authenticator group only runs once.
     */
    fileprivate var runOnce = false
    

    // MARK:- IBOutlets
    
    /*!
     @brief The UISegmentedControl that displays the name of all available (according to the server policy) authenticators.
     */
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    
    // MARK:- Initialisation
    
    /*!
     @brief Instantiates a new instance of the @link DASMultipleChoicePolicyViewController @/link class.
     @param nibNameOrNil Passed through to designated initializer
     @param nibBundleOrNil Passed through to designated initializer
     @param ctx The @link DASMultiAuthenticatorContext @/link object with which the view controller can gain access to the set of available authenticators for authentication.
     @return A new @link DASMultipleChoicePolicyViewController @/link instance ready to display.
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
     @brief Called after view has been loaded. Sets up the initial UI state.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Multiple Choice Policy (Swift)"
        
        // Dark mode support
        if DASUtils.isDarkModeEnabled() {
            self.view.backgroundColor = .black
        }
        
        // Segmented control - Hide until the UI is all setup in viewWillAppear
        self.segmentedControl.alpha = 0
    }
    
    /*!
     @brief Called when the view is about to be made visible. Using the @link runOnce @/link flag to execute only once, we determine the
     first group of authenticators and display them.
     @param animated YES if view appearance will be animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure this code only runs once.
        if !runOnce {
            runOnce = true
            
            // Determine the first group to show, and setup the UI.
            authenticatorGroups = self.multiAuthenticatorContext.requestedAuthenticatorGroups()
            
            if authenticatorGroups.count > 0 {
                // DASAuthenticatorFactorUnknown == "Show the first group".
                nextGroup(completedFactor: .unknown, animated: false)
            } else {
                IXALog.logError(withTag: KDASDefaultLoggingTag, message:"No Multiple authenticator groups returned for Multiple Choice policy.")
                self.multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
            }
        }
    }
    
    
    // MARK:- From DASAuthenticatorViewControllerBase - Actions
    
    /*!
     @brief Called when the authenticator UI should be reset due to the view controller being removed from its parent. Typically this
     happens when transitioning between authenticators in a multi-authenticator policy. Resetting ensures that when transitioning
     back to the authenticator that it is back in its default prepared state.
     */
    override func authenticatorShouldReset() {
        removeCurrentChildAuthenticatorViewController()
    }
    
    /*!
     @brief Cancels the authenticator by telling the context which will dismiss the UI.
     */
    override func authenticatorIsCancelling() {
        removeCurrentChildAuthenticatorViewController()
        multiAuthenticatorContext.cancelCapture()
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
        
        let selectedAuthenticator = currentGroup![self.segmentedControl.selectedSegmentIndex]
        
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
    
    
    // MARK:- Groups
    
    /*!
     @brief Attempt to move to the next group of authenticators.
     @param completedFactor Which factor was just completed. DASAuthenticatorFactorUnknown if we just started.
     @param animated YES if we should have an animated transition to the group. We typically only set this to NO if
     this is the first time we called it so we want the group to be fully transitioned to when the view appears.
     */
    fileprivate func nextGroup(completedFactor: DASAuthenticatorFactor, animated: Bool) {
        //
        // Determine the currentGroup to display
        //
        
        if currentGroup == nil {
            // Just starting, so determine all unique authenticators
            currentGroup = getAllRemainingAuthenticatorsForGroups(authenticatorGroups)
        } else {
            // We have a currentGroup, so add the passed in factor to the list of completed factors.
            completedFactors.insert(completedFactor)
            
            // Check if we have authenticated with enough authenticators to match
            // one of the authenticator groups..
            let matchingGroup = getMatchingAuthenticatorGroup()
            
            if matchingGroup != nil {
                // We are done!!
                currentGroup = nil
                self.multiAuthenticatorContext.completeCapture()
            } else {
                // We are not done. So see which group the completed factor belongs to..
                // If it belongs to one group, show the remaining factors from that group
                // If it belongs to multiple groups, show the remaining factors from all those groups
                let parentGroups = getGroupsContainingFactor(completedFactor)
                
                if parentGroups.count == 0 {
                    IXALog.logError(withTag: KDASDefaultLoggingTag, message:"Completed factor has no parent!")
                    self.multiAuthenticatorContext.completeCaptureWithError(.authenticatorInconsistentState)
                } else if parentGroups.count == 1 {
                    // Completed factor is only part of one group, set the currentGroup to whatever is remaining from that group
                    currentGroup = getRemainingAuthenticatorsForGroup(parentGroups[0])
                } else {
                    // Completed factor is part of multiple groups, set the currentGroup to whatever is remaining from those groups
                    currentGroup = getAllRemainingAuthenticatorsForGroups(parentGroups)
                }
            }
        }
        
        //
        // Display the currentGroup for collection
        //
        if currentGroup != nil {
            resetForCurrentGroupWithAnimation(animated)
        }
    }
    
    /*!
     @brief Get all authenticators from a set of authenticator groups that have not yet been completed (registered or authenticated).
     @param groups The set of groups to check.
     @return The set of authenticators in groups that have not yet been completed (registered or authenticated).
     */
    fileprivate func getAllRemainingAuthenticatorsForGroups(_ groups: [DASAuthenticatorGroup]) -> DASAuthenticatorGroup? {
        var remainingAuthenticators : [DASAuthenticatorFactor:DASAuthenticatorInfo]? = [DASAuthenticatorFactor:DASAuthenticatorInfo]()
        
        for group in groups {
            if let remainingGroup = getRemainingAuthenticatorsForGroup(group) {
                for authInfo in remainingGroup {
                    remainingAuthenticators![authInfo.authenticatorFactor] = authInfo
                }
            }
        }
        
        if remainingAuthenticators!.count == 0 {
            return nil
        } else {
            return Array(remainingAuthenticators!.values)
        }
    }
    
    /*!
     @brief Get all authenticators from an authenticator group that have not yet been completed (registered or authenticated).
     @param group The group to check.
     @return The set of authenticators in group that have not yet been completed (registered or authenticated).
     */
    fileprivate func getRemainingAuthenticatorsForGroup(_ group: DASAuthenticatorGroup) -> DASAuthenticatorGroup? {
        var remainingAuthenticators : [DASAuthenticatorFactor:DASAuthenticatorInfo]? = [DASAuthenticatorFactor:DASAuthenticatorInfo]()
        
        for authInfo in group {
            if !completedFactors.contains(authInfo.authenticatorFactor) {
                remainingAuthenticators![authInfo.authenticatorFactor] = authInfo
            }
        }
        
        if remainingAuthenticators!.count == 0 {
            return nil
        } else {
            return Array(remainingAuthenticators!.values)
        }
    }

    /*!
     @brief Get all authenticator authenticator groups that contain a specific @link DASAuthenticatorFactor @/link.
     @param factor The @link DASAuthenticatorFactor @/link to check for.
     @return The set of authenticator groups that contain the specified factor.
     */
    fileprivate func getGroupsContainingFactor(_ factor: DASAuthenticatorFactor) -> [DASAuthenticatorGroup] {
        var groups = [DASAuthenticatorGroup]()
        
        for authenticatorGroup in authenticatorGroups {
            for authInfo in authenticatorGroup {
                if factor == authInfo.authenticatorFactor {
                    if !groups.contains(authenticatorGroup) {
                        groups.append(authenticatorGroup)
                    }
                }
            }
        }
        
        return groups
    }
    
    /*!
     @brief Determine if there are any authenticator groups for which we have completed (registered or authenticated) all
     their authenticators. Return the first group where this is so.
     @return The matching authenticator group or nil.
     */
    fileprivate func getMatchingAuthenticatorGroup() -> DASAuthenticatorGroup? {
        var matchingGroup : DASAuthenticatorGroup?
        
        for group in authenticatorGroups {
            var completedAuthenticators = 0
            
            for authInfo in group {
                if completedFactors.contains(authInfo.authenticatorFactor) {
                    completedAuthenticators += 1
                }
            }
            
            if completedAuthenticators >= group.count {
                matchingGroup = group
                break
            }
        }
        
        return matchingGroup
    }
    
    /*!
     @brief Display the authenticators from @link currentGroup @/link and select the first one that isn't
     unlocked or invalidated.
     @return An error if no authenticator can be selected. DASAuthenticatorErrorCancelled if there are no issues.
     */
    fileprivate func selectFirstUnlockedAuthenticatorForCurrentGroup() -> DASAuthenticatorError {
        var error : DASAuthenticatorError = .authenticatorInconsistentState
        
        // First clear the segmented control and insert the segments for all the
        // authenticators in currentGroup.
        self.segmentedControl.removeAllSegments()
        
        let segWidth    = self.segmentedControl.frame.size.height // Keep the segments square
        let imageBuffer : CGFloat = 10
        
        for i in 0..<currentGroup!.count {
            let authenticatorInfo = currentGroup![i]
            
            let image = DASUtils.resize(authenticatorInfo.authenticatorIcon,
                                        to: CGSize(width: segWidth - imageBuffer, height: segWidth - imageBuffer))
            
            self.segmentedControl.insertSegment(with: image, at: i, animated: false)
            self.segmentedControl.setWidth(segWidth, forSegmentAt: i)
        }
        
        // Find the first unlocked && not invalidated authenticator, and select it.
        for i in 0..<currentGroup!.count {
            let firstAuthenticator = currentGroup![i]
            
            if firstAuthenticator.authenticatorLockState == .unlocked && !firstAuthenticator.authenticatorInvalidated {
                // Found an unlocked and not invalidated authenticator. Update the segmented control for it's index,
                // create its view controller and set it as the current child view controller.
                currentAuthenticatorIndex = i
                self.segmentedControl.selectedSegmentIndex = currentAuthenticatorIndex
                currentChildViewController?.view.alpha = 0
                
                if let firstViewController = viewControllerForFactor(firstAuthenticator.authenticatorFactor) {
                    multiAuthenticatorContext.activeFactor = firstAuthenticator.authenticatorFactor
                    addChildAuthenticatorViewController(firstViewController)
                }
                
                error = .cancelled; // Cancelled == No Issues
                break;
            } else if currentGroup!.count == 1 {
                // There is only one authenticator in this group, and it's either locked or invalidated.
                // So all we can do is cancel capture with an error.
                if firstAuthenticator.authenticatorInvalidated {
                    error = .localAuthenticationEnrollmentHasChanged
                } else if firstAuthenticator.authenticatorLockState == .temporary {
                    error = .cannotContinueRemainingAuthIsTempLocked
                } else {
                    error = .cannotContinueRemainingAuthIsPermLocked
                }
                
                if error != .authenticatorInconsistentState {
                    // Cancelling with an error, change the active factor to the one that
                    // we are unable to switch to.
                    multiAuthenticatorContext.activeFactor = firstAuthenticator.authenticatorFactor;
                }
                break;
            }
        }
        
        return error;
    }
    
    /*!
     @brief Display the current group of authenticators.
     @param animated YES if we should have an animated transition to the group. We typically only set this to NO if
     this is the first time we called it so we want the group to be fully transitioned to when the view appears.
     */
    fileprivate func resetForCurrentGroupWithAnimation(_ animated: Bool) {
        let error = selectFirstUnlockedAuthenticatorForCurrentGroup()
        
        let completionClosure = {
            if error == .cancelled { // Cancelled == No Issues
                self.segmentedControl.alpha                 = 1
                self.currentChildViewController?.view.alpha = 1
            } else {
                IXALog.logError(withTag: KDASDefaultLoggingTag, message: "Could not determine which authenticator to show first!")
                self.multiAuthenticatorContext.completeCaptureWithError(error)
            }
        }
        
        if animated {
            UIView.animate(withDuration: KAnimationDuration,
                           animations: {
                                            self.segmentedControl.alpha                 = 0
                                            self.currentChildViewController?.view.alpha = 0
                                        },
                           completion: { (finished) in completionClosure() })
        } else {
            completionClosure()
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
        // 1) The completion handler block in which we automatically move to the next authenticator group once this authenticator is complete.
        // 2) The failure handler block in which we dismiss the current authenticator with an error.
        //
        
        return self.multiAuthenticatorContext.authenticatorViewController(for: factor,
                                                        completionHandler: { (completionFactor) in self.nextGroup(completedFactor: completionFactor, animated: true) },
                                                        failureHandler: { (completionFactor, error) in
                                                                            self.removeCurrentChildAuthenticatorViewController()
                                                                            self.multiAuthenticatorContext.completeCaptureWithError(error)
                                                                        })
    }
}
