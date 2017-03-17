//
//  HomeViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 15/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tiles = [HomeTile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        title = "Hospital"
        helloLabel.text = "Hello, \(PersonLogged.name)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Settings"), style: .plain, target: self, action: #selector(openSettings))
        loadTiles()

    }
    
    func composeDate() -> String {
        
        let date = Date()
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return "\(day) \(monthConverter(month)) \(year)"
    }
    
    func composeHour() -> String {
        
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        var minuteString: String
        
        if minutes < 10 {
            minuteString = "0\(minutes)"
        } else {
            minuteString = "\(minutes)"
        }
        
        return "\(hour):\(minuteString)"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tile", for: indexPath) as! TileCell
        cell.titleLabel.text = tiles[indexPath.item].titleTile.uppercased()
        cell.descriptionLabel.text = tiles[indexPath.item].descriptionTile
        cell.iconImage.image = UIImage(named: "Settings")
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    
    func monthConverter(_ monthNumber: Int) -> String {
        switch monthNumber {
        case 01:
            return "January"
        case 02:
            return "February"
        case 03:
            return "March"
        case 04:
            return "April"
        case 05:
            return "May"
        case 06:
            return "June"
        case 07:
            return "July"
        case 08:
            return "August"
        case 09:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        case 12:
            return "December"
        default:
            print("missing month!")
            return "error"
        }
    }
    
    func openSettings() {
        if let settings = storyboard?.instantiateViewController(withIdentifier: "Settings") as? SettingsViewController {
            navigationController?.pushViewController(settings, animated: true)
        }
    }
    
    // Funzione che carica il file JSON contenente le informazioni delle tiles, crea un oggetto HomeTile per ogni tile e lo inserisce nell'array tiles.
    func loadTiles() {
        
        if let path = Bundle.main.path(forResource: "json/homepage", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) {
                let json = JSON(data: data)
                parse(json: json)
            }
        }
    }
    
    func parse(json: JSON) {
        for tile in json.arrayValue {
            let homeTile = HomeTile(titleTile: tile["tilename"].stringValue, descriptionTile: "Questa è una descrizione.", logoTile: tile["logo"].stringValue, dimensionTile: tile["dimension"].intValue)
            tiles.append(homeTile)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dateLabel.text = composeDate()
        hourLabel.text = composeHour()
    }
    
    @IBAction func but(_ sender: Any) {
        if let settings = storyboard?.instantiateViewController(withIdentifier: "TabBar") as? UITabBarController {
            navigationController?.pushViewController(settings, animated: true)
        }
    }
    
}
