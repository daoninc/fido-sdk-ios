//
//  ViewController.swift
//  SingleShot-Swift
//
//  Copyright © 2019 Daon. All rights reserved.
//

import UIKit
import DaonFIDOSDK

class ViewController: UIViewController, IXUAFDelegate {

    var fido : IXUAF?
    var username : String?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!    
    @IBOutlet weak var infoLabel: UILabel!
    
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
        
        username = Settings.shared.getString(key: Settings.Key.username)
        
        let server = Settings.shared.getString(key: Settings.Key.serverAddress)
        let serverUsername = Settings.shared.getString(key: Settings.Key.serverUsername)
        let serverPassword = Settings.shared.getString(key: Settings.Key.serverPassword)
        let application = Settings.shared.getString(key: Settings.Key.serverApplicationID)
        
        if server.contains("acme.com") {
            
            performSegue(withIdentifier: "Settings", sender: self)
            
        } else if username == "email" {
            
            show(title: "Username", message: "Please provide a username in Settings"){ (action) in
                self.performSegue(withIdentifier: "Settings", sender: self)
            }
            
        } else {
                        
            if fido == nil {
                
                busy(on: true)
                
                // Store server credentials username and password in key chain
                IXAKeychain.setKey(serverUsername, value: serverPassword)
                
                fido = IXUAF(service:IXUAFRESTService(url: server, application: application, username:serverUsername))
                
                let params = ["com.daon.sdk.ados.enabled" : "true"];
                
                
                fido?.logging = true
                fido?.delegate = self
                
                fido?.initialize(parameters: params) { (code, warnings) in
                    
                    self.busy(on: false)
                    
                    if code == .licenseExpired {
                        self.show(title: "Initialize failed", message: "License expired")
                    } else if code == .licenseNotVerified {
                        self.show(title: "Initialize failed", message: "License not verified")
                    } else if code == .licenseNoAuthenticators {
                        self.show(title: "Initialize failed", message: "No licensed authenticators")
                    } else {
                        if code != .noError {
                            self.show(title: "Initialize", message: "\(code.rawValue)")
                        }
                        
                        self.checkRemoteNotification()                        
                    }
                    
                    self.show(warnings: warnings)
                }
            }
            
            IXUAFLocator.sharedInstance().locate()
        }
    }

    func show(warnings: [NSNumber]) {
        
        var message = ""
        
        for warning in warnings {
            if warning == IXUAFWarningDeviceDebug {
                message = "Application is running in debug mode"
            } else if warning == IXUAFWarningDeviceSimulator {
                message = "Application is running in a simulator"
            } else if warning == IXUAFWarningDeviceSecurityDisabled {
                message = "Device passcode/Touch ID/Face ID is not enabled"
            } else if warning == IXUAFWarningDeviceCompromised {
                message = "Device is jailbroken"
            } else if warning == IXUAFWarningKeyMigrationFailed {
                message = "Touch ID/Face ID. One or more keys failed to migrate and has been invalidated."
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
            
            fido?.authenticate(notification: notification, username: username, parameters: nil) { (res, error) in
                if let e = error {
                    self.show(error: e);
                } else {
                    self.show(title: "Notification", message: "Authenticate complete");
                }
            }
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        busy(on: true)
        
        fido?.register(username: username) { (res, error) in
            if let e = error {
                self.show(error: e);                
            } else {
                self.show(title: "Register", response:res);
            }
        }
    }
    
    @IBAction func authenticateButtonPressed(_ sender: Any) {
        
        busy(on: true)
        
        fido?.authenticate(username:username, description: "Login") { (res, error) in
            if let e = error {
                self.show(error: e);
            } else {
                self.show(title: "Authenticate", response:res?.filter({ (k,v) in
                    return k != "request";
                }));
            }
        }
    }
    
    @IBAction func deregisterButtonPressed(_ sender: Any) {
        
        busy(on: true)
        
        var message = ""
        
        fido?.deregister(username: username!) { (aaid, error) in
            if aaid == nil {                
                self.show(title: "De-register", message: message);
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
        
        confirm(title: "Delete user", message: "Are you sure?") { action in
            
            self.busy(on: true)
            
            // Example.
            // Delete ALL local authenticator information without talking to the server
            //
//            let request = IXUAFMessageWriter.deregistrationRequest(withAaid: "", application: fidoAppID)
//            self.fido?.deregister(withMessage: request, handler: { (error) in
//                if let e = error {
//                    Logging.log(string: "Deregister: \(e.localizedDescription)");
//                } else {
//                    Logging.log(string: "Deregister: Done");
//                }
//            })
            
            self.deleteUser() { (error) -> (Void) in
                DispatchQueue.main.async {
                    if let e = error {
                        self.show(error: e);
                    } else {
                        self.show(title: "User", message: "User archived");
                    }
                }
            }
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        
        confirm(title: "Reset", message: "Are you sure?") { action in
            
            self.busy(on: true)
            
            self.deleteUser() { (error) -> (Void) in
                if let e = error {
                    Logging.log(string: "Delete user: \(e.localizedDescription)");
                } else {
                    Logging.log(string: "User deleted");
                }
                
                self.fido?.reset()
                Settings.shared.reset()
                
                // Testing: Just to make sure that everything is gone
                if let keys = IXAKeychain.allKeys() {
                    print("All keys (reset): ", keys)
                }
                
                // Check user defaults
                print("User Defaults (standard): ", UserDefaults.standard.dictionaryRepresentation())
                
                exit(0)
            }
        }
    }
    
    func deleteUser(completion: @escaping (Error?) -> (Void)) {
                
        if let username = username {
            fido?.deregister(username: username) { [self] (aaid, error) in
                if aaid == nil {
                    Logging.log(string: "De-register: complete");
                    
                    // Archive user
                    fido?.delete(username: username, parameters: nil, completion: completion)
                    
                } else {
                    if let e = error {
                        Logging.log(string: "De-register: \(e.localizedDescription)")
                    } else {
                        Logging.log(string: "De-register: \(aaid!)")
                    }
                }
            }
        }
    }
    
    // No UI.
    // The data, e.g. password, and aaid is passed to the register or authenticate method.
    // It is up to the application to collect the data. Except for Face/Touch ID.
    
    func register(aaid: String, data: Any?) {
        
        busy(on: true)
        
        fido?.register(aaid: aaid, username: username, data:data, parameters: nil) { (res, error) in
            if let e = error {
                self.show(error: e)
            } else {
                self.show(title: "Register", response:res);
            }
        }
    }
    
    func authenticate(aaid: String, data: Any?) {
        
        busy(on: true)
        
        fido?.authenticate(aaid: aaid, username: username, data:data, description: "Authenticate", parameters: nil) { (res, error) in
            if let e = error {
                self.show(error: e)
            } else {
                self.show(title: "Authenticate", response:res)
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
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = .zero
        
        fido?.discover() { (data, error) in
            if let e = error {
                self.show(error: e)
            } else {
                
                if let authenticators = data?.availableAuthenticators {
                    for authenticator in authenticators {
                                                
                        if !authenticator.registered && self.supported(aaid: authenticator.aaid) {
                            let action = UIAlertAction(title: authenticator.title, style: .default) { action in
                                
                                // HACK: Hard code data for password. This only makes sense for a
                                // password authenticator, it is ignored otherwise.
                                self.register(aaid: authenticator.aaid, data:"1234")
                            }
                            alertController.addAction(action)
                        }
                    }
                    
                    self.present(alertController, animated: true)
                    
                } else {
                    self.show(title:"Register", message:"No authenticators")
                }
            }
        }
    }

    @IBAction func noUIAuthenticateButtonPressed(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Authenticate", message: "Note. Passcode is hardcoded to \"1234\"", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) )
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = .zero
        
        fido?.discover() { (data, error) in
            if let e = error {
                self.show(error: e)
            } else {
                if let authenticators = data?.availableAuthenticators {
                    for authenticator in authenticators {
                        
                        if self.supported(aaid: authenticator.aaid) &&
                            authenticator.registered(withUsername: self.username, appId: self.fido?.application) {
                            let action = UIAlertAction(title: authenticator.title, style: .default) { action in
                                self.authenticate(aaid: authenticator.aaid, data:"1234") // HACK: Hard code data for password
                            }
                            alertController.addAction(action)
                        }
                    }
                    
                    self.present(alertController, animated: true)
                    
                } else {
                    self.show(title:"Authenticate", message:"No authenticators")
                }
            }
        }
    }

    
    // Delegate
    
    func operation(_ operation: IXUAFOperation, attemptFailedWithInfo info: [String : Any]) {
        
        Logging.log(string:"***\nAttempt: \(info)\n***")
        
        let remaining = info["com.daon.user.retriesRemaining"] as! Int
        if remaining == 1 {
            Logging.log(string:"***\nAttempt: Warning. Only one attempt left until user is locked\n***");
            
            // Add a delay, so that we can update an existing dialog instead of blocking it
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.show(title:"Too many attempts", message:"Only one attempt left until user is locked.")
            }
        }
    }

    func show(error: Error) {
        show(title: "Error", message: "\(error._code): \(error.localizedDescription)")
    }

    func show(title: String, response:[String : Any]?) {
        if let res = response {
            show(title:title, message:res.filter({ (k, v) in return k != "request"}).description)
        } else {
            show(title:title, message:"Success!")
        }
    }
    
    func show(title: String, message: String, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(action)

        busy(on: false)
        
        Logging.log(string:"***\n\(title): \(message)\n***")

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

