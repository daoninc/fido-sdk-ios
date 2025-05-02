//
//  ErrorView.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2020-25 Daon. All rights reserved.
//

import SwiftUI

import DaonAuthenticatorSDK

/// Cancellable SwiftUI view for displaying an error.

struct ErrorView: View {
    
    /// The error message to display.
    var error : String
    
    private var context: DASAuthenticatorContext?
    
    /// Initializes a new instance of the @link PasscodeView @/link struct.
    /// - Parameter context: The @link DASAuthenticatorContext @/link object with which the view can cancel the authentication. If nil, no cancellation button will be displayed
    /// - Parameter error: The error message to display
    init(context: DASAuthenticatorContext? = nil, error: String){
        self.context = context
        self.error = error
    }
        
    var body: some View {
        VStack {
            Spacer();
            
            Text(error)
                .multilineTextAlignment(.center);
            
            Spacer();
            Spacer();
        }
        .onDisappear { self.dismiss() }
    }
    
    func cancel() {
        context?.cancelCapture()
    }
    
    func dismiss() {
        guard let context = context else { return }
        
        if !context.isCaptureComplete {
            cancel()
        }
    }
}

