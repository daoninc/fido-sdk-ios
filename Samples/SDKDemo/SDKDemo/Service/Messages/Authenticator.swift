// Copyright (C) 2022 Daon.
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
// DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

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

