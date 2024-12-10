// Copyright (C) 2022 Daon.
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
// DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

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
