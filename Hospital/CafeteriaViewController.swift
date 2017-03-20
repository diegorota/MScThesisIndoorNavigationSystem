//
//  CafeteriaViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 17/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class CafeteriaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let defaults = UserDefaults.standard
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var secondDishTableView: UITableView!
    @IBOutlet weak var firstDishTableView: UITableView!
    @IBOutlet weak var secondDishSwitch: UISwitch!
    @IBOutlet weak var firstDishSwitch: UISwitch!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var firstDishLabel: UILabel!
    @IBOutlet weak var secondDishLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    
    var confirmationView: UILabel? = nil
    var confirmationMenuBool = false
    
    var firstDishes = [String]()
    var secondDishes = [String]()
    var firstChoosen = true
    var secondChoosen = true
    
    var firstDish: String?
    var secondDish: String?
    
    var selectedFirstIndexPath: IndexPath? = IndexPath(row: 0, section: 0)
    var selectedSecondIndexPath: IndexPath? = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.layer.cornerRadius = 5
        
        firstChoosen = firstDishSwitch.isOn
        secondChoosen = secondDishSwitch.isOn
        
        firstDishTableView.isHidden = !firstChoosen
        secondDishTableView.isHidden = !secondChoosen
        
        firstDishTableView.delegate = self
        secondDishTableView.delegate = self
        
        firstDishTableView.dataSource = self
        secondDishTableView.dataSource = self
        
        firstDishTableView.isScrollEnabled = false
        secondDishTableView.isScrollEnabled = false
        
    }
    
    // Funzione che carica il file JSON contenente le informazioni dei pasti
    func loadDishes() {
        
        if let path = Bundle.main.path(forResource: "json/cafeteria", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) {
                let json = JSON(data: data)
                parse(json: json)
            }
        }
    }
    
    func parse(json: JSON) {
        
        let day = json["day"].intValue
        let dayName = json["day_name"].stringValue
        let type = json["type"].stringValue
        
        firstDishes = json["first_dish"].arrayObject as! [String]
        secondDishes = json["second_dish"].arrayObject as! [String]
        
        dateLabel.text = "\(dayName) \(day), \(type)"
    }
    
    @IBAction func changeSwitch(_ sender: UISwitch) {
        if sender.tag == 0 {
            firstChoosen = firstDishSwitch.isOn
            firstDishTableView.isHidden = !firstChoosen
            defaults.setValue(firstChoosen, forKey: UserDefaultsKeys.firstChoosenBoolKey)
            defaults.synchronize()
        } else if sender.tag == 1 {
            secondChoosen = secondDishSwitch.isOn
            secondDishTableView.isHidden = !secondChoosen
            defaults.setValue(secondChoosen, forKey: UserDefaultsKeys.secondChoosenBoolKey)
            defaults.synchronize()
        }
    }
    
    @IBAction func confirmButtonAction(_ sender: UIButton) {
        
        if confirmButton.currentTitle == "Confirm" {
            hideView(duration: 0.5, confirmation: true)
            confirmationMenuBool = true
            
        } else {
            showView(duration: 0.5, confirmation: true)
            confirmationMenuBool = false
        }
        defaults.setValue(confirmationMenuBool, forKey: UserDefaultsKeys.confirmationMenuBoolKey)
        defaults.synchronize()
    }
    
    func hideView(duration: Double, confirmation: Bool) {
        UIView.animate(withDuration: duration, delay: 0, options: [], animations: { [unowned self] in
            self.firstDishLabel.alpha = 0
            self.firstDishSwitch.alpha = 0
            self.firstDishTableView.alpha = 0
            
            self.secondDishLabel.alpha = 0
            self.secondDishSwitch.alpha = 0
            self.secondDishTableView.alpha = 0
            
            self.informationLabel.alpha = 0
        }){[unowned self] (finished: Bool) in
            self.firstDishLabel.isHidden = true
            self.firstDishSwitch.isHidden = true
            self.firstDishTableView.isHidden = true
            
            self.secondDishLabel.isHidden = true
            self.secondDishSwitch.isHidden = true
            self.secondDishTableView.isHidden = true
            
            self.informationLabel.isHidden = true
            
            if confirmation {
                self.confirmationView = UILabel(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2-300/2, y: self.view.frame.height/2-100/2), size: CGSize(width: 300, height: 100)))
                self.confirmationView?.text = "You have choosen the menu."
                self.confirmationView?.font = UIFont.boldSystemFont(ofSize: 24)
                self.confirmationView?.numberOfLines = 2
                self.confirmationView?.lineBreakMode = NSLineBreakMode.byWordWrapping
                self.confirmationView?.adjustsFontSizeToFitWidth = true
                self.confirmationView?.textAlignment = NSTextAlignment.center
                self.view.addSubview(self.confirmationView!)
            }
            
            self.confirmButton.setTitle("Modify", for: .normal)
        }
    }
    
    func showView(duration: Double, confirmation: Bool) {
        UIView.animate(withDuration: duration, delay: 0, options: [], animations: { [unowned self] in
            self.firstDishLabel.alpha = 1
            self.firstDishSwitch.alpha = 1
            self.firstDishTableView.alpha = 1
            
            self.secondDishLabel.alpha = 1
            self.secondDishSwitch.alpha = 1
            self.secondDishTableView.alpha = 1
            
            self.informationLabel.alpha = 1
        }){[unowned self] (finished: Bool) in
            self.firstDishLabel.isHidden = false
            self.firstDishSwitch.isHidden = false
            self.firstDishTableView.isHidden = !self.firstChoosen
            
            self.secondDishLabel.isHidden = false
            self.secondDishSwitch.isHidden = false
            self.secondDishTableView.isHidden = !self.secondChoosen
            
            self.informationLabel.isHidden = false
            
            if confirmation {
                self.confirmationView?.removeFromSuperview()
            }
            
            self.confirmButton.setTitle("Confirm", for: .normal)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return firstDishes.count
        } else if tableView.tag == 1 {
            return secondDishes.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if tableView.tag == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "FirstDishCell", for: indexPath)
            cell.textLabel?.text = firstDishes[indexPath.row]
            if indexPath == selectedFirstIndexPath {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        } else if tableView.tag == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SecondDishCell", for: indexPath)
            cell.textLabel?.text = secondDishes[indexPath.row]
            if indexPath == selectedSecondIndexPath {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            tableView.deselectRow(at: selectedFirstIndexPath!, animated: true)
            if indexPath == selectedFirstIndexPath {
                return
            }
            let newCell = tableView.cellForRow(at: indexPath)
            if newCell?.accessoryType == UITableViewCellAccessoryType.none {
                newCell?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            let oldCell = tableView.cellForRow(at: selectedFirstIndexPath!)
            if oldCell?.accessoryType == UITableViewCellAccessoryType.checkmark {
                oldCell?.accessoryType = UITableViewCellAccessoryType.none
            }
            selectedFirstIndexPath = indexPath
            defaults.setValue(selectedFirstIndexPath?.row, forKey: UserDefaultsKeys.selectedFirstDishIndexPathKey)
            defaults.synchronize()
        } else if tableView.tag == 1 {
            tableView.deselectRow(at: selectedSecondIndexPath!, animated: true)
            if indexPath == selectedSecondIndexPath {
                return
            }
            let newCell = tableView.cellForRow(at: indexPath)
            if newCell?.accessoryType == UITableViewCellAccessoryType.none {
                newCell?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            let oldCell = tableView.cellForRow(at: selectedSecondIndexPath!)
            if oldCell?.accessoryType == UITableViewCellAccessoryType.checkmark {
                oldCell?.accessoryType = UITableViewCellAccessoryType.none
            }
            selectedSecondIndexPath = indexPath
            defaults.setValue(selectedSecondIndexPath?.row, forKey: UserDefaultsKeys.selectedSecondDishIndexPathKey)
            defaults.synchronize()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Cafeteria"
        loadDishes()
        selectedFirstIndexPath = IndexPath(row: defaults.integer(forKey: UserDefaultsKeys.selectedFirstDishIndexPathKey), section: 0)
        selectedSecondIndexPath = IndexPath(row: defaults.integer(forKey: UserDefaultsKeys.selectedSecondDishIndexPathKey), section: 0)
        firstChoosen = defaults.bool(forKey: UserDefaultsKeys.firstChoosenBoolKey)
        secondChoosen = defaults.bool(forKey: UserDefaultsKeys.secondChoosenBoolKey)
        confirmationMenuBool = defaults.bool(forKey: UserDefaultsKeys.confirmationMenuBoolKey)
        firstDishSwitch.isOn = firstChoosen
        secondDishSwitch.isOn = secondChoosen
        firstDishTableView.isHidden = !firstChoosen
        secondDishTableView.isHidden = !secondChoosen
        
        if confirmationMenuBool {
            hideView(duration: 0.5, confirmation: true)
        }
        
    }
    
}
