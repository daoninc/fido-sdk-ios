//
//  User
//
//  Created by Neil Johnston on 7/30/18.
//  Copyright © 2018 Daon. All rights reserved.
//

import UIKit

class User: Codable {
    
    
    var id : String?
    var userId : String?
    var created : String?
    var updated : String?
    var status : String?
    
    private enum CodingKeys : String, CodingKey {
        case id
        case userId
        case created
        case updated
        case status
    }
    
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.id) {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        if container.contains(.userId) {
            self.userId = try container.decode(String.self, forKey: .userId)
        }
        
        if container.contains(.created) {
            self.created = try container.decode(String.self, forKey: .created)
        }
        
        if container.contains(.updated) {
            self.updated = try container.decode(String.self, forKey: .updated)
        }
        
        if container.contains(.status) {
            self.status = try container.decode(String.self, forKey: .status)
        }
    }
}

