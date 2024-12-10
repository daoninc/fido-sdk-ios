//
//  LogUtils.swift
//  Copyright © 2019 Daon. All rights reserved.
//

import Foundation

class Logging {
    static let max = 20000;
    
    public static var content = String()
        
    class func log(string : String) {
        print("Daon - ", string)
        
        if content.count > max {
            content = ""
        }
        content.append(string)
        content.append("\n")
    }
    
}
