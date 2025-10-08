// Copyright (C) 2022 Daon.
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
// DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

//
//  RPSAService
//
//  Implements the IXUAFServiceDelegate protocol used by IXUAF()
//
//  Copyright © 2018-22 Daon. All rights reserved.
//

import SystemConfiguration
import DaonFIDOSDK


@objc public class IXUAFRPSAServiceErrorCode : NSObject {
    
    @objc public static let couldNotParse : Int = -1
    @objc public static let couldNotCreateRequest : Int = -2
    @objc public static let expiredSession : Int = 202
    @objc public static let noSession : Int = 203
}

@objc public class IXUAFRPSAService : NSObject, IXUAFServiceDelegate {
    
    public init(url: String) {
        RPSAService.shared.server = url
    }
    
    public func serviceRequestAccess(parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        if let username = parameters?[kIXUAFServiceParameterUsername] as? String {

            let first = parameters?[kIXUAFServiceParameterAccountNameFirst] as? String ?? "first name"
            let last = parameters?[kIXUAFServiceParameterAccountNameFirst] as? String ?? "last name"
            let password = parameters?[kIXUAFServiceParameterAccountPassword] as? String
            let registration = parameters?[kIXUAFServiceParameterAccountRegistrationRequest] as? Bool ?? true
            
            RPSAService.shared.account(first: first,
                                       last: last,
                                       username: username,
                                       password: password,
                                       registration: registration) { (token, error) in
                if let e = error {
                    handler(nil, nil, e)
                } else {
                    handler(token, nil, nil)
                }
            }
        }
    }
    
    public func serviceRevokeAccess(parameters params: [String : Any]?, handler: @escaping (Error?) -> Void) {
        RPSAService.shared.deleteSession(completion: handler)
    }

    public func serviceDeleteUser(parameters params: [String : Any]?, handler: @escaping (Error?) -> Void) {
        RPSAService.shared.deleteAccount(completion:handler)
    }
    
    public func serviceRequestRegistration(parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        RPSAService.shared.serviceRequestRegistration(parameters: parameters, handler: handler)
    }
        
    public func serviceRegister(message: String, parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        RPSAService.shared.serviceRegister(message: message, parameters: parameters, handler: handler)
    }
    
    public func serviceRequestAuthentication(parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        RPSAService.shared.serviceRequestAuthentication(parameters: parameters, handler: handler)
    }
    
    public func serviceAuthenticate(message: String, parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        RPSAService.shared.serviceAuthenticate(message: message, parameters: parameters, handler: handler)
    }
    
    public func serviceUpdate(message: String, username: String?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        RPSAService.shared.serviceUpdate(message: message, username: username, handler: handler)
    }
    
    public func serviceRequestDeregistration(aaid: String, parameters: [String : Any]?, handler: @escaping (String?, Error?) -> Void) {
        RPSAService.shared.serviceRequestDeregistration(aaid: aaid, parameters: parameters, handler: handler)
    }
    
    public func serviceRequestRegistrationPolicy(parameters: [String : String]?, handler: @escaping (String?, Error?) -> Void) {
        RPSAService.shared.serviceRequestRegistrationPolicy(parameters: parameters, handler: handler)
    }
    
    public func serviceUpdate(attempt info: [String : Any], handler: @escaping (String?, Error?) -> Void) {
        RPSAService.shared.serviceUpdate(attempt: info, handler: handler)
    }
}


internal class RPSAService : NSObject {
    
    static let shared: RPSAService = RPSAService()
    
    var server = "https://emea-rp.identityx-cloud.com/daonfuda-fido/"
    
    // Resources
    private let KServerResourceAccounts                     = "accounts"
    private let KServerResourceSessions                     = "sessions"
    private let KServerResourceListAuthenticators           = "listAuthenticators"
    private let KServerResourceAuthenticators               = "authenticators"
    private let KServerResourceAuthRequests                 = "authRequests"
    private let KServerResourceTransactionAuthRequests      = "transactionAuthRequests"
    private let KServerResourceAuthValidation               = "transactionAuthValidation"
    private let KServerResourceRegRequests                  = "regRequests"
    private let KServerResourceSubmitFailedAttempts         = "failedTransactionData"
    
