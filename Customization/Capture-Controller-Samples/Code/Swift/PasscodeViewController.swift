//
//  PasscodeViewController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import UIKit

class PasscodeViewController: DASAuthenticatorViewControllerBase {
    // MARK:- Outlets
    
    @IBOutlet var passcodeTextField: UITextField!
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var processingIndicator: UIActivityIndicatorView!
    
    
    // MARK:- Closures
    
    fileprivate let inputHandler : ((_ passcode: String) -> ())
    fileprivate let cancellationHandler: (() -> ())
    
    
    // MARK:- State
    
    fileprivate var isProcessing = false

    
    // MARK:- Initialisation
    
    init!(nibName nibNameOrNil: String!,
          bundle nibBundleOrNil: Bundle!,
          inputHandler: @escaping ((_ passcode: String) -> ()),
          cancellationHandler: @escaping (() -> ())) {
        self.inputHandler = inputHandler
        self.cancellationHandler = cancellationHandler;
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Passcode (Swift CC Sample)"
        showCancelButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        passcodeTextField.becomeFirstResponder()
    }
    
    
    // MARK:- DASAuthenticatorViewControllerBase - Actions
    
    override func authenticatorIsCancelling() {
        dismissVisibleAlert()
        passcodeTextField.resignFirstResponder()
        cancellationHandler()
    }
    
    
    // MARK:- IBActions
    
    @IBAction func continuePressed(_ sender: Any) {
        self.passcodeTextField.resignFirstResponder()
        
        if passcodeTextField.text!.count > 0 {
            self.setIsProcessing(true)
            inputHandler(passcodeTextField.text!)
        } else {
            handleError("Please enter a passcode")
        }
    }
    
    
    // MARK:- UI

    private func setIsProcessing(_ processing: Bool) {
        objc_sync_enter(self)

        if isProcessing != processing {
            isProcessing = processing
            
            self.passcodeTextField.isEnabled  = !isProcessing
            self.continueButton.isEnabled     = !isProcessing
            self.continueButton.isHidden      = isProcessing
            self.processingIndicator.isHidden = !isProcessing
            
            if isProcessing {
                super.hideCancelButton()
            } else {
                super.showCancelButton()
            }
        }

        objc_sync_exit(self)
    }
    
    
    // MARK:- Error Handling
    
    public func handleError(_ errorMessage: String) {
        self.setIsProcessing(false)
        
        showAlert(withTitle: "Error", message: errorMessage) {
            self.passcodeTextField.text = nil
            self.passcodeTextField.becomeFirstResponder()
        }
    }
}
