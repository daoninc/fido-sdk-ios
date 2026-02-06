//
//  LogUtils.swift
//  Copyright © 2019 Daon. All rights reserved.
//

import Foundation

class Logging {
    @MainActor static let shared = Logging()
    
    let max = 20000
    
    public var content = String()
        
    func log(string: String) {
        print("Daon - ", string)
        
        if content.count > max {
            content = ""
        }
        content.append(string)
        content.append("\n")
    }
    
}
