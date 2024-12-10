//
//  DASNonUIAuthenticatorPlaceholderViewController.swift
//  DaonAuthenticatorSDK
//
//  Created by Neil Johnston on 1/22/20.
//  Copyright © 2020 Daon. All rights reserved.
//

import DaonAuthenticatorSDK

/*!
 @brief A placeholder View Controller for registering or authenticating with authenticators that don't typically have a UI (Silent, OTP).
 */
@objc(DASNonUIAuthenticatorPlaceholderViewController)
class DASNonUIAuthenticatorPlaceholderViewController: DASAuthenticatorViewControllerBase
{
    // MARK:- IBOutlets
    
    /*!
     @brief A UIButton which completes capture with this factor.
     */
    @IBOutlet var continueButton: UIButton!
    
    
    // MARK:- Initialisation
    
    /*!
     @brief Instantiates a new @link DASNonUIAuthenticatorPlaceholderViewController @/link object.
     @param nibNameOrNil Passed through to designated initializer
     @param nibBundleOrNil Passed through to designated initializer
     @param authenticatorContext The @link DASAuthenticatorContext @/link object with which this view controller can register or authenticate.
     @return A new @link DASNonUIAuthenticatorPlaceholderViewController @/link object.
     */
    override init!(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, context authenticatorContext: DASAuthenticatorContext?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: authenticatorContext)

        // Set the tabBarItem in case this view controller is being displayed in a UITabBarController
        if (self.singleAuthenticatorContext?.authenticatorInfo?.authenticatorFactor == .offlineOTP)
        {
            self.tabBarItem.title = localise("Offline OTP Screen - Title")
        }
        else
        {
            self.tabBarItem.title = localise("Silent Screen - Title")
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- View Lifecycle
    
    /*!
     @brief Called after view has been loaded. Sets up the initial UI state.
     */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if (self.singleAuthenticatorContext?.authenticatorInfo?.authenticatorFactor == .offlineOTP)
        {
            self.title = localise("Offline OTP Screen - Title") + " (Swift)"
        }
        else
        {
            self.title = localise("Silent Screen - Title") + " (Swift)"
        }
        
        if (self.singleAuthenticatorContext!.isRegistration)
        {
            self.continueButton.setTitle(localise("Register"), for: .normal)
        }
        else
        {
            self.continueButton.setTitle(localise("Authenticate"), for: .normal)
        }
    }

    
    // MARK:- Actions
    
    /*!
     @brief IBAction called when @link continueButton @/link is pressed.
     */
    @IBAction func continueButtonPressed(_ sender: UIButton?)
    {
        self.singleAuthenticatorContext?.completeCapture()
    }
}
