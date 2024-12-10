//
//  IdentityXService.swift
//  Copyright © 2019 Daon. All rights reserved.
//

import Foundation
import DaonFIDOSDK

class IDXUAFService : NSObject, IXUAFServiceDelegate {
        
    let idx = IdentityX()
    
    var registrationChallenge : RegistrationChallenge?
    var authenticationRequest : AuthenticationRequest?
    
    func error(code: Int, message: String?) -> NSError {
        if let msg = message {
            return NSError(domain: "Server", code: code, userInfo: [NSLocalizedDescriptionKey : msg])
        }
        return NSError(domain: "Server", code: code)
    }
    
    // Request a FIOD registration challenge
    func serviceRequestRegistration(parameters: [String : Any]?, handler: @escaping (String?, Error?) -> Void) {
        
        if let user = parameters?[kIXUAFServiceParameterUsername] as? String {

            idx.registrationChallenge(withUsername: user) { (error, challenge) -> (Void) in
                
                self.registrationChallenge = challenge
                
                if let e = error {
                    handler(e.localizedDescription, e)
                } else {
                    handler(challenge?.fidoRegistrationRequest, nil)
                }
            }
        } else {
            handler(nil, IXUAFError.protocolError())
        }
    }
    
    // Submit the provided FIDO registration message to the server
    func serviceRegister(message: String, parameters params: [String : Any]?, handler: @escaping (String?, Error?) -> Void) {
        register(message: message, handler: handler)
    }
    
    // Request a FIDO authentication
    func serviceRequestAuthentication(parameters: [String : Any]?, handler: @escaping (String?, Error?) -> Void) {
        
        let username = parameters?[kIXUAFServiceParameterUsername] as? String
        let description = parameters?[kIXUAFServiceParameterDescription] as? String
        
        idx.authenticationRequest(withUsername: username, description: description ?? "NA") { (error, request) -> (Void) in
            
            self.authenticationRequest = request
            
            if let e = error {
                handler(e.localizedDescription, e)
            } else {
                handler(request?.fidoAuthenticationRequest, nil)                                
            }
        }
        
    }
    
    // Submit the provided FIDO authentication message to the server
    func serviceAuthenticate(message: String, parameters: [String : Any]?, handler: @escaping (String?, Error?) -> Void) {
        
        authenticate(message: message, handler: handler)
    }
    
    // Submit updated FIDO message to the server. This would be an ADoS message with user data
    
    func serviceUpdate(message: String, username: String?, handler: @escaping (String?, Error?) -> Void) {
        
        // If this is a registration request we have to use a different server call
        if let operation = IXUAFMessageReader.init(message: message) {
            if operation.isRegistration() {
                register(message: message, handler: handler)
            } else {
                authenticate(message: message, handler: handler)
            }
        }
    }
    
    // Request a deregistration message
    func serviceRequestDeregistration(aaid: String, parameters: [String : Any]?, handler: @escaping (String?, Error?) -> Void) {
        
        // The application is the FIDO application ID, not the IdentityX application
        //let request = IXUAFMessageWriter.deregistrationRequest(withAaid: aaid, application: application)
        //handler(request, nil)
        
        if let user = parameters?[kIXUAFServiceParameterUsername] as? String {
            idx.authenticators(withUsername: user) { (error, authenticators) -> (Void) in
                if let e = error {
                    handler(e.localizedDescription, e)
                } else {
                    
                    if let authenticator = self.findActive(authenticators: authenticators, aaid: aaid) {
                        self.idx.archive(authenticator: authenticator.id!, username: user, completion: { (error, res) in
                            if let e = error {
                                handler(e.localizedDescription, e)
                            } else {
                                handler(res, nil)
                            }
                        })
                    } else {
                        handler(nil, IXUAFError.error(withCode: IXUAFErrorCode.userNotEnrolled.rawValue))
                    }
                }
            }
        }
    }
    
    // Get the registration policy
    func serviceRequestRegistrationPolicy(handler: @escaping (String?, Error?) -> Void) {
     
        let policy = Settings.shared.getString(key: Settings.Key.serverRegistrationPolicyID)
        
        idx.policy(withPolicyID: policy) { (error, policy) -> (Void) in
            if let e = error {
                handler(e.localizedDescription, e)
            } else {
                handler(policy, nil)
            }
        }
    }
    
    // Submit failed attempt data to the server
    func serviceUpdate(attempt info: [String : Any], handler: @escaping (String?, Error?) -> Void) {
        
        if let authentication = authenticationRequest {
            
            idx.update(withAttempt: info, authenticationRequest: authentication) { (error, response) -> (Void) in
                if let e = error {
                    handler(response?.fidoAuthenticationResponse, e)
                } else {
                    handler(response?.fidoAuthenticationResponse, nil)
                }
            }
        }
    }
    
    //
    // Helper methods
    //
    
    private func register(message: String, handler: @escaping (String?, Error?) -> Void) {
        
        if let challenge = registrationChallenge {
            challenge.fidoRegistrationResponse = message
            
            idx.update(registrationChallenge: challenge) { (error, challenge) -> (Void) in
                if let e = error {
                    handler(e.localizedDescription, e)
                } else {
                    if let code = challenge?.fidoResponseCode {
                        if code == IXUAFServerErrorCode.noError.rawValue {
                            handler(challenge?.fidoRegistrationResponse, nil)
                        } else {
                            handler(challenge?.fidoRegistrationResponse, self.error(code: code, message: challenge?.fidoResponseMsg))
                        }
                    }
                }
            }
        } else {
            handler(nil, IXUAFError.protocolError())
        }
    }
    
    private func authenticate(message: String, handler: @escaping (String?, Error?) -> Void) {
        
        if let authentication = authenticationRequest {
            authentication.fidoAuthenticationResponse = message
            
            idx.update(authenticationRequest: authentication) { (error, reponse) -> (Void) in
                if let e = error {
                    handler(e.localizedDescription, e)
                } else {
                    if let code = reponse?.fidoResponseCode {
                        if code == IXUAFServerErrorCode.noError.rawValue {
                            handler(reponse?.fidoAuthenticationResponse, nil)
                        } else {
                            handler(reponse?.fidoAuthenticationResponse, self.error(code: code, message: reponse?.fidoResponseMsg))
                        }
                    }
                }
            }
        } else {
            handler(nil, IXUAFError.protocolError())
        }
    }
    
    private func findActive(authenticators:[Authenticator]?, aaid: String) -> Authenticator? {
        
        if let list = authenticators {
            for authenticator in list {
                if authenticator.authenticatorAttestationId == aaid {
                    // NOTE. If multiple devices are using the same account, we should only deregister
                    // the authenticator on this device.
                    if authenticator.deviceCorrelationId == "" || authenticator.deviceCorrelationId == DaonFIDO.deviceId() {
                        if authenticator.status == "ACTIVE" {
                            return authenticator
                        }
                    }
                }
            }
        }
        return nil
    }
}
