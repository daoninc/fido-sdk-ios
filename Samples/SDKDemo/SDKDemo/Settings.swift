//
//  Settings.swift
//  Copyright © 2019 Daon. All rights reserved.
//

import Foundation


class Settings {

    static let RPSA = "RPSA"
    static let REST = "REST"
    
    public struct Key {
        static let restUrl = "com.daon.rest"
        static let restAccount = "com.daon.rest.account"
        static let restUsername = "com.daon.rest.username"
        static let restPassword = "com.daon.rest.password"
        static let restApplicationID = "com.daon.rest.application"
        static let restRegistrationPolicyID = "com.daon.rest.policy.reg"
        static let restAuthenticationPolicyID = "com.daon.rest.policy.auth"
        
        static let rpsaUrl = "com.daon.rpsa"
        static let rpsaAccount = "com.daon.rpsa.account"
        
        static let serviceType = "com.daon.service.type"
        
        static let notification = "com.daon.notification"
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
    
    public func getString(key: String?) -> String {
        if let key {            
            if let value = UserDefaults.standard.string(forKey: key) {
                return value
            }
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
