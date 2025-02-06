//
//  StatusViewController.swift
//
//  Copyright © 2019-22 Daon. All rights reserved.
//

import Foundation
import UIKit
import DaonFIDOSDK

class StatusViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
            case 0: textView.text = info()
            case 1: textView.text = Logging.content
            default: break
        }
    }
    
    override func viewDidLoad() {
        
        textView.text = info()
    }
    
    private func info() -> String {
        var str = String()
        
        let accounts = IXUAF.accounts()
        str.append("ACCOUNTS:\n\n")
        for account in accounts {
            str.append(account)
            str.append("\n")
        }
        str.append("\n\n")
    
        
        str.append("INFO:\n\n")
        str.append("facet:\n")
        str.append(IXUAF.facet())
        str.append("\n\n")
                
        let keys = IXUAF.keys()
        str.append("KEYS:\n\n")
        str.append(string(dictionary: keys))
    
        return str
    }
    
    private func string(dictionary: [String : Any]) -> String {
        
        var str = String()
        
        let keys = dictionary.keys
        for key in keys {
            str.append(key)
            str.append(":")
            str.append("\n")
            let value = dictionary[key]
            
            if let value = value as? [String : Any] {
                str.append(string(dictionary: value))
            } else if let value = value as? String {
                str.append(value)
            } else if let value = value as? Date {
                str.append(value.description)
            }
            str.append("\n\n")
        }
        
        return str
    }
}