    // Response data keys
    private let jsonEmailAddressKey                 = "emailAddress"
    private let jsonSubmittedAuthenticationCodeKey  = "submittedAuthenticationCode"
    private let jsonSecureTransactionContentKey     = "secureTransactionContent"
    private let jsonEmailKey                        = "email"
    private let jsonPasswordKey                     = "password"
    private let jsonFidoAuthenticationResponseKey   = "fidoAuthenticationResponse"
    private let jsonFidoAuthenticationRequestKey    = "fidoAuthenticationRequest"
    private let jsonAuthenticationRequestIdKey      = "authenticationRequestId"
    private let jsonFirstNameKey                    = "firstName"
    private let jsonLastNameKey                     = "lastName"
    private let jsonRegistrationRequestedKey        = "registrationRequested"
    private let jsonLanguageKey                     = "language"
    private let jsonTransactionContentTypeKey       = "transactionContentType"
    private let jsonTransactionContentKey           = "transactionContent"
    private let jsonEnableConfirmationOTP           = "otpEnabled"
    private let jsonStepUpAuthKey                   = "stepUpAuth"
    private let jsonFidoRegistrationResponseKey     = "fidoReqistrationResponse"
    private let jsonRegistrationChallengeIdKey      = "registrationChallengeId"
    
    private let kContentTypeText = "text/plain"
    private let kContentTypePNG = "image/png"
    
    private var sessionId : String?
    private var requestId : String?
    private var singleShotRequest : String?
    private var cachedRegistrationRequest : String?
    private var cachedRegistrationRequestId : String?
    
    enum State {
        case login
        case stepup
        case push
    }

    private var state : State = .login
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
        
    // Get Registration Request message from server
    public func serviceRequestRegistration(parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        if cachedRegistrationRequest != nil {
            print("Daon Service: Using cached registration request")
                        
            handler(cachedRegistrationRequest, [:], nil)
            
            self.requestId = cachedRegistrationRequestId
            self.cachedRegistrationRequest = nil
            
        } else {
            get(resource: KServerResourceRegRequests, completion: { (json, raw) in
                
                let response = RequestRegistrationResponse(json: json)
                self.requestId = response.registrationRequestId
                
                handler(response.fidoRegistrationRequest, [:], nil)
                
            }) { (error) in
                handler(error.localizedDescription, [:], error)
            }
        }
    }
    

    public func serviceRegister(message: String, parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        var body = Dictionary<String, String>()
        
        body[jsonFidoRegistrationResponseKey]   = message
        body[jsonRegistrationChallengeIdKey]    = requestId
        
        post(resource: KServerResourceAuthenticators, body: body, completion: { (json, raw) in
            
            // Check for FIDO error
            let response = RegisterAuthenticatorResponse(json: json)
            if let code = response.fidoResponseCode, let msg = response.fidoResponseMsg {
                
                if code == IXUAFServerErrorCode.noError.rawValue {
                    handler(response.fidoRegistrationConfirmation, [:], nil)
                } else {
                    handler(response.fidoRegistrationConfirmation, [:], ServerOperationError(errorCode: code, msg: msg))
                }
            }
        }) { (error) in
            handler(error.localizedDescription, [:], error)
        }
    }
    
