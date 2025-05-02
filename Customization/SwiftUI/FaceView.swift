//
//  FaceView.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019-25 Daon. All rights reserved.
//

import SwiftUI
import DaonAuthenticatorSDK

#Preview {
    if #available(iOS 15.0, *) {
        FaceView(context: nil)
    } else {
        // Fallback on earlier versions
    }
}

/// SwiftUI view for face registration and authentication.
@available(iOS 15.0, *)
struct FaceView: View {
    
    @ObservedObject private var model : FaceViewModel
        
    init(context: DASAuthenticatorContext?) {
        self.model = FaceViewModel(context: context, useCustomView: true)
    }
        
    var body: some View {
        Group {
            Text("A face authenticator with server based liveness and injection attack detection. Press START to begin capture.").italic()
                .padding(50)
                .multilineTextAlignment(.center)
                .background(.gray.opacity(0.1))
            
            Spacer()
            
            Button("START") {
                model.startCapture()
            }
            .buttonStyle(.bordered)
        }
        .navigationBarTitle(model.title)
    }
}
