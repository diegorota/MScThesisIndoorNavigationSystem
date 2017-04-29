//
//  SettingsViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 16/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var surname: UILabel!
    @IBOutlet weak var fiscalCode: UILabel!
    @IBOutlet weak var settingsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.isScrollEnabled = false
        
        title = "Settings"
        
        name.textColor = Colors.darkColor
        surname.textColor = Colors.darkColor
        fiscalCode.textColor = Colors.darkColor
        
        name.text = defaults.string(forKey: UserDefaultsKeys.nameKey)!
        surname.text = defaults.string(forKey: UserDefaultsKeys.surnameKey)!
        fiscalCode.text = defaults.string(forKey: UserDefaultsKeys.fiscalCodeKey)!
        image.image = UIImage(named: "User_logo")?.withRenderingMode(.alwaysTemplate)
        image.tintColor = Colors.darkColor
        
        settingsTableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.textColor = Colors.darkColor
        if indexPath.row == 0 {
            cell.textLabel?.text = "Logout"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Bluetooth pairing"
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Office Map"
        }
        cell.textLabel?.textColor = Colors.darkColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let login = storyboard?.instantiateViewController(withIdentifier: "LoginNavigation") {
                let appDomain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: appDomain)
                present(login,animated: true)
            }
        } else if indexPath.row == 1 {
            if let pairing = storyboard?.instantiateViewController(withIdentifier: "Pairing") {
                self.navigationController?.pushViewController(pairing, animated: true)
            }
        } else if indexPath.row == 2 {
            if let map = storyboard?.instantiateViewController(withIdentifier: "OfficeMap") {
                self.navigationController?.pushViewController(map, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}
