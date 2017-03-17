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
        navigationController?.visibleViewController?.title = "Cafeteria"
        
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
        } else if sender.tag == 1 {
            secondChoosen = secondDishSwitch.isOn
            secondDishTableView.isHidden = !secondChoosen
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
            defaults.setValue(selectedFirstIndexPath?.row, forKey: UserDefaultsKeys.selectedFirstDishIndexPath)
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
            defaults.setValue(selectedSecondIndexPath?.row, forKey: UserDefaultsKeys.selectedSecondDishIndexPath)
            defaults.synchronize()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDishes()
        selectedFirstIndexPath = IndexPath(row: defaults.integer(forKey: UserDefaultsKeys.selectedFirstDishIndexPath), section: 0)
        selectedSecondIndexPath = IndexPath(row: defaults.integer(forKey: UserDefaultsKeys.selectedSecondDishIndexPath), section: 0)

    }
    
}
