//
//  DeregistrationRequest
//
//  Copyright © 2019 Daon. All rights reserved.
//

import UIKit

class DeregistrationRequest: Codable {
    
    var id : String?
    var fidoDeregistrationRequest : String?
    var fidoResponseCode : Int = 0
    var fidoResponseMsg : String?
    
    private enum CodingKeys : String, CodingKey {
        case id
        case fidoDeregistrationRequest
        case fidoResponseCode
        case fidoResponseMsg
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.id) {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        if container.contains(.fidoDeregistrationRequest) {
            self.fidoDeregistrationRequest = try container.decode(String.self, forKey: .fidoDeregistrationRequest)
        }
                
        if container.contains(.fidoResponseCode) {
            self.fidoResponseCode = try container.decode(Int.self, forKey: .fidoResponseCode)
        }
        
        if container.contains(.fidoResponseMsg) {
            self.fidoResponseMsg = try container.decode(String.self, forKey: .fidoResponseMsg)
        }                
    }
}
