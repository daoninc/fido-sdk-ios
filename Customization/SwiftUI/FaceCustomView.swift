//
//  FaceCustomView.swift
//  SDKDemo
//
//  Copyright © 2025 Daon. All rights reserved.
//

import SwiftUI

#Preview {
    if #available(iOS 15.0, *) {
        FaceCustomView(model: FaceViewModel(context: nil))
    } else {
        // Fallback on earlier versions
    }
}

@available(iOS 15.0, *)
struct FaceCustomView: View {
    @ObservedObject var model : FaceViewModel
        
    var body: some View {
        VStack {
            HStack {
                Button {
                    model.cancel()
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
                .disabled(model.busy)
                
                Spacer()
                
            }
            .padding(.horizontal)
            .padding(.vertical, 50)
                        
            Spacer()
            
            HStack {
                Spacer()
                Text(model.message)
                    .frame(width: 300, height: 100, alignment: .center)
                    .background(.black.opacity(0.5))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .cornerRadius(8)
                    
                Spacer()
            }
            .padding(50)
            .opacity(model.buttons || model.busy ? 0 : 1)
                        
            if $model.buttons.wrappedValue {
                HStack {
                    Spacer()
                    switch model.state {
                    case .start:
                        Button("Start") {
                            model.start()
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle)
                        
                    case .confirm:
                        Button("Confirm") {
                            model.confirm()
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle)
                        
                        Button("Retry") {
                            model.retry()
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                        
                    case .error:
                        VStack {
                            Text(model.error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 20)
                            
                            Button("Retry") {
                                model.retry()
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 60)
                .background(Color.black.opacity(0.8))
                
            } // End button bar
                        
            if $model.busy.wrappedValue {
                VStack {
                    ProgressView()
                        .tint(.white)
                        .controlSize(.large)
                }
                .padding(.vertical, 80)
            }
        }
        .overlay(Oval().stroke(model.color, lineWidth: 4))
        .background(Color.black.opacity(0.5)
        .clipShape(OvalMask(), style: FillStyle(eoFill: true)))
        
    }
        
}

struct OvalMask: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addPath(Rectangle().path(in: rect))
            path.addPath(Ellipse().scale(0.9).path(in: CGRect(x: 20, y: 80, width: rect.width - 2 * 20, height: rect.height * 0.65)))
        }
    }
}

struct Oval: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addPath(Ellipse().scale(0.9).path(in: CGRect(x: 20, y: 80, width: rect.width - 2 * 20, height: rect.height * 0.65)))
        }
    }
}
