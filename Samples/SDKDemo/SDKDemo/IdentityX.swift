//
//  IdentityXComms.swift
//
//  Copyright © 2019 Daon. All rights reserved.
//

import UIKit

class IdentityX {
    
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

    }
    
    internal struct Status {
        static let completed = "COMPLETED_SUCCESSFUL"
    }
    
    /**
     * Create a FIDO registration challenge for a specified user, application and policy
     *
     * @param username - User ID (e.g. email address)
     * @param policyId - Registration policy ID
     * @return
     */
    func registrationChallenge(withUsername username: String, completion: @escaping (Error?, RegistrationChallenge?) -> (Void)) {
        
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
        
        let applicationID   = Settings.shared.getString(key: Settings.Key.serverApplicationID)
        let policyID        = Settings.shared.getString(key: Settings.Key.serverRegistrationPolicyID)
        
        let user        = [JSON.userId          : username]
        
        let application = [JSON.applicationID   : applicationID]
        
        let policy      = [JSON.policyID        : policyID,
                           JSON.application     : application] as [String : Any]
        
        let reg         = [JSON.registrationID  : username,
                           JSON.application     : application,
                           JSON.user            : user] as [String : Any]
        
        let challenge   = [JSON.policy          : policy,
                           JSON.registration    : reg] as [String : Any]
        
        HTTP.post(url: url(entity:Entity.registrationChallenges), payload: challenge) { (error, response) -> (Void) in
            if let err = error{
                completion(err, nil)
            } else {
                do {
                    let jsonResponseData = response!.data(using: String.Encoding.utf8)
                    let regChallengeObject = try JSONDecoder().decode(RegistrationChallenge.self, from: jsonResponseData!)
                    completion(nil, regChallengeObject)
                    
                } catch let err {
                    Logging.log(string: HTTPError.createRegistrationChallengeServerError.localizedDescription + ": " + err.localizedDescription)
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
    func update(registrationChallenge: RegistrationChallenge, completion: @escaping (Error?, RegistrationChallenge?) -> (Void)) {
        
        if let id = registrationChallenge.id, let fidoRegistrationResponse = registrationChallenge.fidoRegistrationResponse {
            
            let challenge   = [JSON.id                       : id,
                               JSON.status                   : JSON.pending,
                               JSON.fidoRegistrationResponse : fidoRegistrationResponse]
            
            HTTP.post(url: url(entity:Entity.registrationChallenges + "/" + id), payload: challenge) { (error, response) -> (Void) in
                if let err = error {
                    completion(err, nil)
                } else {
                    do {
                        let jsonResponseData = response!.data(using: String.Encoding.utf8)
                        let regChallengeObject = try JSONDecoder().decode(RegistrationChallenge.self, from: jsonResponseData!)
                        completion(nil, regChallengeObject)
                    } catch (_) {
                        Logging.log(error: HTTPError.updateRegistrationChallengeCantDecode)
                        completion(HTTPError.updateRegistrationChallengeCantDecode, nil)
                    }
                }
            }
        } else {
            completion(HTTPError.updateRegistrationChallengeServerError, nil)
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
    func authenticationRequest(withUsername username: String?, description: String, completion: @escaping (Error?, AuthenticationRequest?) -> (Void)) {
        
        let applicationId   = Settings.shared.getString(key: Settings.Key.serverApplicationID)
        let policyID        = Settings.shared.getString(key: Settings.Key.serverAuthenticationPolicyID)
        
        let application = [JSON.applicationID    : applicationId]
        
        let policy      = [JSON.policyID         : policyID,
                           JSON.application      : application] as [String : Any]
        
        var request     = [JSON.policy           : policy,
                           JSON.type             : JSON.fi,
                           JSON.description      : description] as [String : Any]
        
        if username != nil {
            request[JSON.user] = [JSON.userId : username]
        }

        HTTP.post(url: url(entity:Entity.authenticationRequests), payload: request) { (error, response) -> (Void) in
            if let err = error {
                completion(err, nil)
            } else {
                do {
                    let jsonResponseData = response!.data(using: String.Encoding.utf8)
                    let authRequestObject = try JSONDecoder().decode(AuthenticationRequest.self, from: jsonResponseData!)
                    completion(nil, authRequestObject)
                } catch (_) {
                    Logging.log(error: HTTPError.createAuthenticationRequestDecodeError)
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
    func update(authenticationRequest: AuthenticationRequest, completion: @escaping (Error?, AuthenticationRequest?) -> (Void)) {
        
        if let id = authenticationRequest.id, let fidoAuthenticationResponse = authenticationRequest.fidoAuthenticationResponse {
            
            let request = [JSON.id                           : id,
                           JSON.fidoAuthenticationResponse   : fidoAuthenticationResponse]
            
            HTTP.post(url: url(entity: Entity.authenticationRequests + "/" + id), payload: request) { (error, response) -> (Void) in
                if let err = error {
                    completion(err, nil)
                } else {
                    do {
                        let jsonResponseData = response!.data(using: String.Encoding.utf8)
                        let authRequestObject = try JSONDecoder().decode(AuthenticationRequest.self, from: jsonResponseData!)
                        completion(nil, authRequestObject)
                    } catch _ {
                        Logging.log(error: HTTPError.updateAuthenticationRequestDecodeError)
                        completion(HTTPError.updateAuthenticationRequestDecodeError, nil)
                    }
                }
            }
        } else {
            completion(HTTPError.updateAuthenticationRequestServerError, nil)
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
    func update(withAttempt info: [String : Any], authenticationRequest: AuthenticationRequest, completion: @escaping (Error?, AuthenticationRequest?) -> (Void)) {
        
        if let id = authenticationRequest.id {
            
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
                
                let request = [JSON.id                  : id,
                               JSON.failedClientAttempt : attempt] as [String : Any]
                
                
                HTTP.post(url: url(entity: Entity.authenticationRequests + "/" + id + "/appendFailedAttempt"), payload: request) { (error, response) -> (Void) in
                    if let err = error {
                        completion(err, nil)
                    } else {
                        do {
                            let jsonResponseData = response!.data(using: String.Encoding.utf8)
                            let authRequestObject = try JSONDecoder().decode(AuthenticationRequest.self, from: jsonResponseData!)
                            completion(nil, authRequestObject)
                        } catch _ {
                            Logging.log(error: HTTPError.updateAuthenticationRequestDecodeError)
                            completion(HTTPError.updateAuthenticationRequestDecodeError, nil)
                        }
                    }
                }
            }
        } else {
            completion(HTTPError.updateAuthenticationRequestServerError, nil)
        }
    }
    
    /**
     * Get a policy
     *
     * @param policyId - IdentityX policyID
     */
    func policy(withPolicyID policyId: String, completion: @escaping (Error?, String?) -> (Void)) {
        
        HTTP.get(url: url(entity: Entity.policies + "?status=ACTIVE&policyId=" + policyId)) { (error, response) -> (Void) in
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
                                    self.policy(withID: id, completion: completion)
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
    private func policy(withID id: String, completion: @escaping (Error?, String?) -> (Void)) {
        
        HTTP.get(url: url(entity: Entity.policies + "/" + id)) { (error, response) -> (Void) in
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
    func user(withUsername username: String, completion: @escaping (Error?, User?) -> (Void)) {
        
        HTTP.get(url: url(entity: Entity.users + "?userId=" + username)) { (error, response) -> (Void) in
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
    func archive(withUsername username: String, completion: @escaping (Error?, String?) -> (Void)) {
        
        user(withUsername: username) { (error, user) -> (Void) in
            if let e = error {
                completion(e, nil)
            } else {
                if let id = user?.id {                    
                    HTTP.post(url: self.url(entity: Entity.users + "/" + id + "/archived"), payload: [:], completion: completion)
                } else {
                    completion(HTTPError.deleteError, nil)
                }
            }
        }
        
    }
    
    /**
     * Get list of authenticators for a user
     *
     * @param username - IdentityX userId / username
     */
    func authenticators(withUsername username: String, completion: @escaping (Error?, [Authenticator]?) -> (Void)) {
        
        user(withUsername: username) { (error, user) -> (Void) in
            if let e = error {
                completion(e, nil)
            } else {
                if let id = user?.id {
                    self.authenticators(withUserID: id, completion: completion)
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
    func authenticators(withUserID id: String, completion: @escaping (Error?, [Authenticator]?) -> (Void)) {
        
        HTTP.get(url: url(entity: Entity.users + "/" + id + "/authenticators?limit=1000")) { (error, response)  in
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
    func archive(authenticator id: String, username: String, completion: @escaping (Error?, String?) -> (Void)) {
        
        HTTP.post(url: self.url(entity: Entity.authenticators + "/" + id + "/archived"), payload: [:]) { (error, response) in
            if let err = error {
                completion(err, nil)
            } else {
                do {
                    let jsonResponseData = response!.data(using: String.Encoding.utf8)
                    let deregRequestObject = try JSONDecoder().decode(DeregistrationRequest.self, from: jsonResponseData!)
                    completion(nil, deregRequestObject.fidoDeregistrationRequest)
                } catch _ {
                    Logging.log(error: HTTPError.deleteError)
                    completion(HTTPError.deleteError, nil)
                }
            }
        }
    }
    

    private func url(entity: String) -> String {
        
        let host    = Settings.shared.getString(key: Settings.Key.serverAddress)
        let port    = Settings.shared.getInt(key: Settings.Key.serverPort)
        let scheme  = Settings.shared.getBool(key: Settings.Key.serverSecure) ? HTTP.HTTPScheme.https : HTTP.HTTPScheme.http
        
        let url = URL(string: scheme + "://" + host)!
        
        return url.scheme! + "://" + url.host! + ":" + String(port) + url.path + "/" + RESTPath + "/" + entity
    }
}
