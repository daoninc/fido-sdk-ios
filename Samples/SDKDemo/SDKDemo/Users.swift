//
//  Users
//
//  Created by Jonny on 2/8/19.
//  Copyright © 2019 Daon. All rights reserved.
//

import UIKit

class Users: Codable {
    
    var items : [User]?
    
    private enum CodingKeys : String, CodingKey {
        case items        
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.items) {
            self.items = try container.decode([User].self, forKey: .items)
        }
    }
}