    public func serviceRequestAuthentication(parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
                
        // Clear the request id
        self.requestId = nil
        
        let username = parameters?[kIXUAFServiceParameterUsername] as? String
                
        // If we have an id, it's a push notification
        // If the server supports it, use the instanceId, kIXUAFServiceParameterInstanceID for better performance
        if let id = parameters?[kIXUAFServiceParameterIdentifier] as? String {
            
            state = .push
            
            requestAuthentication(resource: KServerResourceAuthRequests + "/" + id, handler: handler)
                        
        } else {
            // If we have a session it is a step-up
            if sessionId != nil {
                
                state = .stepup
                
                let singleshot = parameters?[kIXUAFServiceParameterSingleShot] as? Bool ?? false
                
                if singleshot {
                    print("Daon Service: Single-shot")
                    
                    // If single-shot then don't call the server.
                    
                    // Client generated authentication request, aka single-shot aka offline request
                    //
                    // NOTE
                    // The Sample RP Server currently only supports single shot for step-up/transactions authentications
                    
                    // Create a request based on an open policy
                    singleShotRequest = IXUAFMessageWriter.authenticationRequest(withApplication: parameters?[kIXUAFServiceParameterApplication] as? String)
                    singleShotRequest = IXUAFMessageWriter.updateRequest(singleShotRequest, username: username)
                    singleShotRequest = IXUAFMessageWriter.updateRequest(singleShotRequest, extensions: ["com.daon.sdk.deviceInfo" : "true"])
                    
                    handler(singleShotRequest, [:], nil)
                    
                } else {
                    // Get request from the server
                    print("Daon Service: Server request")
                    
                    singleShotRequest = nil
                                                                            
                    var body = Dictionary<String, String>()
                    
                    body[jsonStepUpAuthKey] = "true"
                    
                    if let cotp = parameters?[kIXUAFServiceParameterOTP] as? Bool {
                        if cotp {
                            body[jsonEnableConfirmationOTP] = "true"
                        }
                    }
                                        
                    if let tcType = parameters?[kIXUAFServiceParameterTransactionConfirmationType] as? String {
                        body[jsonTransactionContentTypeKey] = tcType
                                                
                        if let tcContent = parameters?[kIXUAFServiceParameterTransactionConfirmationContent] as? String {
                            body[jsonTransactionContentKey] = tcContent
                        } else {
                            body[jsonTransactionContentTypeKey] = kContentTypeText
                            body[jsonTransactionContentKey] = "No content data provided"
                        }
                    }

                    post(resource: KServerResourceTransactionAuthRequests, body: body, completion: { (json, raw) in
            
                        let response = RequestAuthenticationResponse(json: json)
                        self.requestId = response.authenticationRequestId
            
                        handler(response.fidoAuthenticationRequest, [:], nil)
            
                    }) { (error) in
                        handler(error.localizedDescription, [:], error)
                    }
                }
            } else {
                state = .login
                
                singleShotRequest = nil
                
                var resource = KServerResourceAuthRequests
                
                if username != nil {
                    resource = "\(resource)?userId=\(username!)"
                }
                
                requestAuthentication(resource: resource, handler: handler)
            }
        }
    }
    
    
    public func serviceAuthenticate(message: String, parameters: [String : Any]?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        if state == .login || state == .push {
            createSession(message: message, handler: handler)
        } else {
            let username = parameters?[kIXUAFServiceParameterUsername] as? String
            
            verify(message: message, username: username, handler: handler)
        }
    }
    
    public func serviceUpdate(message: String, username: String?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        // If this is a registration request we have to use a different server call
        let reader = IXUAFMessageReader.init(message: message)            
        if reader.isRegistration() {
            serviceRegister(message: message, parameters: nil, handler: handler)
        } else {
            verify(message: message, username: username, handler: handler)
        }
    }
    
    public func serviceRequestDeregistration(aaid: String, parameters: [String : Any]?, handler: @escaping (String?, Error?) -> Void) {
        
        // Get the list of authenticators from the server to get the authenticator id
        listAuthenticators() { (response) in
            
            if let error = response.error {
                handler(nil, error)
            } else {
                
                if let info = self.find(authenticators: response.authenticatorInfoList, aaid: aaid, status: "ACTIVE") {
                    
                    // Tell the server to de-register the authenticator
                    self.deregisterAuthenticator(withId: info.id) { (response) in
                        
                        if let error = response.error {
                            handler(nil, error)
                        } else {
                            handler(response.deregistrationRequest, nil)
                        }
                    }
                } else {
                    
                    // Providing IXUAFErrorCode.userNotEnrolled will deregister the authenticator
                    handler(nil, ServerOperationError(errorCode: IXUAFErrorCode.userNotEnrolled.rawValue, msg: "No ACTIVE Authenticator found on server"))
                }
            }
        }
    }
    
    func find(authenticators:[AuthenticatorInfo]?, aaid: String, status: String) -> AuthenticatorInfo? {
        
        if let list = authenticators {
            for info in list {
                if info.aaid == aaid {
                    // NOTE. The RP Server may return a deviceid. If multiple devices are
                    // using the same account, we should only deregister the authenticator
                    // on this device.
                    if info.deviceid == "" || info.deviceid == IXUAF.deviceId() {
                        if info.status == status {
                            return info
                        }
                    }
                }
            }
        }
        return nil
    }
    
    public func serviceRequestRegistrationPolicy(parameters: [String : String]?, handler: @escaping (String?, Error?) -> Void) {
        
        get(resource: "policies/reg", completion: { (json, raw) in
            let response = GetPolicyResponse(json: json)
            handler(response.policy, nil)
        }) { (error) in
            handler(nil, error)
        }
    }
    
