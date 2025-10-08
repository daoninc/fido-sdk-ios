//
//  SettingsTableViewController.swift
//
//  Copyright © 2018-25 Daon. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    private enum Section : Int {
        case service
        case rest
        case rpsa
        case MAX
    }
    
    private enum RESTSectionRow : Int {
        case account
        case url
        case username
        case password
        case applicationID
        case registrationPolicyID
        case authenticationPolicyID
        case MAX
    }
    
    private enum RPSASectionRow : Int {
        case account
        case url
        case MAX
    }
    
    private enum ServiceSectionRow : Int {
        case type
        case MAX
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.title = "Settings"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Section.MAX.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch section {
        case Section.service.rawValue:                  return ServiceSectionRow.MAX.rawValue
        case Section.rest.rawValue:                     return RESTSectionRow.MAX.rawValue
        case Section.rpsa.rawValue:                     return RPSASectionRow.MAX.rawValue
        default:                                        return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case Section.service.rawValue:                  return "Service"
        case Section.rest.rawValue:                     return "REST Settings"
        case Section.rpsa.rawValue:                     return "RPSA Settings"
        default:                                        return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.cellForRow(at: indexPath) ?? UITableViewCell(style: .value1, reuseIdentifier: "textCellReuseIdentifier")
        
        switch indexPath.section {
        case Section.service.rawValue:
            switch indexPath.row {
            case ServiceSectionRow.type.rawValue:
                cell.textLabel?.text = "Type"
                let serviceSwitch = UISwitch()
                serviceSwitch.isOn = Settings.shared.getString(key: Settings.Key.serviceType) == Settings.RPSA
                serviceSwitch.addTarget(self, action: #selector(serviceTypeSwitchChanged(_:)), for: .valueChanged)
                cell.accessoryView = serviceSwitch
                cell.detailTextLabel?.text = serviceSwitch.isOn ? Settings.RPSA : Settings.REST
            default:
                cell.textLabel?.text = ""
                cell.detailTextLabel?.text = ""
            }
            
        case Section.rest.rawValue:
            switch indexPath.row {
            case RESTSectionRow.account.rawValue:
                cell.textLabel?.text        = "Account"
                cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath))
            case RESTSectionRow.url.rawValue:
                cell.textLabel?.text        = "URL"
                cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath))
            case RESTSectionRow.username.rawValue:
                cell.textLabel?.text        = "Username"
                cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath))
            case RESTSectionRow.password.rawValue:
                cell.textLabel?.text        = "Password"
                cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath))
            case RESTSectionRow.applicationID.rawValue:
                cell.textLabel?.text        = "Application ID"
                cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath))
                
            case RESTSectionRow.registrationPolicyID.rawValue:
                cell.textLabel?.text        = "Registration Policy ID"
                cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath))
                
            case RESTSectionRow.authenticationPolicyID.rawValue:
                cell.textLabel?.text        = "Authentication Policy ID"
                cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath))
                
            default:
                cell.textLabel?.text        = ""
                cell.detailTextLabel?.text  = ""
            }
            
        case Section.rpsa.rawValue:
            switch indexPath.row {
            case RPSASectionRow.account.rawValue:
                cell.textLabel?.text        = "Account"
                cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath))
            case RPSASectionRow.url.rawValue:
                cell.textLabel?.text        = "URL"
                cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath))
                
            default:
                cell.textLabel?.text        = ""
                cell.detailTextLabel?.text  = ""
            }
            
        default: cell.textLabel?.text = ""
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        
        let editableAlert = UIAlertController(title: cell.textLabel?.text,
                                              message: nil,
                                              preferredStyle: .alert)
        
        editableAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        editableAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            if let enteredText = editableAlert.textFields![0].text {
                if enteredText.count > 0 {
                    if let key = self.userDefaultsKey(forIndexPath: indexPath) {
                        if editableAlert.textFields![0].keyboardType == .numberPad {
                            UserDefaults.standard.set(Int(enteredText), forKey: key)
                        } else {
                            UserDefaults.standard.set(enteredText, forKey: key)
                        }
                        
                        self.tableView.reloadData()
                    }
                } else {
                    let error = UIAlertController(title: "Error", message: "Invalid input", preferredStyle: .alert)
                    error.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
                    self.present(error, animated: true, completion: nil)
                }
            }
        }))
        
        editableAlert.addTextField(configurationHandler: { (textField) in
            textField.text                          = cell.detailTextLabel?.text
            textField.autocapitalizationType        = UITextAutocapitalizationType.none
            textField.autocorrectionType            = UITextAutocorrectionType.no
            textField.enablesReturnKeyAutomatically = true
            textField.returnKeyType                 = UIReturnKeyType.done
            textField.clearButtonMode               = UITextField.ViewMode.whileEditing
        })
        
        self.present(editableAlert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK:- UserDefaults Helper
    
    private func userDefaultsKey(forIndexPath indexPath : IndexPath) -> String? {
        var key : String?
        
        switch indexPath.section {
        case Section.rest.rawValue:
            switch indexPath.row {
            case RESTSectionRow.account.rawValue:                   key = Settings.Key.restAccount
            case RESTSectionRow.url.rawValue:                       key = Settings.Key.restUrl
            case RESTSectionRow.username.rawValue:                  key = Settings.Key.restUsername
            case RESTSectionRow.password.rawValue:                  key = Settings.Key.restPassword
            case RESTSectionRow.applicationID.rawValue:             key = Settings.Key.restApplicationID
            case RESTSectionRow.registrationPolicyID.rawValue:      key = Settings.Key.restRegistrationPolicyID
            case RESTSectionRow.authenticationPolicyID.rawValue:    key = Settings.Key.restAuthenticationPolicyID
                
            default:
                key = nil
            }
            
        case Section.rpsa.rawValue:
            switch indexPath.row {
            case RPSASectionRow.account.rawValue:  key = Settings.Key.rpsaAccount
            case RPSASectionRow.url.rawValue:   key = Settings.Key.rpsaUrl
            default:
                key = nil
            }
                        
        default:
            key = nil
        }
        
        return key
    }
    
    @objc private func serviceTypeSwitchChanged(_ sender: UISwitch) {
        let type = sender.isOn ? Settings.RPSA : Settings.REST
        UserDefaults.standard.set(type, forKey: Settings.Key.serviceType)
        self.tableView.reloadData()
    }
}
