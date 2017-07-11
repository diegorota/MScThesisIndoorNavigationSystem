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

    @IBOutlet weak var secondDishTableView: UITableView!
    @IBOutlet weak var firstDishTableView: UITableView!
    @IBOutlet weak var secondDishSwitch: UISwitch!
    @IBOutlet weak var firstDishSwitch: UISwitch!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var firstDishLabel: UILabel!
    @IBOutlet weak var secondDishLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var confirmationView: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var confirmationMenuBool = false
    var menu: CafeteriaMenu!
    
    var firstChoosen = true
    var secondChoosen = true
    
    var firstDish: String?
    var secondDish: String?
    
    var selectedFirstIndexPath: IndexPath? = IndexPath(row: 0, section: 0)
    var selectedSecondIndexPath: IndexPath? = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.backgroundColor = Colors.mediumColor
        confirmButton.titleLabel?.textColor = UIColor.white
        modifyButton.backgroundColor = Colors.mediumColor
        confirmButton.titleLabel?.tintColor = UIColor.white

        dateLabel.textColor = Colors.darkColor
        firstDishLabel.textColor = Colors.darkColor
        secondDishLabel.textColor = Colors.darkColor
        informationLabel.textColor = Colors.darkColor
        confirmationView.textColor = Colors.darkColor
        
        confirmationView.isHidden = true
        confirmationView.adjustsFontSizeToFitWidth = true
        
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
        
        self.menu = CafeteriaData.getData()
        self.dateLabel.text = "\(menu.lastDayName!.capitalized) \(menu.lastDay!), \(menu.lastType!.capitalized)"
        if menu.newMenu == false {
            selectedFirstIndexPath = IndexPath(row: defaults.integer(forKey: UserDefaultsKeys.selectedFirstDishIndexPathKey), section: 0)
            selectedSecondIndexPath = IndexPath(row: defaults.integer(forKey: UserDefaultsKeys.selectedSecondDishIndexPathKey), section: 0)
            firstChoosen = defaults.bool(forKey: UserDefaultsKeys.firstChoosenBoolKey)
            secondChoosen = defaults.bool(forKey: UserDefaultsKeys.secondChoosenBoolKey)
            confirmationMenuBool = defaults.bool(forKey: UserDefaultsKeys.confirmationMenuBoolKey)
        } else {
            selectedFirstIndexPath = IndexPath(row: 0, section: 0)
            selectedSecondIndexPath = IndexPath(row: 0, section: 0)
            firstChoosen = true
            secondChoosen = true
            confirmationMenuBool = false
        }
        firstDishSwitch.isOn = firstChoosen
        secondDishSwitch.isOn = secondChoosen
        firstDishTableView.isHidden = !firstChoosen
        secondDishTableView.isHidden = !secondChoosen
        confirmButton.isHidden = confirmationMenuBool
        modifyButton.isHidden = true
        if confirmationMenuBool {
            hideView(duration: 0.5, confirmation: true)
        } else {
            showView(duration: 0.5, confirmation: true)
        }

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
        
        if sender.currentTitle == "Confirm" {
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
            self.dateLabel.alpha = 0
            self.confirmButton.alpha = 0
            
            self.confirmationView.alpha = 0.7
            self.modifyButton.alpha = 1
        }){[unowned self] (finished: Bool) in
            self.firstDishLabel.isHidden = true
            self.firstDishSwitch.isHidden = true
            self.firstDishTableView.isHidden = true
            
            self.secondDishLabel.isHidden = true
            self.secondDishSwitch.isHidden = true
            self.secondDishTableView.isHidden = true
            
            self.informationLabel.isHidden = true
            self.dateLabel.isHidden = true
            self.confirmButton.isHidden = true
            if confirmation {
                self.confirmationView.isHidden = false
                self.modifyButton.isHidden = false
            }
        }
    }
    
    func showView(duration: Double, confirmation: Bool) {
        UIView.animate(withDuration: duration, delay: 0, options: [], animations: { [unowned self] in
            self.firstDishLabel.alpha = 0.7
            self.firstDishSwitch.alpha = 1
            self.firstDishTableView.alpha = 1
            
            self.secondDishLabel.alpha = 0.7
            self.secondDishSwitch.alpha = 1
            self.secondDishTableView.alpha = 1
            
            self.informationLabel.alpha = 0.7
            self.dateLabel.alpha = 0.7
            self.confirmButton.alpha = 1
            
            self.confirmationView.alpha = 0
            self.modifyButton.alpha = 0
        }){[unowned self] (finished: Bool) in
            self.firstDishLabel.isHidden = false
            self.firstDishSwitch.isHidden = false
            self.firstDishTableView.isHidden = !self.firstChoosen
            
            self.secondDishLabel.isHidden = false
            self.secondDishSwitch.isHidden = false
            self.secondDishTableView.isHidden = !self.secondChoosen
            
            self.informationLabel.isHidden = false
            self.dateLabel.isHidden = false
            self.confirmButton.isHidden = false
            
            if confirmation {
                self.confirmationView.isHidden = true
                self.modifyButton.isHidden = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return menu.firstDishes!.count
        } else if tableView.tag == 1 {
            return menu.secondDishes!.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = CafeteriaCell()
        
        if tableView.tag == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "FirstDishCell", for: indexPath) as! CafeteriaCell
            cell.titleLabel.text = menu.firstDishes![indexPath.row].capitalized
            if indexPath == selectedFirstIndexPath {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        } else if tableView.tag == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SecondDishCell", for: indexPath) as! CafeteriaCell
            cell.titleLabel.text = menu.secondDishes![indexPath.row].capitalized
            if indexPath == selectedSecondIndexPath {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        cell.titleLabel.textColor = Colors.darkColor
        cell.titleLabel.backgroundColor = UIColor.clear
        cell.tintColor = Colors.darkColor
        cell.layer.backgroundColor = UIColor(white: 1, alpha: 0.7).cgColor
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
    }
    
}
