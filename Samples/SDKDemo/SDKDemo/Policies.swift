//
//  Policies
//
//  Created by Jonny on 2/8/19.
//  Copyright © 2019 Daon. All rights reserved.
//

import UIKit

class Policies: Codable {
    
    var items : [PolicyItem]?
    
    private enum CodingKeys : String, CodingKey {
        case items        
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.items) {
            self.items = try container.decode([PolicyItem].self, forKey: .items)
        }
    }
}