    public func serviceUpdate(attempt info: [String : Any], handler: @escaping (String?, Error?) -> Void) {
                
        if info["userAuthKeyId"] != nil {
            
            // Note
            // Only works if we have a key id
            
            var body = [String: String]()
            body[jsonAuthenticationRequestIdKey] = requestId
            
            // Only get strings and convert integers to strings
            for key in info.keys {
                if let str = info[key] as? String  {
                    body[key] = str
                } else if let int = info[key] as? Int  {
                    body[key] = String(int)
                }
            }
            
            post(resource: KServerResourceSubmitFailedAttempts, body: body, completion: { (json, raw) in
                let response = RequestAuthenticationResponse(json: json)
                handler(response.fidoAuthenticationRequest, nil)
            }) { (error) in
                handler(nil, error)
            }
        }
    }

    private func requestAuthentication(resource: String, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {

        get(resource: resource, completion: { (json, raw) in

            let response = RequestAuthenticationResponse(json: json)
            self.requestId = response.authenticationRequestId

            handler(response.fidoAuthenticationRequest, [:], nil)

        }) { (error) in
            handler(error.localizedDescription, [:], error)
        }
    }

    
    private func createSession(message : String?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        var body = Dictionary<String, String>()
        
        body[jsonEmailKey] = ""
        body[jsonPasswordKey] = ""
        body[jsonFidoAuthenticationResponseKey] = message
        body[jsonAuthenticationRequestIdKey] = requestId
        
        post(resource: KServerResourceSessions, body: body, completion: { (json, raw) in
            
            let response = CreateSessionResponse(json: json)
            self.sessionId = response.sessionId
            handler(response.fidoAuthenticationResponse, [:], nil)
            
        }) { (error) in
            handler(error.localizedDescription, [:], error)
        }
    }
    
    private func verify(message: String, username: String?, handler: @escaping (String?, [String : Any]?, Error?) -> Void) {
        
        var body = Dictionary<String, String>()
                
        if username != nil {
            body[jsonEmailKey] = username;
        }
        
        body[jsonFidoAuthenticationResponseKey] = message
        
        if requestId != nil {
            body[jsonAuthenticationRequestIdKey] = requestId
        }
        
        if singleShotRequest != nil {
            body[jsonFidoAuthenticationRequestKey] = singleShotRequest
        }
        
        post(resource: KServerResourceAuthValidation, body: body, completion: { (json, raw) in
            
            // Check for FIDO error
            let response = VerifyAuthenticationResponse(json: json)
            
            if let code = response.fidoResponseCode, let msg = response.fidoResponseMsg {
                
                if code == IXUAFServerErrorCode.noError.rawValue {
                    handler(response.fidoAuthenticationResponse, [:], nil)
                } else {
                    handler(response.fidoAuthenticationResponse, [:], ServerOperationError(errorCode: code, msg: msg))
                }
            }
        }) { (error) in
            handler(error.localizedDescription, [:], error)
        }
    }
    
    private func getAuthenticator(withId: String, completion: @escaping (GetAuthenticatorResponse) -> ()) {
        
        let resource = KServerResourceAuthenticators + "/" + withId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        get(resource: resource, completion: { (json, raw) in
            completion(GetAuthenticatorResponse(json: json))
        }) { (error) in
            completion(GetAuthenticatorResponse(error: error))
        }
    }
    
    private func deregisterAuthenticator(withId: String, completion: @escaping (DeregisterAuthenticatorResponse) -> ()) {
        
        if let authenticatorIdEscapedString = withId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            
            delete(resource: KServerResourceAuthenticators, identifier:authenticatorIdEscapedString, completion: { (json, raw) in
                completion(DeregisterAuthenticatorResponse(request: raw))
            }) { (error) in
                completion(DeregisterAuthenticatorResponse(error: error))
            }
        }
    }
   
    //
    // Account management
    //
    
    public func active(authenticators: [IXUAFAuthenticator]?, completion: @escaping ([IXUAFAuthenticator]) -> Void) -> Void {
        
        var active = [IXUAFAuthenticator]()
        
        if let list = authenticators {
            
            // Get the list of authenticators from the server
            listAuthenticators() { (response) in
                
                DispatchQueue.main.async {
                    if response.error != nil {
                        completion(list)
                    } else {
                        for authenticator in list {
                            // If the authenticator is active add it
                            if self.find(authenticators: response.authenticatorInfoList, aaid: authenticator.aaid, status: "ACTIVE") != nil {
                                active.append(authenticator)
                            }
                        }
                        completion(active)
                    }
                }
            }
        }
    }
    
