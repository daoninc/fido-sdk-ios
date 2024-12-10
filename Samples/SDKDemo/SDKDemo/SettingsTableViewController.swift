//
//  SettingsTableViewController.swift
//
//  Copyright © 2018-23 Daon. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    private enum Section : Int {
        case User
        case Server
        case ApplicationAndPolicyIds        
        case MAX
    }
    
    private enum ServerSectionRow : Int {
        case address
        case username
        case password
        case MAX
    }
    
    private enum AppSectionRow : Int {
        case ID
        case registrationPolicyID
        case authenticationPolicyID
        case MAX
    }
    
    private enum UserSectionRow : Int {
        case username
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
            case Section.User.rawValue:                     return UserSectionRow.MAX.rawValue
            case Section.Server.rawValue:                   return ServerSectionRow.MAX.rawValue
            case Section.ApplicationAndPolicyIds.rawValue:  return AppSectionRow.MAX.rawValue
            default:                                        return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            case Section.User.rawValue:                     return "User"
            case Section.Server.rawValue:                   return "Server"
            case Section.ApplicationAndPolicyIds.rawValue:  return "Application & Policy IDs"
            default:                                        return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "textCellReuseIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell...
        
        switch indexPath.section {
            case Section.User.rawValue:
                switch indexPath.row {
                    case UserSectionRow.username.rawValue:
                        cell.textLabel?.text        = "Username"
                        cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath)!)
                
                    default:
                        cell.textLabel?.text        = ""
                        cell.detailTextLabel?.text  = ""
                }

            case Section.Server.rawValue:
                switch indexPath.row {
                    case ServerSectionRow.address.rawValue:
                        cell.textLabel?.text        = "URL"
                        cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath)!)
                                        
                    case ServerSectionRow.username.rawValue:
                        cell.textLabel?.text        = "Username"
                        cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath)!)
                    
                    case ServerSectionRow.password.rawValue:
                        cell.textLabel?.text        = "Password"
                        cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath)!)
                    
                    default:
                        cell.textLabel?.text        = ""
                        cell.detailTextLabel?.text  = ""
                }
            
            case Section.ApplicationAndPolicyIds.rawValue:
                switch indexPath.row {
                    case AppSectionRow.ID.rawValue:
                        cell.textLabel?.text        = "Application ID"
                        cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath)!)
                    
                    case AppSectionRow.registrationPolicyID.rawValue:
                        cell.textLabel?.text        = "Registration Policy ID"
                        cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath)!)
                    
                    case AppSectionRow.authenticationPolicyID.rawValue:
                        cell.textLabel?.text        = "Authentication Policy ID"
                        cell.detailTextLabel?.text  = Settings.shared.getString(key: userDefaultsKey(forIndexPath: indexPath)!)
                    
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
                    if editableAlert.textFields![0].keyboardType == .numberPad {
                        UserDefaults.standard.set(Int(enteredText), forKey: self.userDefaultsKey(forIndexPath: indexPath)!)
                    } else {
                        UserDefaults.standard.set(enteredText, forKey: self.userDefaultsKey(forIndexPath: indexPath)!)
                    }
                    
                    self.tableView.reloadData()
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
            case Section.Server.rawValue:
                switch indexPath.row {
                    case ServerSectionRow.address.rawValue:     key = Settings.Key.serverAddress
                    case ServerSectionRow.username.rawValue:    key = Settings.Key.serverUsername
                    case ServerSectionRow.password.rawValue:    key = Settings.Key.serverPassword
                    default:                                    key = nil
                }
            
            case Section.ApplicationAndPolicyIds.rawValue:
                switch indexPath.row {
                    case AppSectionRow.ID.rawValue:                       key = Settings.Key.serverApplicationID
                    case AppSectionRow.registrationPolicyID.rawValue:     key = Settings.Key.serverRegistrationPolicyID
                    case AppSectionRow.authenticationPolicyID.rawValue:   key = Settings.Key.serverAuthenticationPolicyID
                    default:                                              key = nil
                }
            case Section.User.rawValue:
                switch indexPath.row {
                    case UserSectionRow.username.rawValue:  key = Settings.Key.username
                    default:                                key = nil
                }
            
            default: key = nil
        }
        
        return key
    }
    
}
