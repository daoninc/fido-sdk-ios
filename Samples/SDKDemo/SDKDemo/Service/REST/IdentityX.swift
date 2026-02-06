// Copyright (C) 2022 Daon.
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
// DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

import UIKit


final class IdentityX: Sendable {
        
//    var url = "https://us-dev-env4.identityx-cloud.com/unittests"
//    var serverApplicationID = "unittests"
//    var serverUsername = "admin2"
    
    let url: String?
    let serverApplicationID: String?
    let serverUsername: String?
    let RESTPath = "IdentityXServices/rest/v1"
    
    internal struct Entity {
        static let users                  = "users"
        static let authenticators         = "authenticators"
        static let authenticationRequests = "authenticationRequests"
        static let registrationChallenges = "registrationChallenges"
        static let policies               = "policies"
    }
    
    internal struct JSON {
        static let fidoRegistrationResponse   = "fidoRegistrationResponse"
        static let fidoAuthenticationResponse = "fidoAuthenticationResponse"
        static let id                         = "id"
        static let user                       = "user"
        static let userId                     = "userId"
        static let application                = "application"
        static let applicationID              = "applicationId"
        static let registration               = "registration"
        static let registrationID             = "registrationId"
        static let policy                     = "policy"
        static let policyID                   = "policyId"
        static let type                       = "type"
        static let description                = "description"
        static let status                     = "status"
        static let fidoPolicy                 = "fidoPolicy"
        static let failedClientAttempt        = "failedClientAttempt"
        static let authKeyId                  = "authKeyId"
        static let errorCode                  = "errorCode"
        static let score                      = "score"        
        static let fi                         = "FI"
        static let pending                    = "PENDING"
        static let confirmationOTP            = "oneTimePasswordEnabled"

    }
    
    internal struct Status {
        static let completed = "COMPLETED_SUCCESSFUL"
    }
    
    public init(url: String, application: String, username: String) {
        self.url = url
        self.serverApplicationID = application
        self.serverUsername = username
    }
    
    /**
     * Create a FIDO registration challenge for a specified user, application and policy
     *
     * @param username - User ID (e.g. email address)
     * @param policyId - Registration policy ID
     * @return
     */
    func registrationChallenge(username: String, policyID: String, completion: @escaping @Sendable (Error?, RegistrationChallenge?) -> (Void)) {
        
        // NOTE
        // ====
        //
        // The registrationId must be unique within the application. The registrationId is important in FIDO
        // as it is the "username" field passed to the FIDO Client and Authenticator and as such displayed to
        // the user.
        
        // The registration will be created dynamically if it is not found by a registrationId/applicationId
        // combination as long as a user is also submitted as part of the registration.
        
        // If a userId is used and the user does not exist then a user will be created dynamically with that
        // userId and will be used for the registration creation.
        
        let applicationID   = serverApplicationID
        let policyID        = policyID
        
        let user        = [JSON.userId          : username]
        
        let application = [JSON.applicationID   : applicationID]
        
        let policy      = [JSON.policyID        : policyID,
                           JSON.application     : application] as [String : Any]
        
        let reg         = [JSON.registrationID  : username,
                           JSON.application     : application,
                           JSON.user            : user] as [String : Any]
        
        let challenge   = [JSON.policy          : policy,
                           JSON.registration    : reg] as [String : Any]
        
        HTTP.post(url: url(entity:Entity.registrationChallenges), username: serverUsername, payload: challenge) { (error, response) -> (Void) in
            if let err = error{
                completion(err, nil)
            } else {
                do {
                    let jsonResponseData = response!.data(using: String.Encoding.utf8)
                    let regChallengeObject = try JSONDecoder().decode(RegistrationChallenge.self, from: jsonResponseData!)
                    completion(nil, regChallengeObject)
                    
                } catch let err {
                    print(err.localizedDescription)
                    completion(HTTPError.createRegistrationChallengeServerError, nil)
                }
            }
        }
    }
    
    /**
     * Update a FIDO registration challenge
     *
     * @param registrationChallenge - the registration challenge
     * @return Updated RegistrationChallenge
     */
    func update(registrationId: String, registrationResponse: String, completion: @escaping @Sendable (Error?, RegistrationChallenge?) -> (Void)) {
                        
        let challenge   = [JSON.id                       : registrationId,
                           JSON.status                   : JSON.pending,
                           JSON.fidoRegistrationResponse : registrationResponse]
        
        HTTP.post(url: url(entity:Entity.registrationChallenges + "/" + registrationId), username: serverUsername, payload: challenge) { (error, response) -> (Void) in
            if let err = error {
                completion(err, nil)
            } else {
                do {
                    let jsonResponseData = response!.data(using: String.Encoding.utf8)
                    let regChallengeObject = try JSONDecoder().decode(RegistrationChallenge.self, from: jsonResponseData!)
                    completion(nil, regChallengeObject)
                } catch (_) {
                    completion(HTTPError.updateRegistrationChallengeCantDecode, nil)
                }
            }
        }
    }
    
