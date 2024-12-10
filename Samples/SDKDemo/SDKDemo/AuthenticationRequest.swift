//
//  AuthenticationRequest.swift
//
//  Created by Neil Johnston on 7/30/18.
//  Copyright © 2018 Daon. All rights reserved.
//

import UIKit

class AuthenticationRequest: Codable {
    // MARK:- Properties
    
    var id : String?
    var authenticationRequestId : String?
    var description : String?
    
    var created : String?
    var processed : String?
    var expiration : String?
    
    var status : String?
    var fidoAuthenticationRequest : String?
    var fidoAuthenticationResponse : String?
    var fidoResponseCode : Int = 0
    var fidoResponseMsg : String?
    
    var transactionDescription : String?
    var transactionContentType : String?
    var textTransactionContent : String?
    var imageTransactionContent : String?
    
    // MARK:- Enums
    
    private enum CodingKeys : String, CodingKey {
        case id
        case authenticationRequestId
        case description
        case created
        case processed
        case expiration
        case status
        case fidoAuthenticationRequest
        case fidoAuthenticationResponse
        case fidoResponseCode
        case fidoResponseMsg
        case transactionDescription
        case transactionContentType
        case textTransactionContent
        case imageTransactionContent
    }
    
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.id) {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        if container.contains(.authenticationRequestId) {
            self.authenticationRequestId = try container.decode(String.self, forKey: .authenticationRequestId)
        }
        
        if container.contains(.description) {
            self.description = try container.decode(String.self, forKey: .description)
        }
        
        if container.contains(.created) {
            self.created = try container.decode(String.self, forKey: .created)
        }
        
        if container.contains(.processed) {
            self.processed = try container.decode(String.self, forKey: .processed)
        }
        
        if container.contains(.expiration) {
            self.expiration = try container.decode(String.self, forKey: .expiration)
        }
        
        if container.contains(.status) {
            self.status = try container.decode(String.self, forKey: .status)
        }
        
        if container.contains(.fidoAuthenticationRequest) {
            self.fidoAuthenticationRequest = try container.decode(String.self, forKey: .fidoAuthenticationRequest)
        }
        
        if container.contains(.fidoAuthenticationResponse) {
            let response = try container.decode(String.self, forKey: .fidoAuthenticationResponse)
            self.fidoAuthenticationResponse = response.replacingOccurrences(of: "null", with: "") // Parse out the "null" strings from fido.uaf.safetynet
        }
        
        if container.contains(.fidoResponseCode) {
            self.fidoResponseCode = try container.decode(Int.self, forKey: .fidoResponseCode)
        }

        if container.contains(.fidoResponseMsg) {
            self.fidoResponseMsg = try container.decode(String.self, forKey: .fidoResponseMsg)
        }
        
        if container.contains(.transactionDescription) {
            self.transactionDescription = try container.decode(String.self, forKey: .transactionDescription)
        }
        
        if container.contains(.transactionContentType) {
            self.transactionContentType = try container.decode(String.self, forKey: .transactionContentType)
        }
        
        if container.contains(.textTransactionContent) {
            self.textTransactionContent = try container.decode(String.self, forKey: .textTransactionContent)
        }
        
        if container.contains(.imageTransactionContent) {
            self.imageTransactionContent = try container.decode(String.self, forKey: .imageTransactionContent)
        }
    }
}

