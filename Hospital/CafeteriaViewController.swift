//
//  CafeteriaViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 17/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class CafeteriaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var secondDishTableView: UITableView!
    @IBOutlet weak var firstDishTableView: UITableView!
    @IBOutlet weak var secondDishSwitch: UISwitch!
    @IBOutlet weak var firstDishSwitch: UISwitch!
    
    var firstDish = [String]()
    var secondDish = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.visibleViewController?.title = "Cafeteria"
        firstDishTableView.delegate = self
        secondDishTableView.delegate = self
        
        firstDishTableView.dataSource = self
        secondDishTableView.dataSource = self

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
        
        firstDish = json["first_dish"].arrayObject as! [String]
        secondDish = json["second_dish"].arrayObject as! [String]
        
        dateLabel.text = "\(dayName) \(day), \(type)"
    }
    
    @IBAction func changeSwitch(_ sender: UISwitch) {

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return firstDish.count
        } else if tableView.tag == 1 {
            return secondDish.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if tableView.tag == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "FirstDishCell", for: indexPath)
            cell.textLabel?.text = firstDish[indexPath.row]
        } else if tableView.tag == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SecondDishCell", for: indexPath)
            cell.textLabel?.text = secondDish[indexPath.row]
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDishes()
    }
    
}