    /**
     * Create an Authentication Request
     *
     * @param username - IdentityX user ID
     * @param policyId - Authentication policy ID
     * @param description - the authentication request description
     *
     * @return AuthenticationRequest
     */
    func authenticationRequest(username: String?, policyID: String, description: String, otp: Bool, completion: @escaping @Sendable (Error?, AuthenticationRequest?) -> (Void)) {
        
        let applicationId   = serverApplicationID
        let policyID        = policyID
        
        let application = [JSON.applicationID    : applicationId]
        
        let policy      = [JSON.policyID         : policyID,
                           JSON.application      : application] as [String : Any]
        
        var request     = [JSON.policy           : policy,
                           JSON.type             : JSON.fi,
                           JSON.description      : description] as [String : Any]
        
        if username != nil {
            request[JSON.user] = [JSON.userId : username]
        }
        
        request[JSON.confirmationOTP] = otp
        

        HTTP.post(url: url(entity:Entity.authenticationRequests), username: serverUsername, payload: request) { (error, response) -> (Void) in
            if let err = error {
                completion(err, nil)
            } else {
                do {
                    let jsonResponseData = response!.data(using: String.Encoding.utf8)
                    let authRequestObject = try JSONDecoder().decode(AuthenticationRequest.self, from: jsonResponseData!)
                    completion(nil, authRequestObject)
                } catch (_) {
                    completion(HTTPError.createAuthenticationRequestDecodeError, nil)
                }
            }
        }
    }
    
    /**
     * Update an Authentication Request
     *
     * @param authenticationRequest - authentication request to update
     *
     * @return AuthenticationRequest
     */
    func update(authenticationId: String, authenticationResponse: String, completion: @escaping @Sendable (Error?, AuthenticationRequest?) -> (Void)) {
                    
        let request = [JSON.id                           : authenticationId,
                       JSON.fidoAuthenticationResponse   : authenticationResponse]
        
        HTTP.post(url: url(entity: Entity.authenticationRequests + "/" + authenticationId), username: serverUsername, payload: request) { (error, response) -> (Void) in
            if let err = error {
                completion(err, nil)
            } else {
                do {
                    let jsonResponseData = response!.data(using: String.Encoding.utf8)
                    let authRequestObject = try JSONDecoder().decode(AuthenticationRequest.self, from: jsonResponseData!)
                    completion(nil, authRequestObject)
                } catch _ {
                    completion(HTTPError.updateAuthenticationRequestDecodeError, nil)
                }
            }
        }
    }
    
    /**
     * Update an failed attempts
     *
     * @param info - failed attempt data
     * @param authenticationRequest - authentication request to update
     *
     * @return AuthenticationRequest
     */
    func update(withAttempt info: [String : Any], requestId: String, completion: @escaping @Sendable  (Error?, AuthenticationRequest?) -> (Void)) {
        
        var attempt = [String : Any]()
        
        if let authKeyId = info["userAuthKeyId"] {
            
            // Note
            // Only works if we have a key id
            //
            
            attempt[JSON.authKeyId] = authKeyId as? String
            
            if let errorCode = info["errorCode"] {
                attempt[JSON.errorCode] = errorCode as? Int
            }
            
            if let score = info["score"] {
                attempt[JSON.score] = score as? Double
            }
            
            let request = [JSON.id                  : requestId,
                           JSON.failedClientAttempt : attempt] as [String : Any]
            
            
            HTTP.post(url: url(entity: Entity.authenticationRequests + "/" + requestId + "/appendFailedAttempt"),
                      username: serverUsername,
                      payload: request) { (error, response) -> (Void) in
                if let err = error {
                    completion(err, nil)
                } else {
                    do {
                        let jsonResponseData = response!.data(using: String.Encoding.utf8)
                        let authRequestObject = try JSONDecoder().decode(AuthenticationRequest.self, from: jsonResponseData!)
                        completion(nil, authRequestObject)
                    } catch _ {
                        completion(HTTPError.updateAuthenticationRequestDecodeError, nil)
                    }
                }
            }
        }
    }
    
    /**
     * Get a policy
     *
     * @param policyId - IdentityX policyID
     */
    func policy(id: String, completion: @escaping @Sendable (Error?, String?) -> (Void)) {
        
        let policyId = id
        
        HTTP.get(url: url(entity: Entity.policies + "?status=ACTIVE&policyId=" + policyId), username: serverUsername) { (error, response) -> (Void) in
            if let e = error {
                completion(e, nil)
            } else {
                do {
                    if let res = response, let json = res.data(using: String.Encoding.utf8) {
                        
                        var found = false
                        
                        let policies = try JSONDecoder().decode(Policies.self, from: json)
                        if let items = policies.items {
                            if items.count > 0 {
                                if let id = items[0].id {
                                    found = true
                                    self.policyContent(id: id, completion: completion)
                                }
                            }
                        }
                        
                        if !found {
                            completion(nil, nil)
                        }
                     
                    } else {
                        completion(HTTPError.policyRequestServerError, nil)
                    }
                }
                catch _ {                    
                    completion(HTTPError.policyRequestServerError, nil)
                }
            }
        }
    }
    
