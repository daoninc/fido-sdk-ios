// Copyright (C) 2022 Daon.
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
// DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

import Foundation
import DaonFIDOSDK


@objc public class IXUAFRESTService : NSObject, IXUAFServiceDelegate {
    
    var idx : IdentityX?
    
    var registrationChallenge : RegistrationChallenge?
    var authenticationRequest : AuthenticationRequest?
        
    // TODO use Dictionary
    public init(url: String, application: String, username: String) {
        idx = IdentityX(url:url , application: application, username: username);
    }
    
    func error(code: Int, message: String?) -> NSError {
        if let msg = message {
            return NSError(domain: "Server", code: code, userInfo: [NSLocalizedDescriptionKey : msg])
        }
        return NSError(domain: "Server", code: code)
    }
    
    // Called by IXUAF requestServiceAccessWithUsername:parameters:completion
    public func serviceRequestAccess(parameters params: [String : Any]?, handler: @escaping (String?, Error?) -> Void) {
        
        // Nothing to do at the moment
        
        // serviceRequestRegistration
        //
        // The registration/user will be created if it is not found by a registrationId/applicationId
        // combination as long as a user is also submitted as part of the registration.
        //
        // If a userId is used and the user does not exist then a user will be created.
        handler(nil, nil)
    }
    
    // Called by IXUAF revokeServiceAccessWithParameters:completion
    public func serviceRevokeAccess(parameters params: [String : Any]?, handler: @escaping (Error?) -> Void) {
        // Nothing to do at the moment
        handler(nil)
    }
    
    // Called by IXUAF deleteUser:parameters:completion
    public func serviceDeleteUser(parameters: [String : Any]?, handler: @escaping (Error?) -> Void) {
        if let username = parameters?[kIXUAFServiceParameterUsername] as? String {
            idx?.archive(username: username, completion: handler)
        } else {
            handler(IXUAFError.error(withCode: IXUAFErrorCode.userNotEnrolled.rawValue))
        }
    }
    

    // Request a FIOD registration challenge
    public func serviceRequestRegistration(parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        if let user = parameters?[kIXUAFServiceParameterUsername] as? String {

            let policy = parameters?[kIXUAFServiceParameterPolicyRegistration] as? String ?? "reg"
            
            idx?.registrationChallenge(username: user, policyID: policy) { (error, challenge) -> (Void) in
                
                self.registrationChallenge = challenge
                
                if let e = error {
                    handler(e.localizedDescription, [:], e)
                } else {
                    handler(challenge?.fidoRegistrationRequest, [:], nil)
                }
            }
        } else {
            handler(nil, [:], IXUAFError.protocolError())
        }
    }
    
    // Submit the provided FIDO registration message to the server
    public func serviceRegister(message: String, parameters params: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        register(message: message, handler: handler)
    }
    
    // Request a FIDO authentication
    public func serviceRequestAuthentication(parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        let username = parameters?[kIXUAFServiceParameterUsername] as? String
        let description = parameters?[kIXUAFServiceParameterDescription] as? String
        let policy = parameters?[kIXUAFServiceParameterPolicyAuthentication] as? String ?? "auth"
        
        idx?.authenticationRequest(username: username, policyID: policy, description: description ?? "NA") { (error, request) -> (Void) in
            
            let customData = ["custom1":"1"];
            
            self.authenticationRequest = request
            
            if let e = error {
                handler(e.localizedDescription, customData, e)
            } else {
                handler(request?.fidoAuthenticationRequest, customData, nil)
            }
        }
        
    }
    
    // Submit the provided FIDO authentication message to the server
    public func serviceAuthenticate(message: String, parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        authenticate(message: message, handler: handler)
    }
    
    // Submit updated FIDO message to the server. This would be an ADoS message with user data
    
    public func serviceUpdate(message: String, username: String?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        // If this is a registration request we have to use a different server call
        let operation = IXUAFMessageReader.init(message: message)
        if operation.isRegistration() {
            register(message: message, handler: handler)
        } else {
            authenticate(message: message, handler: handler)
        }
    
    }
    
    // Request a deregistration message
    public func serviceRequestDeregistration(aaid: String, parameters: [String : Any]?, handler: @escaping (String?, Error?) -> Void) {
        
        // The application is the FIDO application ID, not the IdentityX application
        //let request = IXUAFMessageWriter.deregistrationRequest(withAaid: aaid, application: application)
        //handler(request, nil)
        
        if let user = parameters?[kIXUAFServiceParameterUsername] as? String {
            idx?.authenticators(username: user) { [self] (error, authenticators) -> (Void) in
                if let e = error {
                    handler(e.localizedDescription, e)
                } else {
                    
                    if let authenticator = self.findActive(authenticators: authenticators, aaid: aaid) {
                        idx?.archive(authenticator: authenticator.id!, username: user, completion: { (error, res) in
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
    public func serviceRequestRegistrationPolicy(parameters: [String : String]?, handler: @escaping (String?, Error?) -> Void) {
     
        let policy = parameters?[kIXUAFServiceParameterPolicyAuthentication] as? String ?? "reg"
        
        idx?.policy(id: policy) { (error, policy) -> (Void) in
            if let e = error {
                handler(e.localizedDescription, e)
            } else {
                handler(policy, nil)
            }
        }
    }
    
    // Submit failed attempt data to the server
    public func serviceUpdate(attempt info: [String : Any], handler: @escaping (String?, Error?) -> Void) {
        
        if let authentication = authenticationRequest {
            
            idx?.update(withAttempt: info, authenticationRequest: authentication) { (error, response) -> (Void) in
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
    
    private func register(message: String, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        if let challenge = registrationChallenge {
            challenge.fidoRegistrationResponse = message
            
            idx?.update(registrationChallenge: challenge) { (error, challenge) -> (Void) in
                if let e = error {
                    handler(e.localizedDescription, [:], e)
                } else {
                    if let code = challenge?.fidoResponseCode {
                        if code == IXUAFServerErrorCode.noError.rawValue {
                            handler(challenge?.fidoRegistrationResponse, [:], nil)
                        } else {
                            handler(challenge?.fidoRegistrationResponse, [:], self.error(code: code, message: challenge?.fidoResponseMsg))
                        }
                    }
                }
            }
        } else {
            handler(nil, [:], IXUAFError.protocolError())
        }
    }
    
    private func authenticate(message: String, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        if let authentication = authenticationRequest {
            authentication.fidoAuthenticationResponse = message
            
            idx?.update(authenticationRequest: authentication) { (error, reponse) -> (Void) in
                
                let customData = ["custom2":"2"];
                
                if let e = error {
                    handler(e.localizedDescription, customData, e)
                } else {
                    if let code = reponse?.fidoResponseCode {
                        if code == IXUAFServerErrorCode.noError.rawValue {
                            handler(reponse?.fidoAuthenticationResponse, customData, nil)
                        } else {
                            handler(reponse?.fidoAuthenticationResponse, customData, self.error(code: code, message: reponse?.fidoResponseMsg))
                        }
                    }
                }
            }
        } else {
            handler(nil, [:], IXUAFError.protocolError())
        }
    }
    
    private func findActive(authenticators:[Authenticator]?, aaid: String) -> Authenticator? {
        
        if let list = authenticators {
            for authenticator in list {
                if authenticator.authenticatorAttestationId == aaid {
                    // NOTE. If multiple devices are using the same account, we should only deregister
                    // the authenticator on this device.
                    if authenticator.deviceCorrelationId == "" || authenticator.deviceCorrelationId == IXUAF.deviceId() {
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
