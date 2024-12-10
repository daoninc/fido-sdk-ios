// Copyright (C) 2022 Daon.
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
// DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

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

