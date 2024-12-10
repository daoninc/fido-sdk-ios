//
//  RegistrationChallenge.swift
//
//  Created by Neil Johnston on 7/30/18.
//  Copyright © 2018 Daon. All rights reserved.
//

import UIKit

class RegistrationChallenge: Codable {
    
    var id : String?
    var fidoRegistrationRequest : String?
    var fidoRegistrationResponse : String?
    var fidoResponseCode : Int = 0
    var fidoResponseMsg : String?
    
    private enum CodingKeys : String, CodingKey {
        case id
        case fidoRegistrationRequest
        case fidoRegistrationResponse
        case fidoResponseCode
        case fidoResponseMsg
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.id) {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        if container.contains(.fidoRegistrationRequest) {
            self.fidoRegistrationRequest = try container.decode(String.self, forKey: .fidoRegistrationRequest)
        }
        
        if container.contains(.fidoRegistrationResponse) {
            self.fidoRegistrationResponse = try container.decode(String.self, forKey: .fidoRegistrationResponse)
        }
        
        if container.contains(.fidoResponseCode) {
            self.fidoResponseCode = try container.decode(Int.self, forKey: .fidoResponseCode)
        }
        
        if container.contains(.fidoResponseMsg) {
            self.fidoResponseMsg = try container.decode(String.self, forKey: .fidoResponseMsg)
        }                
    }
}
