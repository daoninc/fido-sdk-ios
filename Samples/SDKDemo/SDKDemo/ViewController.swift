//
//  ViewController.swift
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import UIKit
import SwiftUI
@preconcurrency import DaonFIDOSDK

class ViewController: UIViewController, @MainActor IXUAFDelegate {

    var fido : IXUAF?
    var username : String = "email"
    
    var extensions = ["com.daon.sdk.ados.enabled" : "true",
                      "com.daon.sdk.keys.access.biometry" : "true",
                      "com.daon.sdk.exclude.invalidAuthenticators" : "true",
                      "com.daon.sdk.operation.wait.timeout" : "10"] 
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var optionSwiftUI: Bool = false
    var optionInjectionAttackDetection: Bool = true
    var optionConfirmationOTP: Bool = false
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveNotification),
                                               name:Notification.Name("Notification"),
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if DASUtils.isDarkModeEnabled() {
            activityIndicator.color = .white
        }
                
        let serviceType = Settings.shared.getString(key: Settings.Key.serviceType)
        
        let url = Settings.shared.getString(key: serviceType == Settings.REST
                                                           ? Settings.Key.restUrl
                                                           : Settings.Key.rpsaUrl)
        
        self.title = "IdentityX FIDO (\(serviceType))"
        
        username = Settings.shared.getString(key: serviceType == Settings.REST
                                             ? Settings.Key.restAccount
                                             : Settings.Key.rpsaAccount)
        
        if url.contains("acme.com") {
            
            performSegue(withIdentifier: "Settings", sender: self)
            
        } else if username == "email" {
            
            show(title: "Username", message: "Please provide a username in Settings"){ (action) in
                self.performSegue(withIdentifier: "Settings", sender: self)
            }
            
        } else {
            busy(on: true)
            
            // If the license is provided as an extension uncomment this line and set the license string.
//                extensions["com.daon.sdk.license"] = #"license string"#
            
            if serviceType == Settings.RPSA {
                fido = IXUAF(service:IXUAFRPSAService(url: url))
                
                let account = [kIXUAFServiceParameterAccountNameFirst : "first",
                               kIXUAFServiceParameterAccountNameLast : "last",
                               kIXUAFServiceParameterAccountPassword : "password",
                    kIXUAFServiceParameterAccountRegistrationRequest : false] as [String : Any]
                
                fido?.requestServiceAccess(username: username, parameters: account) { [weak self] (token, error) in
                    Task { @MainActor in
                        if let e = error {
                            self?.show(error: e)
                        } else {
                            if let extensions = self?.extensions {
                                self?.initialize(parameters: extensions)
                            }
                        }
                    }
                }
            } else {
                let restUsername = Settings.shared.getString(key: Settings.Key.restUsername)
                let restPassword = Settings.shared.getString(key: Settings.Key.restPassword)
                let application = Settings.shared.getString(key: Settings.Key.restApplicationID)
                
                // Store server credentials username and password in key chain
                IXAKeychain.setKey(restUsername, value: restPassword)
                
                fido = IXUAF(service:IXUAFRESTService(url: url, application: application, username:restUsername))
                initialize(parameters: self.extensions)
            }
            
            IXUAFLocator.sharedInstance().locate()
        }
    }

    func initialize(parameters: [String : String]) {
        fido?.logging = true
        fido?.delegate = self
        
        fido?.initialize(parameters: extensions) { [weak self] (code, warnings) in
            
            Task { @MainActor in
                self?.busy(on: false)
                
                if code == .licenseExpired {
                    self?.show(title: "Initialize failed", message: "License expired")
                } else if code == .licenseNotVerified {
                    self?.show(title: "Initialize failed", message: "License not verified")
                } else if code == .licenseNoAuthenticators {
                    self?.show(title: "Initialize failed", message: "No licensed authenticators")
                } else {
                    if code != .noError {
                        self?.show(title: "Initialize", message: "\(code.rawValue)")
                    }
                    
                    self?.checkRemoteNotification()
                }

                self?.show(warnings: warnings)
            }
        }
    }
    
    func show(warnings: [NSNumber]) {
        
        var message = ""
        
        for warning in warnings {
            let code = IXUAFWarningCode(rawValue: warning.intValue)
            switch code {
            case .deviceDebug:
                message = "\(message)\nApplication is running in debug mode"
            case .deviceSimulator:
                message = "\(message)\nApplication is running in a simulator"
            case .deviceSecurityDisabled:
                message = "\(message)\nDevice passcode/Touch ID/Face ID is not enabled"
            case .deviceCompromised:
                message = "\(message)\nDevice is jailbroken"
            case .keyMigrationFailed:
                message = "\(message)\nTouch ID/Face ID. One or more keys failed to migrate and has been invalidated."
            case .deviceNoHardwareKeystore:
                message = "\(message)\nDevice does not have a hardware keystore."
            case .keyPendingRegistrationsRemoved:
                message = "\(message)\nOne or more pending registrations were removed."
            case .none:
                break
            case .some(_):
                break
            }
        }
        
        // Check keys
        let status = IXUAF.checkKeys()
        if status != errSecSuccess {
            if let err = SecCopyErrorMessageString(status, nil) {
                message = "\(message)\n\n\(err)"
            } else {
                message = "\(message)\n\nError: \(status)"
            }
        }
        updateInfo(message: message)
    }
    
    func busy(on: Bool) {
        self.activityIndicator.isHidden = !on
        self.stackView.isHidden = on
    }
    
    @objc func didReceiveNotification(notification : Notification?) {
        checkRemoteNotification()
    }
    
    func checkRemoteNotification() {
        
        if let notification = Settings.shared.get(key: Settings.Key.notification) {
            
            busy(on: true)
            
            Settings.shared.remove(key: Settings.Key.notification)
            
            fido?.authenticate(notification: notification, username: username, parameters: nil) { [weak self] (res, error) in
                if let e = error {
                    self?.show(error: e);
                } else {
                    self?.show(title: "Notification", message: "Authenticate complete");
                }
            }
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        busy(on: true)
        
        fido?.register(username: username) { [weak self] (res, error) in
            if let e = error {
                self?.show(error: e);
            } else {
                self?.show(title: "Register", response:res);
            }
        }
    }
    
    @IBAction func authenticateButtonPressed(_ sender: Any) {
        
        busy(on: true)
        
        fido?.authenticate(username:username,
                           description: "Login",
                           parameters: [kIXUAFServiceParameterOTP : optionConfirmationOTP]) { [weak self] (res, error) in
            if let e = error {
                self?.show(error: e);
            } else {
                self?.show(title: "Authenticate", response:res);
            }
        }
    }
    
    @IBAction func deregisterButtonPressed(_ sender: Any) {
        
        busy(on: true)
        
        var message = ""
        
        fido?.deregister(username: username) { [weak self] (aaid, error) in
            if aaid == nil {
                self?.show(title: "De-register", message: message);
            } else {
                if let e = error {
                    message.append("Error: \(aaid!): \(e.localizedDescription)\n")
                } else {
                    message.append("De-register: \(aaid!)\n")
                }
            }
        }
    }
    
    
    @IBAction func deleteUserButtonPressed(_ sender: Any) {
        
        confirm(title: "Delete user", message: "Are you sure?") { [weak self] action in
            
            self?.busy(on: true)
            
            // Example.
            // Delete ALL local authenticator information without talking to the server
            //
//            if let request = IXUAFMessageWriter.deregistrationRequest(withAaid: "", application: nil) {
//                self.fido?.deregister(message: request, handler: { (error) in
//                    if let e = error {
//                        Logging.shared.log(string: "Deregister: \(e.localizedDescription)");
//                    } else {
//                        Logging.shared.log(string: "Deregister: Done");
//                    }
//                })
//            }
            
            self?.deleteUser() { (error) -> (Void) in
                DispatchQueue.main.async {
                    if let e = error {
                        self?.show(error: e);
                    } else {
                        self?.show(title: "User", message: "User archived");
                    }
                }
            }
        }
    }
    
    func reset() {
        
        confirm(title: "Reset", message: "Are you sure?") { [weak self] action in
            
            self?.busy(on: true)
            
            self?.deleteUser() { error -> (Void) in
                
                Task { @MainActor in
                    if let e = error {
                        Logging.shared.log(string: "Delete user: \(e.localizedDescription)");
                    } else {
                        Logging.shared.log(string: "User deleted");
                    }
                    
                    self?.fido?.reset()
                    
                    Settings.shared.reset()
                    
                    // Testing: Just to make sure that everything is gone
                    if let keys = IXAKeychain.allKeys() {
                        Logging.shared.log(string:"All keys (reset): \(keys)")
                    }
                    
                    // Check user defaults
                    Logging.shared.log(string:"User Defaults (standard): \(UserDefaults.standard.dictionaryRepresentation())")
                    
                    exit(0)
                }
            }
        }
    }
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        
        let on = optionSwiftUI ? "On" : "Off"
        let swiftUIAction = UIAlertAction(title: "SwiftUI (iOS15): \(on)", style: .default) { _ in
            if #available(iOS 15.0, *) {
                self.optionSwiftUI = !self.optionSwiftUI
            }
        }
        
        let cotp = optionConfirmationOTP ? "On" : "Off"
        let cotpAction = UIAlertAction(title: "Confirmation OTP: \(cotp)", style: .default) { _ in
            self.optionConfirmationOTP = !self.optionConfirmationOTP
        }
        
        let iad = optionInjectionAttackDetection ? "On" : "Off"
        let injectionAttackDetectionAction = UIAlertAction(title: "Face Injection Attack Detection: \(iad)", style: .default) { [weak self] _ in
            self?.optionInjectionAttackDetection = !(self?.optionInjectionAttackDetection ?? false)
                        
            self?.extensions["com.daon.face.liveness.ifp"] = self?.optionInjectionAttackDetection.description
            
            self?.show(title: "Face Injection Attack Detection",
                    message: "If the injection attack detection extension is provided in the server policy, this setting has no effect. The server policy takes precedence.")
            self?.busy(on: true)
            if let extensions = self?.extensions {
                self?.fido?.initialize(parameters: extensions) { (error, warnings) in
                    Task { @MainActor in
                        self?.busy(on: false)
                    }
                }
            }
        }
        
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.reset()
        }
        
        alertController.addAction(swiftUIAction)
        alertController.addAction(cotpAction)
        alertController.addAction(injectionAttackDetectionAction)
        alertController.addAction(resetAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertController, animated: true)
    }
    
    func deleteUser(completion: @escaping @Sendable (Error?) -> (Void)) {
                
        fido?.deregister(username: username) { [weak self] (aaid, error) in
            if aaid == nil {
                Logging.shared.log(string: "De-register: complete");
                
                // Archive user
                if let username = self?.username {
                    self?.fido?.delete(username: username, parameters: nil, completion: completion)
                }
                
            } else {
                if let e = error {
                    Logging.shared.log(string: "De-register: \(e.localizedDescription)")
                } else {
                    Logging.shared.log(string: "De-register: \(aaid!)")
                }
            }
        }
    }
    
    // No UI.
    // The data, e.g. password, and aaid is passed to the register or authenticate method.
    // It is up to the application to collect the data. Except for Face/Touch ID.
    
    func register(aaid: String, data: Any?) {
        
        busy(on: true)
        
        fido?.register(aaid: aaid, username: username, data:data, parameters: nil) { [weak self] (res, error) in
            if let e = error {
                self?.show(error: e)
            } else {
                self?.show(title: "Register", response:res);
            }
        }
    }
    
    func authenticate(aaid: String, data: Any?) {
        
        busy(on: true)
        
        fido?.authenticate(aaid: aaid,
                           username: username,
                           data:data,
                           description: "Authenticate",
                           parameters: [kIXUAFServiceParameterOTP : optionConfirmationOTP]) { [weak self] (res, error) in
            if let e = error {
                self?.show(error: e)
            } else {
                self?.show(title: "Authenticate", response:res)
            }
        }
    }
    
    func supported(aaid: String) -> Bool {
        // Voice and face is currently not supported
        let unsupported = ["D409#2205", "D409#9201", "D409#2203", "D409#2901", "D409#2401", "D409#9401"]
        
        return !unsupported.contains(aaid)
    }
    
    @IBAction func noUIRegisterButtonPressed(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Register", message: "Note. Passcode is hardcoded to \"1234\"", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) )
                
        fido?.discover() { [weak self] (data, error) in
            guard let self = self else {
                return
            }
            
            if let e = error {
                Task { @MainActor in
                    self.show(error: e)
                }
            } else {
                
                if let authenticators = data?.availableAuthenticators {
                    for authenticator in authenticators {
                        Task { @MainActor in
                            if !authenticator.registered(withUsername: self.username, appId: self.fido?.application) && self.supported(aaid: authenticator.aaid) {
                                
                                let action = UIAlertAction(title: authenticator.title, style: .default) { action in
                                    
                                    // HACK: Hard code data for password. This only makes sense for a
                                    // password authenticator, it is ignored otherwise.
                                    self.register(aaid: authenticator.aaid, data:"1234")
                                }
                                alertController.addAction(action)
                            }
                        }
                    }
                    
                    Task { @MainActor in
                        self.present(alertController, animated: true)
                    }
                    
                } else {
                    Task { @MainActor in
                        self.show(title:"Register", message:"No authenticators")
                    }
                }
            }
        }
    }

    @IBAction func noUIAuthenticateButtonPressed(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Authenticate", message: "Note. Passcode is hardcoded to \"1234\"", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) )
        
        fido?.discover() { (data, error) in
            if let e = error {
                Task { @MainActor in
                    self.show(error: e)
                }
            } else {
                if let authenticators = data?.availableAuthenticators {
                    for authenticator in authenticators {
                        Task { @MainActor in
                            if self.supported(aaid: authenticator.aaid) &&
                                authenticator.registered(withUsername: self.username, appId: self.fido?.application) {
                                let action = UIAlertAction(title: authenticator.title, style: .default) { action in
                                    self.authenticate(aaid: authenticator.aaid, data:"1234") // HACK: Hard code data for password
                                }
                                alertController.addAction(action)
                            }
                        }
                    }
                    
                    Task { @MainActor in
                        self.present(alertController, animated: true)
                    }
                } else {
                    Task { @MainActor in
                        self.show(title:"Authenticate", message:"No authenticators")
                    }
                }
            }
        }
    }
    
    // Delegate
    
    func operation(
        _ operation: IXUAFOperation,
        attemptFailedWithInfo info: [String : Any]) {
        
            Logging.shared.log(string:"***\nAttempt: \(info)\n***")
        
        let remaining = info["com.daon.user.retriesRemaining"] as! Int
        if remaining == 1 {
            Logging.shared.log(string:"***\nAttempt: Warning. Only one attempt left until user is locked\n***");
            
            // Add a delay, so that we can update an existing dialog instead of blocking it
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.show(title:"Too many attempts", message:"Only one attempt left until user is locked.")
            }
        }
    }
    