    /**
     * Get a policy
     *
     * @param id - IdentityX policy entity ID
     */
    private func policyContent(id: String, completion: @escaping @Sendable (Error?, String?) -> (Void)) {
        
        HTTP.get(url: url(entity: Entity.policies + "/" + id), username: serverUsername) { (error, response) -> (Void) in
            if let e = error {
                completion(e, nil)
            } else {
                do {
                    if let res = response, let json = res.data(using: String.Encoding.utf8) {
                        
                        var str : String?
                        let dictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any]
                        if let policy = dictionary?[JSON.fidoPolicy] as? [String : Any] {
                            str = HTTP.JSONString(object: policy)
                        }
                        completion(nil, str)
                        
                    } else {
                        completion(HTTPError.policyRequestServerError, nil)
                    }
                }
                catch _ {
                    completion(HTTPError.policyRequestServerError, nil)
                }
            }
        }
    }
    
    /**
     * Get a user
     *
     * @param username - IdentityX userId / username
     */
    private func user(username: String, completion: @escaping @Sendable (Error?, User?) -> (Void)) {
        
        HTTP.get(url: url(entity: Entity.users + "?userId=" + username), username: serverUsername) { (error, response) -> (Void) in
            if let e = error {
                completion(e, nil)
            } else {
                do {
                    if let res = response, let json = res.data(using: String.Encoding.utf8) {
                        
                        var found = false
                        
                        let users = try JSONDecoder().decode(Users.self, from: json)
                        
                        if let items = users.items {
                            for user in items {
                            
                                // We do not want an archived user
                                if user.status == "ACTIVE" {
                                    found = true
                                    completion(nil, user)
                                }
                            }
                        }
                        
                        if !found {
                            completion(nil, nil)
                        }
                        
                    } else {
                        completion(HTTPError.usersRequestServerError, nil)
                    }
                }
                catch _ {
                    completion(HTTPError.usersRequestServerError, nil)
                }
            }
        }
    }
    
    /**
     * Archive a user
     *
     * @param username - IdentityX userId / username
     */
    func archive(username: String, completion: @escaping @Sendable (Error?) -> (Void)) {
        
        user(username: username) { (error, user) -> (Void) in
            if let e = error {
                completion(e)
            } else {
                if let id = user?.id {
                    let url = self.url(entity: Entity.users + "/" + id + "/archived")
                    HTTP.post(url: url, username: self.serverUsername, payload: [:]) { (error, response) in
                        completion(error)
                    }
                } else {
                    completion(HTTPError.deleteError)
                }
            }
        }
        
    }
    
    /**
     * Get list of authenticators for a user
     *
     * @param username - IdentityX userId / username
     */
    func authenticators(username: String, completion: @escaping @Sendable (Error?, [Authenticator]?) -> (Void)) {
        
        user(username: username) { (error, user) -> (Void) in
            if let e = error {
                completion(e, nil)
            } else {
                if let id = user?.id {
                    self.authenticators(userid: id, completion: completion)
                } else {
                    completion(HTTPError.usersRequestServerError, nil)
                }
            }
        }
        
    }
    
    /**
     * Get list of authenticators for a user
     *
     * @param id - IdentityX user entity ID
     */
    private func authenticators(userid: String, completion: @escaping @Sendable (Error?, [Authenticator]?) -> (Void)) {
        
        HTTP.get(url: url(entity: Entity.users + "/" + userid + "/authenticators?limit=1000"), username: serverUsername) { (error, response)  in
            if let e = error {
                completion(e, nil)
            } else {
                do {
                    if let res = response, let json = res.data(using: String.Encoding.utf8) {
                        let authenticators = try JSONDecoder().decode(Authenticators.self, from: json)
                        completion(nil, authenticators.items)
                    } else {
                        completion(HTTPError.authenticatorsRequestServerError, nil)
                    }
                } catch _ {
                    completion(HTTPError.authenticatorsRequestServerError, nil)
                }
            }
        }
    }
    
    /**
     * Archive an authenticator
     *
     * @param id - Authenticator ID
     * @param username - Username
     */
    func archive(authenticator id: String, username: String, completion: @escaping @Sendable (Error?, String?) -> (Void)) {
        
        HTTP.post(url: url(entity: Entity.authenticators + "/" + id + "/archived"), username: serverUsername, payload: [:]) { (error, response) in
            if let err = error {
                completion(err, nil)
            } else {
                do {
                    let jsonResponseData = response!.data(using: String.Encoding.utf8)
                    let deregRequestObject = try JSONDecoder().decode(DeregistrationRequest.self, from: jsonResponseData!)
                    completion(nil, deregRequestObject.fidoDeregistrationRequest)
                } catch _ {
                    completion(HTTPError.deleteError, nil)
                }
            }
        }
    }
    

    private func url(entity: String) -> String {
        return "\(url ?? "NA")/\(RESTPath)/\(entity)"
    }
}
