//
//  Authenticator
//
//  Copyright © 2019 Daon. All rights reserved.
//

import UIKit

class Authenticator: Codable {
    
    
    var id : String?
    var authenticatorId : String?
    var authenticatorAttestationId : String?
    var created : String?
    var updated : String?
    var archived : String?
    var status : String?
    var deviceCorrelationId :String?
    var appCorrelationId : String?
    
    private enum CodingKeys : String, CodingKey {
        case id
        case authenticatorId
        case authenticatorAttestationId
        case created
        case updated
        case archived
        case status
        case deviceCorrelationId
        case appCorrelationId
    }
    
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.id) {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        if container.contains(.authenticatorId) {
            self.authenticatorId = try container.decode(String.self, forKey: .authenticatorId)
        }
        
        // AAID
        if container.contains(.authenticatorAttestationId) {
            self.authenticatorAttestationId = try container.decode(String.self, forKey: .authenticatorAttestationId)
        }
        
        if container.contains(.created) {
            self.created = try container.decode(String.self, forKey: .created)
        }
        
        if container.contains(.updated) {
            self.updated = try container.decode(String.self, forKey: .updated)
        }
        
        if container.contains(.archived) {
            self.archived = try container.decode(String.self, forKey: .archived)
        }
        
        if container.contains(.status) {
            self.status = try container.decode(String.self, forKey: .status)
        }
        
        if container.contains(.deviceCorrelationId) {
            self.deviceCorrelationId = try container.decode(String.self, forKey: .deviceCorrelationId)
        }
        
        if container.contains(.appCorrelationId) {
            self.appCorrelationId = try container.decode(String.self, forKey: .appCorrelationId)
        }
    }
}

