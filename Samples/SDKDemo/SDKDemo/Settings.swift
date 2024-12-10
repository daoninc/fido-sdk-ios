//
//  Settings.swift
//  Copyright © 2019 Daon. All rights reserved.
//

import Foundation


class Settings {

    public struct Key {
        static let serverAddress    = "com.daon.server.address"        
        static let serverUsername   = "com.daon.server.username"
        static let serverPassword   = "com.daon.server.password"
        
        static let serverApplicationID          = "com.daon.server.application"
        static let serverRegistrationPolicyID   = "com.daon.server.policy.reg"
        static let serverAuthenticationPolicyID = "com.daon.server.policy.auth"
        
        static let notification = "com.daon.notification"
        static let username = "com.daon.username"
    }
    
    static let shared = Settings()
    
    init() {
        if let initialDefaultsPath = Bundle.main.path(forResource: "defaultPrefs", ofType: "plist") {
            if let keyedValues = NSDictionary(contentsOfFile: initialDefaultsPath) {
                UserDefaults.standard.register(defaults: keyedValues as! Dictionary)
            }
        }
    }
    
    public func set(key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public func get(key: String) -> [String : Any]? {
        return UserDefaults.standard.dictionary(forKey: key)
    }
    
    public func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public func getString(key: String) -> String {
        if let value = UserDefaults.standard.string(forKey: key) {
            return value
        }
        
        return "NA"
    }
    
    public func getInt(key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    public func getBool(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    public func reset() {
        
        let dict = UserDefaults.standard.dictionaryRepresentation()
        
        for key in dict.keys{
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        UserDefaults.standard.synchronize()
    }
}
