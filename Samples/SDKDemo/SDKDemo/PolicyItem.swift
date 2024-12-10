//
//  PolicyItem
//
//  Created by Jonny on 2/8/19.
//  Copyright © 2019 Daon. All rights reserved.
//

import UIKit

class PolicyItem: Codable {
    
    var href : String?
    var id : String?
    var policyId : String?
    
    private enum CodingKeys : String, CodingKey {
        case href
        case id
        case policyId
        
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.href) {
            self.href = try container.decode(String.self, forKey: .href)
        }
        
        if container.contains(.id) {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        if container.contains(.policyId) {
            self.policyId = try container.decode(String.self, forKey: .policyId)
        }
    }
}
