//
//  CustomUIHostingController.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2020-25 Daon. All rights reserved.
//

import SwiftUI

import DaonAuthenticatorSDK

/// Inherits from UIHostingController in order to capture the drag down to dismiss event in hosted SwiftUI views.
class CustomUIHostingController: UIHostingController<AnyView>, UIAdaptivePresentationControllerDelegate {
    
    private unowned var context : DASAuthenticatorContext?
    private unowned var multiAuthenticatorContext : DASMultiAuthenticatorContext?
    
    /// Initializes the controller with a root view and an authenticator context.
    /// - Parameters:
    ///   - rootView: The root view to be hosted.
    ///   - context: The authenticator context.
    init(rootView: AnyView, context: DASAuthenticatorContext) {
        self.context = context
                
        super.init(rootView: rootView)
    }

    /// Initializes the controller with a root view and a multi-authenticator context.
    /// - Parameters:
    ///   - rootView: The root view to be hosted.
    ///   - multiAuthenticatorContext: The multi-authenticator context.
    init(rootView: AnyView, multiAuthenticatorContext: DASMultiAuthenticatorContext) {
        self.multiAuthenticatorContext = multiAuthenticatorContext
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
            
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismiss(notification:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            navigationController?.navigationBar.standardAppearance = appearance;
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }
        
        // Register for the iOS 13 pull-down to dismiss gesture event.
        self.navigationController?.presentationController?.delegate = self;
    }

    
    /// Called on the delegate when the user has taken action to dismiss the presentation successfully, after all animations are finished.
    /// This is not called if the presentation is dismissed programmatically.
    /// - Parameter presentationController: The current UIPresentationController.
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // Handle the iOS 13 swipe to dismiss gesture.
        self.context?.cancelCapture()
        self.multiAuthenticatorContext?.cancelCapture()
    }
    
    @objc func dismiss(notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        
        self.context?.cancelCapture()
        self.multiAuthenticatorContext?.cancelCapture()
    }
}