//    func operation(_ operation: IXUAFOperation, willAllowAuthenticators authenticators: [[IXUAFAuthenticator]]) -> [[IXUAFAuthenticator]]? {
//        
//        
//        // Return all available authenticators. Authenticators can be removed from the list for
//        // additional filtering.
//        return authenticators
//    }
    
    // Use the following to enable replacement of default authenticator screens.
    //
    // By default, just including one of the Daon provided sample classes referenced below in your project is enough to direct the
    // FIDO SDK to use those classes. However we also still provide this existing mechanism for you to return
    // your own custom view controllers to the FIDO SDK. The use of the classes here is only to provide
    
    func operation(
        _ operation: IXUAFOperation,
        shouldUseCollectionViewControllerForUserVerification method: Int,
        context: DASAuthenticatorContext) -> DASAuthenticatorCollectorInfo? {
        
            if optionSwiftUI {
                if #available(iOS 15.0, *) {
                    let viewController = customSwiftUIView(method: method, context: context)
                    
                    // If you wish to control the presentation of the authentication view controller yourself, pass in true here.
                    // Please note that you will also be responsible for dismissing it when authentication has completed.
                    return DASAuthenticatorCollectorInfo(viewController: viewController, clientWillPresent: false)
                }
            }
            return nil
    }
    
    // Use the following to enable replacement of default AND / OR screens.
    //
    // By default, just including one of the Daon provided sample classes referenced below in your project is enough to direct the
    // FIDO SDK to use those classes. However we also still provide this existing mechanism for you to return
    // your own custom view controllers to the FIDO SDK.
    
    func operation(
        _ operation: IXUAFOperation,
        shouldUseViewControllerForAuthenticatorType type: DASAuthenticatorPolicyType,
        context: DASMultiAuthenticatorContext) -> DASMultiAuthenticatorCollectorInfo? {
        
            if optionSwiftUI {
                if #available(iOS 15.0, *) {
                    if let viewController = customSwiftUIView(policyType: type, context: context) {
                        let collectorInfo = DASMultiAuthenticatorCollectorInfo()
                        collectorInfo.collectionViewController = viewController
                        return collectorInfo
                    }
                }
            }
            return nil
    }
    
    
    @available(iOS 15.0, *)
    func customSwiftUIView(method: Int, context: DASAuthenticatorContext) -> UIViewController {
        switch method {
            case USER_VERIFY_PASSCODE:
                return CustomUIHostingController(rootView: AnyView(PasscodeView(context: context)), context: context)
            
            case USER_VERIFY_FACEPRINT:
                if let info = context.authenticatorInfo {
                    if (DASUtils.isLocalAuthenticatorFactor(info.authenticatorFactor, version: info.authenticatorVersion)) {
                        return CustomUIHostingController(rootView: AnyView(LocalAuthenticationView(context: context)), context: context)
                    }
                }
            
                return CustomUIHostingController(rootView: AnyView(FaceView(context: context)), context: context)
                            
            case USER_VERIFY_FINGERPRINT:
                return CustomUIHostingController(rootView: AnyView(LocalAuthenticationView(context: context)), context: context)
            
            case USER_VERIFY_VOICEPRINT:
                return CustomUIHostingController(rootView: AnyView(VoiceView(context: context)), context: context)
            
            default:
                return CustomUIHostingController(rootView: AnyView(ErrorView(context: context, error: "Not Implemented")), context: context)
        }
    }
    
    @available(iOS 15.0, *)
    func customSwiftUIView(policyType: DASAuthenticatorPolicyType, context: DASMultiAuthenticatorContext) -> UIViewController? {
        switch policyType {
            case .OR:
                return CustomUIHostingController(rootView: AnyView(ORView(context: context)), multiAuthenticatorContext: context)
            default:
                return nil
        }
    }
    
    // Alerts and dialogs

    func show(error: Error) {
        show(title: "Error", message: "\(error._code): \(error.localizedDescription)")
    }

    func show(title: String, response:[String : Any]?) {
        if let res = response {
            show(title:title, message:res.filter({ (k, v) in
                return k != "request" && k != "application" && k != "request.id"}).description)
        } else {
            show(title:title, message:"Success!")
        }
    }
    
    func show(title: String, message: String, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(action)

        busy(on: false)
        
        Logging.shared.log(string:"***\n\(title): \(message)\n***")

        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            
            if let currentAlert = topController as? UIAlertController {
                
                currentAlert.title = title
                
                if let msg = currentAlert.message {
                    currentAlert.message = "\(msg)\n\n!\n\(message)"
                } else {
                    currentAlert.message = "\(message)"
                }
            } else {

                topController.present(alertController, animated: true)
            }
        }
    }

    func confirm(title: String, message: String, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: handler)
        alertController.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "No", style: .cancel)
        alertController.addAction(noAction)
        
        present(alertController, animated: true)
    }
    
        
    func updateInfo(message: String?) {
        
        busy(on: false)
        
        if let msg = message {
            self.infoLabel.text = msg
        } else {
            self.infoLabel.text = ""
        }
    }
}