    private func listAuthenticators(completion: @escaping (ListAuthenticatorsResponse) -> ()) {
        
        get(resource: KServerResourceListAuthenticators, completion: { (json, raw) in
            completion(ListAuthenticatorsResponse(json: json))
        }) { (error) in
            completion(ListAuthenticatorsResponse(error: error))
        }
    }
        
    public func account(first: String,
                        last: String,
                        username: String,
                        password: String?,
                        registration: Bool,
                        completion: @escaping (String?, Error?) -> ()) {
        
        var body = Dictionary<String, String>()
        
        body[jsonFirstNameKey]              = first
        body[jsonLastNameKey]               = last
        body[jsonEmailKey]                  = username
        body[jsonPasswordKey]               = password
        body[jsonRegistrationRequestedKey]  = registration ? "true" : "false"
        body[jsonLanguageKey]               = Locale.current.languageCode
        
        post(resource: KServerResourceAccounts, body: body, completion: { (json, raw) in
                        
            print("Daon Service: create account")
            
            IXAKeychain.setKey("daon.rpsa.password", value:password ?? UUID().uuidString)
            
            let response = CreateAccountResponse(json: json)
            
            self.cachedRegistrationRequest = response.fidoRegistrationRequest
            self.cachedRegistrationRequestId = response.registrationRequestId
            self.sessionId = response.sessionId
            completion(self.sessionId, nil)
            
        }) { (error) in
            // TODO option to disable this
            if error.code == 105 { // Account exists
                print("Daon Service: create session")
                
                self.createSession(username: username,
                                   password: password ?? IXAKeychain.string(forKey: "daon.rpsa.password"),
                                   completion: completion)
            } else {
                completion(nil, error)
            }
        }
    }
    
    public func deleteAccount(completion: @escaping (Error?) -> ()) {
        
        delete(resource: KServerResourceAccounts, completion: { (json, raw) in
            completion(nil)
        }) { (error) in
            completion(error)
        }
    }
    
    // disconnect/revoke
    public func deleteSession(completion: @escaping (Error?) -> ()) {
        
        if (self.sessionId == nil) {
            completion(ServerOperationError.NON_EXISTENT_SESSION)
            return
        }
        
        delete(resource: KServerResourceSessions, completion: { (json, raw) in
            completion(nil)
        }) { (error) in
            completion(error)
        }
        
        self.sessionId = nil
    }

    
    public func createSession(username : String, password : String, completion: @escaping (String?, Error?) -> ()) {

        var body = Dictionary<String, String>()

        body[jsonEmailKey] = username
        body[jsonPasswordKey] = password

        post(resource: KServerResourceSessions, body: body, completion: { (json, raw) in

            let response = CreateSessionResponse(json: json)
            self.sessionId = response.sessionId
            completion(self.sessionId, nil)

        }) { (error) in
            completion(nil, error)
        }
    }
    
    
    
    // HTTP Post and Get
    
    private func post(resource : String,
                      body: Dictionary<String, String>,
                      completion: @escaping (Any, String) -> (),
                      failure: @escaping (ServerOperationError) -> ()) {
        
        let operation = ServerOperation(postUrl: server,
                                        resourceName: resource,
                                        body: body,
                                        session: sessionId,
                                        completion: completion,
                                        failure: failure)
        
        operation.start()
    }
    
    private func get(resource : String,
                     completion: @escaping (Any, String) -> (),
                     failure: @escaping (ServerOperationError) -> ()) {
        
        let operation = ServerOperation(getUrl: server,
                                        resourceName: resource,
                                        session: sessionId,
                                        completion: completion,
                                        failure: failure)
        
        operation.start()
    }
    
    private func delete(resource : String,
                        completion: @escaping (Any, String) -> (),
                        failure: @escaping (ServerOperationError) -> ()) {
        
        delete(resource: resource, identifier: sessionId!, completion: completion, failure: failure)
    }
    
    private func delete(resource : String,
                        identifier: String,
                        completion: @escaping (Any, String) -> (),
                        failure: @escaping (ServerOperationError) -> ()) {
        
        let operation = ServerOperation(deleteUrl: server,
                                        resourceName: resource,
                                        identifier: identifier,
                                        session: sessionId,
                                        completion: completion,
                                        failure: failure)
        
        operation.start()
    }
}
